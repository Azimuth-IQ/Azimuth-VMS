import 'package:azimuth_vms/Models/VolunteerForm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../l10n/app_localizations.dart';
import '../../Helpers/NotificationHelperFirebase.dart';
import '../../Helpers/ShiftAssignmentHelperFirebase.dart';
import '../../Models/Event.dart';
import '../../Models/Location.dart';
import '../../Models/ShiftAssignment.dart';
import '../../Models/SystemUser.dart';
import '../../Providers/EventsProvider.dart';
import '../../Providers/ShiftAssignmentProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShiftAssignmentScreen extends StatelessWidget {
  const ShiftAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => EventsProvider()
            ..loadEvents()
            ..loadSystemUsers()
            ..loadLocations()
            ..loadTeams(),
        ),
        ChangeNotifierProvider(create: (_) => ShiftAssignmentProvider()),
      ],
      child: const ShiftAssignmentView(),
    );
  }
}

class ShiftAssignmentView extends StatefulWidget {
  const ShiftAssignmentView({super.key});

  @override
  State<ShiftAssignmentView> createState() => _ShiftAssignmentViewState();
}

class _ShiftAssignmentViewState extends State<ShiftAssignmentView> {
  Event? _selectedEvent;
  EventShift? _selectedShift;
  String? _selectedLocationId; // Can be main locationId or sublocationId
  bool _isMainLocation = true; // Track if it's main location or sublocation

