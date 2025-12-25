import 'package:azimuth_vms/Models/VolunteerForm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../Helpers/NotificationHelperFirebase.dart';
import '../../Helpers/ShiftAssignmentHelperFirebase.dart';
import '../../Models/Event.dart';
import '../../Models/Location.dart';
import '../../Models/ShiftAssignment.dart';
import '../../Models/SystemUser.dart';
import '../../Providers/EventsProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShiftAssignmentScreen extends StatelessWidget {
  const ShiftAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventsProvider()
        ..loadEvents()
        ..loadSystemUsers()
        ..loadLocations(),
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

  void _assignVolunteersToShift(BuildContext context) async {
    if (_selectedEvent == null || _selectedShift == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an event and shift first')));
      return;
    }

    final provider = context.read<EventsProvider>();
    final volunteers = provider.volunteers.where((v) => v.volunteerForm?.status == VolunteerFormStatus.Completed).toList();

    if (volunteers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No approved volunteers available')));
      return;
    }

    // Get team members from the shift
    List<String> teamMemberIds = [];
    if (_selectedShift!.teamId != null) {
      final team = provider.teams.firstWhere((t) => t.id == _selectedShift!.teamId, orElse: () => throw Exception('Team not found'));
      teamMemberIds = team.memberIds;
    } else if (_selectedShift!.tempTeam != null) {
      teamMemberIds = _selectedShift!.tempTeam!.memberIds;
    }

    // Show volunteer selection dialog
    final selectedVolunteers = await showDialog<List<SystemUser>>(
      context: context,
      builder: (context) => _VolunteerSelectionDialog(volunteers: volunteers, preSelectedIds: teamMemberIds),
    );

    if (selectedVolunteers != null && selectedVolunteers.isNotEmpty) {
      await _createAssignments(context, selectedVolunteers, _selectedEvent!, _selectedShift!);
    }
  }

  Future<void> _createAssignments(BuildContext context, List<SystemUser> volunteers, Event event, EventShift shift) async {
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
          status: ShiftAssignmentStatus.ASSIGNED,
          assignedBy: currentUserPhone,
          timestamp: DateTime.now().toIso8601String(),
        );

        helper.CreateShiftAssignment(assignment);

        // Send notification to volunteer
        notifHelper.sendVolunteerAssignmentNotification(volunteer.phone, event.name, '${shift.startTime} - ${shift.endTime}');
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Assigned ${volunteers.length} volunteers successfully')));
      setState(() {
        _selectedEvent = null;
        _selectedShift = null;
      });
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
        title: const Text('Shift Assignment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final provider = context.read<EventsProvider>();
              provider.loadEvents();
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

          if (provider.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
            });
          }

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
                        child: Text('Select Event & Shift', style: Theme.of(context).textTheme.titleLarge),
                      ),
                      const Divider(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: provider.events.length,
                          itemBuilder: (context, index) {
                            final event = provider.events[index];
                            final isSelected = _selectedEvent?.id == event.id;

                            return ExpansionTile(
                              leading: Icon(Icons.event, color: isSelected ? Colors.blue : null),
                              title: Text(event.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                              subtitle: Text('${event.startDate} to ${event.endDate}'),
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
                                    });
                                  },
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
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
                              Text('Select an event and shift to assign volunteers', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                            ],
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_selectedEvent!.name, style: Theme.of(context).textTheme.titleLarge),
                                  const SizedBox(height: 8),
                                  Text('Shift: ${_selectedShift!.startTime} - ${_selectedShift!.endTime}', style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 4),
                                  Text('Date: ${_selectedEvent!.startDate}', style: TextStyle(color: Colors.grey[600])),
                                ],
                              ),
                            ),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: ElevatedButton.icon(
                                onPressed: () => _assignVolunteersToShift(context),
                                icon: const Icon(Icons.person_add),
                                label: const Text('Assign Volunteers'),
                                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                              ),
                            ),
                            const Divider(),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Team Assignment Info', style: Theme.of(context).textTheme.titleMedium),
                                    const SizedBox(height: 16),
                                    if (_selectedShift!.teamId != null) ...[
                                      const Text('Main Location - Permanent Team:', style: TextStyle(fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 8),
                                      _buildTeamInfo(provider, _selectedShift!.teamId!),
                                    ] else if (_selectedShift!.tempTeam != null) ...[
                                      const Text('Main Location - Temporary Team:', style: TextStyle(fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 8),
                                      _buildTempTeamInfo(provider, _selectedShift!.tempTeam!),
                                    ] else ...[
                                      Text(
                                        'No team assigned to main location',
                                        style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                                      ),
                                    ],
                                    
                                    // Show sublocation teams
                                    if (_selectedShift!.subLocations.isNotEmpty) ...[
                                      const SizedBox(height: 24),
                                      const Divider(),
                                      const SizedBox(height: 16),
                                      Text('Sub-Locations (${_selectedShift!.subLocations.length}):', style: Theme.of(context).textTheme.titleMedium),
                                      const SizedBox(height: 12),
                                      ..._selectedShift!.subLocations.map((subLoc) {
                                        final subLocation = provider.locations
                                            .expand((loc) => loc.subLocations ?? [])
                                            .firstWhere((sl) => sl.id == subLoc.subLocationId, 
                                                orElse: () => Location(id: '', name: 'Unknown', description: '', latitude: '0', longitude: '0'));
                                        
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(Icons.location_on, size: 16, color: Colors.blue),
                                                  const SizedBox(width: 4),
                                                  Text(subLocation.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              if (subLoc.teamId != null)
                                                _buildTeamInfo(provider, subLoc.teamId!)
                                              else if (subLoc.tempTeam != null)
                                                _buildTempTeamInfo(provider, subLoc.tempTeam!)
                                              else
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 20),
                                                  child: Text(
                                                    'No team assigned',
                                                    style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic, fontSize: 12),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTeamInfo(EventsProvider provider, String teamId) {
    try {
      final team = provider.teams.firstWhere((t) => t.id == teamId);

      final leader = provider.systemUsers.firstWhere(
        (u) => u.phone == team.teamLeaderId,
        orElse: () => SystemUser(id: '', name: 'Unknown', phone: team.teamLeaderId, role: SystemUserRole.TEAMLEADER),
      );

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(team.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(children: [const Icon(Icons.person, size: 16), const SizedBox(width: 4), Text('Leader: ${leader.name}')]),
              const SizedBox(height: 4),
              Row(children: [const Icon(Icons.group, size: 16), const SizedBox(width: 4), Text('Members: ${team.memberIds.length}')]),
            ],
          ),
        ),
      );
    } catch (e) {
      print('Error finding team $teamId: $e');
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  const Text('Team Not Found', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                ],
              ),
              const SizedBox(height: 8),
              Text('Team ID: $teamId', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text('This team may have been deleted or the data is inconsistent.', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildTempTeamInfo(EventsProvider provider, TempTeam tempTeam) {
    final leader = provider.systemUsers.firstWhere(
      (u) => u.phone == tempTeam.teamLeaderId,
      orElse: () => SystemUser(id: '', name: 'Unknown', phone: tempTeam.teamLeaderId, role: SystemUserRole.TEAMLEADER),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Event-Specific Team', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(children: [const Icon(Icons.person, size: 16), const SizedBox(width: 4), Text('Leader: ${leader.name}')]),
            const SizedBox(height: 4),
            Row(children: [const Icon(Icons.group, size: 16), const SizedBox(width: 4), Text('Members: ${tempTeam.memberIds.length}')]),
          ],
        ),
      ),
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
        width: MediaQuery.of(context).size.width * 0.6,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Select Volunteers', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Search', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
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
