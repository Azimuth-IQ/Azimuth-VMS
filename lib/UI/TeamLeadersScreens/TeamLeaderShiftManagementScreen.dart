import 'package:azimuth_vms/Models/VolunteerForm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Helpers/NotificationHelperFirebase.dart';
import '../../Helpers/ShiftAssignmentHelperFirebase.dart';
import '../../Models/Event.dart';
import '../../Models/Location.dart';
import '../../Models/ShiftAssignment.dart';
import '../../Models/SystemUser.dart';
import '../../Providers/EventsProvider.dart';
import '../../Providers/ShiftAssignmentProvider.dart';

class TeamLeaderShiftManagementScreen extends StatelessWidget {
  const TeamLeaderShiftManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => EventsProvider()
            ..loadEvents()
            ..loadTeams()
            ..loadSystemUsers()
            ..loadLocations(),
        ),
        ChangeNotifierProvider(create: (_) => ShiftAssignmentProvider()),
      ],
      child: const TeamLeaderShiftManagementView(),
    );
  }
}

class TeamLeaderShiftManagementView extends StatefulWidget {
  const TeamLeaderShiftManagementView({super.key});

  @override
  State<TeamLeaderShiftManagementView> createState() => _TeamLeaderShiftManagementViewState();
}

class _TeamLeaderShiftManagementViewState extends State<TeamLeaderShiftManagementView> {
  String? _currentUserPhone;
  Event? _selectedEvent;
  EventShift? _selectedShift;
  String? _selectedLocationId; // Can be main locationId or sublocationId
  bool _isMainLocation = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserPhone = user.email!.split('@').first;
      });
    }
  }

  List<Event> _getFilteredEvents(EventsProvider provider) {
    if (_currentUserPhone == null) return [];

    return provider.events.where((event) {
      return event.shifts.any((shift) {
        return _isMyShiftOrLocation(shift, provider);
      });
    }).toList();
  }

  bool _isMyShiftOrLocation(EventShift shift, EventsProvider provider) {
    // Check main location team
    if (shift.teamId != null) {
      final team = provider.teams.where((t) => t.id == shift.teamId).firstOrNull;
      if (team != null && team.teamLeaderId == _currentUserPhone) {
        return true;
      }
    }
    if (shift.tempTeam != null) {
      if (shift.tempTeam!.teamLeaderId == _currentUserPhone) {
        return true;
      }
    }

    // Check sublocation teams
    for (ShiftSubLocation subLoc in shift.subLocations) {
      if (subLoc.teamId != null) {
        final team = provider.teams.where((t) => t.id == subLoc.teamId).firstOrNull;
        if (team != null && team.teamLeaderId == _currentUserPhone) {
          return true;
        }
      }
      if (subLoc.tempTeam != null) {
        if (subLoc.tempTeam!.teamLeaderId == _currentUserPhone) {
          return true;
        }
      }
    }

    return false;
  }

  void _assignVolunteersToLocation(BuildContext context) async {
    if (_selectedEvent == null || _selectedShift == null || _selectedLocationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an event, shift, and location first')));
      return;
    }

    final EventsProvider provider = context.read<EventsProvider>();

    // Get team members based on selected location
    List<String> teamMemberIds = [];
    if (_isMainLocation) {
      // Main location team
      if (_selectedShift!.teamId != null) {
        try {
          final team = provider.teams.firstWhere((t) => t.id == _selectedShift!.teamId);
          teamMemberIds = team.memberIds;
        } catch (e) {
          print('Error finding team: $e');
        }
      } else if (_selectedShift!.tempTeam != null) {
        teamMemberIds = _selectedShift!.tempTeam!.memberIds;
      }
    } else {
      // Sublocation team
      final ShiftSubLocation subLoc = _selectedShift!.subLocations.firstWhere((sl) => sl.subLocationId == _selectedLocationId);
      if (subLoc.teamId != null) {
        try {
          final team = provider.teams.firstWhere((t) => t.id == subLoc.teamId);
          teamMemberIds = team.memberIds;
        } catch (e) {
          print('Error finding team: $e');
        }
      } else if (subLoc.tempTeam != null) {
        teamMemberIds = subLoc.tempTeam!.memberIds;
      }
    }

    if (teamMemberIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No team assigned to this location')));
      return;
    }

    // Filter volunteers from team members
    final List<SystemUser> volunteers = provider.systemUsers.where((u) {
      if (!teamMemberIds.contains(u.phone)) return false;
      if (u.role != SystemUserRole.VOLUNTEER) return false;
      if (u.volunteerForm == null) return false;
      final VolunteerFormStatus? status = u.volunteerForm!.status;
      return status == VolunteerFormStatus.Approved1 || status == VolunteerFormStatus.Approved2 || status == VolunteerFormStatus.Completed;
    }).toList();

    if (volunteers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No approved volunteers available in your team')));
      return;
    }

    // Show selection dialog
    final List<SystemUser>? selectedVolunteers = await showDialog<List<SystemUser>>(
      context: context,
      builder: (context) => _VolunteerSelectionDialog(volunteers: volunteers),
    );

    if (selectedVolunteers != null && selectedVolunteers.isNotEmpty) {
      await _createAssignments(context, selectedVolunteers, _selectedEvent!, _selectedShift!, _isMainLocation ? null : _selectedLocationId);
    }
  }

  Future<void> _createAssignments(BuildContext context, List<SystemUser> volunteers, Event event, EventShift shift, String? sublocationId) async {
    try {
      final ShiftAssignmentHelperFirebase helper = ShiftAssignmentHelperFirebase();
      final NotificationHelperFirebase notifHelper = NotificationHelperFirebase();

      for (SystemUser volunteer in volunteers) {
        final ShiftAssignment assignment = ShiftAssignment(
          id: const Uuid().v4(),
          volunteerId: volunteer.phone,
          shiftId: shift.id,
          eventId: event.id,
          sublocationId: sublocationId,
          status: ShiftAssignmentStatus.ASSIGNED,
          assignedBy: _currentUserPhone!,
          timestamp: DateTime.now().toIso8601String(),
        );

        helper.CreateShiftAssignment(assignment);

        // Send notification with location info
        final locationInfo = sublocationId != null ? ' (Sublocation)' : '';
        notifHelper.sendVolunteerAssignmentNotification(volunteer.phone, event.name, '${shift.startTime} - ${shift.endTime}$locationInfo');
      }

      if (!context.mounted) return;
      final locationMsg = sublocationId != null ? ' to sublocation' : '';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Assigned ${volunteers.length} volunteers$locationMsg successfully')));

      // Reset selection
      setState(() {
        _selectedLocationId = null;
        _isMainLocation = true;
      });

      // No need to reload assignments manually as the stream listener is already active
      // and will automatically pick up the new assignments
    } catch (e) {
      print('Error creating assignments: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign My Team'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final EventsProvider provider = context.read<EventsProvider>();
              provider.loadEvents();
              provider.loadTeams();
              provider.loadSystemUsers();
            },
          ),
        ],
      ),
      body: Consumer<EventsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_currentUserPhone == null) {
            return const Center(child: Text('Unable to identify current user'));
          }

          final List<Event> myEvents = _getFilteredEvents(provider);

          if (myEvents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No events assigned to your teams', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text('Contact admin to assign your team to events', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final bool isDesktop = constraints.maxWidth > 900;

              if (isDesktop) {
                return _buildDesktopLayout(context, provider, myEvents);
              } else {
                return _buildMobileLayout(context, provider, myEvents);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, EventsProvider provider, List<Event> myEvents) {
    return Row(
      children: [
        // Left panel: Event and Shift selection
        Expanded(
          flex: 2,
          child: Card(
            margin: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Events', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text('Events where your team is assigned', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(child: _buildEventsList(context, provider, myEvents)),
              ],
            ),
          ),
        ),

        // Right panel: Location selection and assignment
        Expanded(
          flex: 3,
          child: Card(
            margin: const EdgeInsets.all(8),
            child: _selectedEvent == null || _selectedShift == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('Select a shift to assign volunteers', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                      ],
                    ),
                  )
                : _buildAssignmentPanel(context, provider),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, EventsProvider provider, List<Event> myEvents) {
    if (_selectedEvent != null && _selectedShift != null) {
      return WillPopScope(
        onWillPop: () async {
          setState(() {
            _selectedEvent = null;
            _selectedShift = null;
          });
          return false;
        },
        child: Column(
          children: [
            Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        _selectedEvent = null;
                        _selectedShift = null;
                      });
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_selectedEvent!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${_selectedShift!.startTime} - ${_selectedShift!.endTime}', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildAssignmentPanel(context, provider)),
          ],
        ),
      );
    }

    return _buildEventsList(context, provider, myEvents);
  }

  Widget _buildEventsList(BuildContext context, EventsProvider provider, List<Event> myEvents) {
    return ListView.builder(
      itemCount: myEvents.length,
      itemBuilder: (context, index) {
        final Event event = myEvents[index];
        final bool isSelected = _selectedEvent?.id == event.id;

        return ExpansionTile(
          leading: Icon(Icons.event, color: isSelected ? Colors.blue : null),
          title: Text(event.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          subtitle: Text('${event.startDate} to ${event.endDate}'),
          initiallyExpanded: isSelected,
          children: event.shifts.map((shift) {
            if (!_isMyShiftOrLocation(shift, provider)) {
              return const SizedBox.shrink();
            }

            final bool shiftSelected = _selectedShift?.id == shift.id;

            final Location location = provider.locations.firstWhere(
              (l) => l.id == shift.locationId,
              orElse: () => Location(id: '', name: 'Unknown', description: '', latitude: '', longitude: ''),
            );

            return ListTile(
              selected: shiftSelected,
              leading: const Icon(Icons.schedule),
              title: Text('${shift.startTime} - ${shift.endTime}'),
              subtitle: Text('Location: ${location.name}'),
              onTap: () {
                setState(() {
                  _selectedEvent = event;
                  _selectedShift = shift;
                  _selectedLocationId = null;
                  _isMainLocation = true;
                });
                context.read<ShiftAssignmentProvider>().startListeningToEvent(event.id);
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAssignmentPanel(BuildContext context, EventsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Select Location to Assign', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Choose which location to assign your team members to:', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              const SizedBox(height: 12),
              _buildLocationDropdown(provider),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _selectedLocationId == null ? null : () => _assignVolunteersToLocation(context),
                icon: const Icon(Icons.person_add),
                label: const Text('Assign Volunteers'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), disabledBackgroundColor: Colors.grey[300]),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer<ShiftAssignmentProvider>(
              builder: (context, assignmentProvider, child) {
                if (assignmentProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final List<ShiftAssignment> assignments = assignmentProvider.assignments;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Assignments', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    Expanded(
                      child: assignments.isEmpty
                          ? Center(
                              child: Text(
                                'No volunteers assigned yet',
                                style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                              ),
                            )
                          : ListView.builder(
                              itemCount: assignments.length,
                              itemBuilder: (context, index) {
                                final ShiftAssignment assignment = assignments[index];
                                final SystemUser? volunteer = provider.systemUsers.where((u) => u.phone == assignment.volunteerId).firstOrNull;

                                String locationName = 'Main Location';
                                if (assignment.sublocationId != null) {
                                  final Location? subLoc = provider.locations.expand((loc) => loc.subLocations ?? []).where((sl) => sl.id == assignment.sublocationId).firstOrNull;
                                  locationName = subLoc?.name ?? 'Unknown Sublocation';
                                }

                                return Card(
                                  child: ListTile(
                                    leading: Icon(Icons.person, color: assignment.status == ShiftAssignmentStatus.EXCUSED ? Colors.orange : Colors.green),
                                    title: Text(volunteer?.name ?? 'Unknown'),
                                    subtitle: Text('$locationName - ${assignment.status.name}'),
                                    trailing: Text('By: ${assignment.assignedBy}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationDropdown(EventsProvider provider) {
    final Location mainLocation = provider.locations.firstWhere(
      (loc) => loc.id == _selectedShift!.locationId,
      orElse: () => Location(id: '', name: 'Unknown', description: '', latitude: '0', longitude: '0'),
    );

    // Build list of locations where current team leader's team is assigned
    List<DropdownMenuItem<String>> locationItems = [];
    Set<String> addedLocationIds = {};

    void addLocationItem(String id, String name, bool isMain) {
      if (addedLocationIds.contains(id)) return;

      locationItems.add(
        DropdownMenuItem(
          value: id,
          child: Row(
            children: [
              Icon(isMain ? Icons.location_on : Icons.subdirectory_arrow_right, size: 18, color: isMain ? Colors.blue : Colors.green),
              const SizedBox(width: 8),
              Text(isMain ? '$name (Main)' : name),
            ],
          ),
        ),
      );
      addedLocationIds.add(id);
    }

    // Check if main location has this team leader's team
    bool isMyMainTeam = false;
    if (_selectedShift!.teamId != null) {
      final team = provider.teams.where((t) => t.id == _selectedShift!.teamId).firstOrNull;
      isMyMainTeam = team != null && team.teamLeaderId == _currentUserPhone;
    } else if (_selectedShift!.tempTeam != null) {
      isMyMainTeam = _selectedShift!.tempTeam!.teamLeaderId == _currentUserPhone;
    }

    if (isMyMainTeam) {
      addLocationItem(_selectedShift!.locationId, mainLocation.name, true);
    }

    // Add sublocations where this team leader's team is assigned
    for (var subLoc in _selectedShift!.subLocations) {
      bool isMySubTeam = false;
      if (subLoc.teamId != null) {
        final team = provider.teams.where((t) => t.id == subLoc.teamId).firstOrNull;
        isMySubTeam = team != null && team.teamLeaderId == _currentUserPhone;
      } else if (subLoc.tempTeam != null) {
        isMySubTeam = subLoc.tempTeam!.teamLeaderId == _currentUserPhone;
      }

      if (isMySubTeam) {
        final Location subLocation = provider.locations
            .expand((loc) => loc.subLocations ?? [])
            .firstWhere(
              (sl) => sl.id == subLoc.subLocationId,
              orElse: () => Location(id: '', name: 'Unknown', description: '', latitude: '0', longitude: '0'),
            );

        addLocationItem(subLoc.subLocationId, subLocation.name, false);
      }
    }

    // Ensure selected value exists in items
    String? validSelectedLocationId = _selectedLocationId;
    bool valueExists = locationItems.any((item) => item.value == validSelectedLocationId);

    if (validSelectedLocationId != null && !valueExists) {
      validSelectedLocationId = null;
      // Schedule a state update to clear the invalid selection
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedLocationId != null) {
          setState(() {
            _selectedLocationId = null;
          });
        }
      });
    }

    return DropdownButtonFormField<String>(
      value: validSelectedLocationId,
      decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), labelText: 'Choose location'),
      hint: const Text('Select a location'),
      items: locationItems,
      onChanged: (value) {
        setState(() {
          _selectedLocationId = value;
          _isMainLocation = value == _selectedShift!.locationId;
        });
      },
    );
  }
}

class _VolunteerSelectionDialog extends StatefulWidget {
  final List<SystemUser> volunteers;

  const _VolunteerSelectionDialog({required this.volunteers});

  @override
  State<_VolunteerSelectionDialog> createState() => __VolunteerSelectionDialogState();
}

class __VolunteerSelectionDialogState extends State<_VolunteerSelectionDialog> {
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Select Volunteers', style: Theme.of(context).textTheme.titleLarge),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: widget.volunteers.length,
                itemBuilder: (context, index) {
                  final volunteer = widget.volunteers[index];
                  final isSelected = _selectedIds.contains(volunteer.phone);

                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedIds.add(volunteer.phone);
                        } else {
                          _selectedIds.remove(volunteer.phone);
                        }
                      });
                    },
                    title: Text(volunteer.name),
                    subtitle: Text(volunteer.phone),
                  );
                },
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Selected: ${_selectedIds.length}'),
                  Row(
                    children: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _selectedIds.isEmpty
                            ? null
                            : () {
                                final selected = widget.volunteers.where((v) => _selectedIds.contains(v.phone)).toList();
                                Navigator.of(context).pop(selected);
                              },
                        child: const Text('Assign'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