  void _assignVolunteersToLocation(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedEvent == null || _selectedShift == null || _selectedLocationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectEventShiftAndLocationFirst)));
      return;
    }

    final provider = context.read<EventsProvider>();
    print('Total volunteers loaded: ${provider.volunteers.length}');
    List<SystemUser> volunteers = [];
    for (var vol in provider.volunteers) {
      if (vol.volunteerForm == null) {
        print('⚠️ Volunteer ${vol.name} (${vol.phone}) has no volunteer form attached - skipping');
        continue;
      }
      print('✓ Volunteer: ${vol.name}, Status: ${vol.volunteerForm!.status.toString()}');
      if (vol.volunteerForm!.status == VolunteerFormStatus.Approved1 ||
          vol.volunteerForm!.status == VolunteerFormStatus.Approved2 ||
          vol.volunteerForm!.status == VolunteerFormStatus.Completed) {
        volunteers.add(vol);
      }
    }

    if (volunteers.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.noApprovedVolunteersAvailable)));
      return;
    }

    // Get team members based on selected location (main or sublocation)
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
      final subLoc = _selectedShift!.subLocations.firstWhere((sl) => sl.subLocationId == _selectedLocationId);
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

    // Show volunteer selection dialog
    final selectedVolunteers = await showDialog<List<SystemUser>>(
      context: context,
      builder: (context) => _VolunteerSelectionDialog(volunteers: volunteers, preSelectedIds: teamMemberIds),
    );

    if (selectedVolunteers != null && selectedVolunteers.isNotEmpty) {
      await _createAssignments(context, selectedVolunteers, _selectedEvent!, _selectedShift!, _isMainLocation ? null : _selectedLocationId);
    }
  }

  Future<void> _createAssignments(BuildContext context, List<SystemUser> volunteers, Event event, EventShift shift, String? sublocationId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final currentUserPhone = user?.email?.split('@').first ?? '';
      final helper = ShiftAssignmentHelperFirebase();
      final notifHelper = NotificationHelperFirebase();

      for (var volunteer in volunteers) {
        final assignment = ShiftAssignment(
          id: const Uuid().v4(),
          volunteerId: volunteer.phone,
          shiftId: shift.id,
          eventId: event.id,
          sublocationId: sublocationId, // Include sublocation if selected
          status: ShiftAssignmentStatus.ASSIGNED,
          assignedBy: currentUserPhone,
          timestamp: DateTime.now().toIso8601String(),
        );

        helper.CreateShiftAssignment(assignment);

        // Send notification to volunteer with location info
        final locationInfo = sublocationId != null ? ' (Sublocation)' : '';
        notifHelper.sendVolunteerAssignmentNotification(volunteer.phone, event.name, '${shift.startTime} - ${shift.endTime}$locationInfo');
      }

      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final message = sublocationId != null ? l10n.assignedVolunteersToSubLocation(volunteers.length) : l10n.assignedVolunteersSuccessfully(volunteers.length);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      setState(() {
        _selectedLocationId = null;
        _isMainLocation = true;
      });
    } catch (e) {
      print('Error creating assignments: $e');
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorCreatingAssignments(e.toString()))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shiftAssignment),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final provider = context.read<EventsProvider>();
              provider.loadEvents();
              provider.loadSystemUsers();
              provider.loadTeams();
            },
          ),
        ],
      ),
      body: Consumer<EventsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
            });
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 900;

              if (isDesktop) {
                return _buildDesktopLayout(context, provider);
              } else {
                return _buildMobileLayout(context, provider);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, EventsProvider provider) {
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
                  child: Text(AppLocalizations.of(context)!.selectEventAndShift, style: Theme.of(context).textTheme.titleLarge),
                ),
                const Divider(),
                Expanded(child: _buildEventsList(context, provider)),
              ],
            ),
          ),
        ),

        // Right panel: Assignment details
        Expanded(
          flex: 3,
          child: Card(
            margin: const EdgeInsets.all(8),
            child: _selectedEvent == null || _selectedShift == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(AppLocalizations.of(context)!.selectAnEventAndShiftToAssignVolunteers, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                      ],
                    ),
                  )
                : _buildAssignmentPanel(context, provider),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, EventsProvider provider) {
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

    return _buildEventsList(context, provider);
  }

  Widget _buildEventsList(BuildContext context, EventsProvider provider) {
    return ListView.builder(
      itemCount: provider.events.length,
      itemBuilder: (context, index) {
        final event = provider.events[index];
        final isSelected = _selectedEvent?.id == event.id;

        return ExpansionTile(
          leading: Icon(Icons.event, color: isSelected ? Colors.blue : null),
          title: Text(event.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          subtitle: Text('${event.startDate} to ${event.endDate}'),
          initiallyExpanded: isSelected,
          children: event.shifts.map((shift) {
            final shiftSelected = _selectedShift?.id == shift.id;

            // Get location name
            final location = provider.locations.firstWhere(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_selectedEvent!.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('${AppLocalizations.of(context)!.shift}: ${_selectedShift!.startTime} - ${_selectedShift!.endTime}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('${AppLocalizations.of(context)!.date}: ${_selectedEvent!.startDate}', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppLocalizations.of(context)!.selectLocation, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Consumer<EventsProvider>(
                builder: (context, provider, child) {
                  // Build location options
                  final mainLocation = provider.locations.firstWhere(
                    (loc) => loc.id == _selectedShift!.locationId,
                    orElse: () => Location(id: '', name: 'Unknown', description: '', latitude: '0', longitude: '0'),
                  );

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
                            Text(isMain ? '$name ${AppLocalizations.of(context)!.mainSuffix}' : name),
                          ],
                        ),
                      ),
                    );
                    addedLocationIds.add(id);
                  }

                  // Main location
                  addLocationItem(_selectedShift!.locationId, mainLocation.name, true);

                  // Sublocations
                  for (var subLoc in _selectedShift!.subLocations) {
                    final subLocation = provider.locations
                        .expand((loc) => loc.subLocations ?? [])
                        .firstWhere(
                          (sl) => sl.id == subLoc.subLocationId,
                          orElse: () => Location(id: '', name: 'Unknown', description: '', latitude: '0', longitude: '0'),
                        );
                    addLocationItem(subLoc.subLocationId, subLocation.name, false);
                  }

                  // Ensure selected value exists in items
                  String? validSelectedLocationId = _selectedLocationId;
                  bool valueExists = locationItems.any((item) => item.value == validSelectedLocationId);

                  if (validSelectedLocationId != null && !valueExists) {
                    validSelectedLocationId = null;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _selectedLocationId != null) {
                        setState(() {
                          _selectedLocationId = null;
                        });
                      }
                    });
                  }

                  return DropdownButtonFormField<String>(
                    initialValue: validSelectedLocationId,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      labelText: AppLocalizations.of(context)!.chooseLocationToAssignVolunteers,
                    ),
                    hint: Text(AppLocalizations.of(context)!.selectALocation),
                    items: locationItems,
                    onChanged: (value) {
                      setState(() {
                        _selectedLocationId = value;
                        _isMainLocation = value == _selectedShift!.locationId;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _selectedLocationId == null ? null : () => _assignVolunteersToLocation(context),
                icon: const Icon(Icons.person_add),
                label: Text(AppLocalizations.of(context)!.assignVolunteersToLocation),
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
                final assignments = assignmentProvider.assignments;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.currentAssignments, style: Theme.of(context).textTheme.titleMedium),
                        if (assignments.isNotEmpty) Chip(label: Text('${assignments.length} ${AppLocalizations.of(context)!.assigned}'), backgroundColor: Colors.green.shade100),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: assignments.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text(
                                    AppLocalizations.of(context)!.noVolunteersAssignedYet,
                                    style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(AppLocalizations.of(context)!.teamLeadersShouldAssignFirst, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: assignments.length,
                              itemBuilder: (context, index) {
                                final assignment = assignments[index];
                                final volunteer = provider.systemUsers.where((u) => u.phone == assignment.volunteerId).firstOrNull;

                                // Get location name
                                String locationName = AppLocalizations.of(context)!.mainLocation;
                                if (assignment.sublocationId != null) {
                                  final subLoc = provider.locations.expand((loc) => loc.subLocations ?? []).where((sl) => sl.id == assignment.sublocationId).firstOrNull;
                                  locationName = subLoc?.name ?? AppLocalizations.of(context)!.unknownSubLocation;
                                }

                                // Determine who assigned
                                final assignedByUser = provider.systemUsers.where((u) => u.phone == assignment.assignedBy).firstOrNull;
                                final isTeamLeader = assignedByUser?.role == SystemUserRole.TEAMLEADER;

                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: Icon(Icons.person, color: assignment.status == ShiftAssignmentStatus.EXCUSED ? Colors.orange : Colors.green),
                                    title: Text(volunteer?.name ?? 'Unknown'),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(locationName),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(isTeamLeader ? Icons.badge : Icons.admin_panel_settings, size: 12, color: isTeamLeader ? Colors.blue : Colors.purple),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${AppLocalizations.of(context)!.by} ${assignedByUser?.name ?? assignment.assignedBy}',
                                              style: TextStyle(fontSize: 11, color: isTeamLeader ? Colors.blue : Colors.purple, fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: Chip(
                                      label: Text(assignment.status.name, style: const TextStyle(fontSize: 11)),
                                      backgroundColor: assignment.status == ShiftAssignmentStatus.EXCUSED ? Colors.orange.shade100 : Colors.green.shade100,
                                    ),
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
}

class _VolunteerSelectionDialog extends StatefulWidget {
  final List<SystemUser> volunteers;
  final List<String> preSelectedIds;

  const _VolunteerSelectionDialog({required this.volunteers, required this.preSelectedIds});

  @override
  State<_VolunteerSelectionDialog> createState() => __VolunteerSelectionDialogState();
}

class __VolunteerSelectionDialogState extends State<_VolunteerSelectionDialog> {
  final Set<String> _selectedIds = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedIds.addAll(widget.preSelectedIds);
  }

  @override
  Widget build(BuildContext context) {
    final filteredVolunteers = widget.volunteers.where((v) {
      return v.name.toLowerCase().contains(_searchQuery.toLowerCase()) || v.phone.contains(_searchQuery);
    }).toList();

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width > 600 ? 600 : MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(AppLocalizations.of(context)!.selectVolunteers, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.search, prefixIcon: const Icon(Icons.search), border: const OutlineInputBorder()),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: filteredVolunteers.length,
                itemBuilder: (context, index) {
                  final volunteer = filteredVolunteers[index];
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
                    secondary: const Icon(Icons.person),
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
                  Text(AppLocalizations.of(context)!.selectedCount(_selectedIds.length)),
                  Row(
                    children: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(AppLocalizations.of(context)!.cancel)),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _selectedIds.isEmpty
                            ? null
                            : () {
                                final selected = widget.volunteers.where((v) => _selectedIds.contains(v.phone)).toList();
                                Navigator.of(context).pop(selected);
                              },
                        child: Text(AppLocalizations.of(context)!.assign),
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
