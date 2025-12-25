import 'package:azimuth_vms/Models/VolunteerForm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Helpers/NotificationHelperFirebase.dart';
import '../../Helpers/ShiftAssignmentHelperFirebase.dart';
import '../../Models/Event.dart';
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
            ..loadSystemUsers(),
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
  List<Event> _myEvents = [];
  Event? _selectedEvent;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserPhone = user.email!.split('@').first;
      });
      _filterMyEvents();
    }
  }

  void _filterMyEvents() {
    if (_currentUserPhone == null) return;

    final eventsProvider = context.read<EventsProvider>();
    setState(() {
      _myEvents = eventsProvider.events.where((event) {
        return event.shifts.any((shift) {
          // Check permanent team
          if (shift.teamId != null) {
            final team = eventsProvider.teams.where((t) => t.id == shift.teamId).firstOrNull;
            if (team != null && team.teamLeaderId == _currentUserPhone) {
              return true;
            }
          }
          // Check temp team
          if (shift.tempTeam != null && shift.tempTeam!.teamLeaderId == _currentUserPhone) {
            return true;
          }
          return false;
        });
      }).toList();
    });
  }

  void _assignVolunteersToShift(BuildContext context, Event event, EventShift shift) async {
    final eventsProvider = context.read<EventsProvider>();

    // Get team members for this shift
    List<String> teamMemberIds = [];
    if (shift.teamId != null) {
      final team = eventsProvider.teams.firstWhere((t) => t.id == shift.teamId);
      teamMemberIds = team.memberIds;
    } else if (shift.tempTeam != null) {
      teamMemberIds = shift.tempTeam!.memberIds;
    }

    // Filter volunteers from team members
    final volunteers = eventsProvider.systemUsers
        .where((u) => teamMemberIds.contains(u.phone) && u.role == SystemUserRole.VOLUNTEER && u.volunteerForm?.status == VolunteerFormStatus.Completed)
        .toList();

    if (volunteers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No volunteers available in your team')));
      return;
    }

    // Show selection dialog
    final selectedVolunteers = await showDialog<List<SystemUser>>(
      context: context,
      builder: (context) => _VolunteerSelectionDialog(volunteers: volunteers),
    );

    if (selectedVolunteers != null && selectedVolunteers.isNotEmpty) {
      await _createAssignments(context, selectedVolunteers, event, shift);
    }
  }

  Future<void> _createAssignments(BuildContext context, List<SystemUser> volunteers, Event event, EventShift shift) async {
    try {
      final helper = ShiftAssignmentHelperFirebase();
      final notifHelper = NotificationHelperFirebase();

      for (var volunteer in volunteers) {
        final assignment = ShiftAssignment(
          id: const Uuid().v4(),
          volunteerId: volunteer.phone,
          shiftId: shift.id,
          eventId: event.id,
          status: ShiftAssignmentStatus.ASSIGNED,
          assignedBy: _currentUserPhone!,
          timestamp: DateTime.now().toIso8601String(),
        );

        helper.CreateShiftAssignment(assignment);

        // Send notification
        notifHelper.sendVolunteerAssignmentNotification(volunteer.phone, event.name, '${shift.startTime} - ${shift.endTime}');
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Assigned ${volunteers.length} volunteers successfully')));

      // Reload assignments
      if (_selectedEvent != null) {
        context.read<ShiftAssignmentProvider>().startListeningToEvent(_selectedEvent!.id);
      }
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
        title: const Text('Manage Event Assignments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<EventsProvider>().loadEvents();
              _filterMyEvents();
            },
          ),
        ],
      ),
      body: Consumer<EventsProvider>(
        builder: (context, eventsProvider, child) {
          if (eventsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_currentUserPhone == null) {
            return const Center(child: Text('Unable to identify current user'));
          }

          if (_myEvents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No events assigned to your teams', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                ],
              ),
            );
          }

          return Row(
            children: [
              // Left panel: Events list
              Expanded(
                flex: 2,
                child: Card(
                  margin: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('My Events', style: Theme.of(context).textTheme.titleLarge),
                      ),
                      const Divider(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _myEvents.length,
                          itemBuilder: (context, index) {
                            final event = _myEvents[index];
                            final isSelected = _selectedEvent?.id == event.id;

                            return ExpansionTile(
                              leading: Icon(Icons.event, color: isSelected ? Colors.blue : null),
                              title: Text(event.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                              subtitle: Text('${event.startDate} to ${event.endDate}'),
                              onExpansionChanged: (expanded) {
                                if (expanded) {
                                  setState(() {
                                    _selectedEvent = event;
                                  });
                                  context.read<ShiftAssignmentProvider>().startListeningToEvent(event.id);
                                }
                              },
                              children: event.shifts.map((shift) {
                                // Only show shifts assigned to this team leader
                                bool isMyShift = false;
                                if (shift.teamId != null) {
                                  final team = eventsProvider.teams.where((t) => t.id == shift.teamId).firstOrNull;
                                  isMyShift = team != null && team.teamLeaderId == _currentUserPhone;
                                } else if (shift.tempTeam != null) {
                                  isMyShift = shift.tempTeam!.teamLeaderId == _currentUserPhone;
                                }

                                if (!isMyShift) return const SizedBox.shrink();

                                return ListTile(
                                  leading: const Icon(Icons.schedule),
                                  title: Text('${shift.startTime} - ${shift.endTime}'),
                                  trailing: ElevatedButton.icon(
                                    onPressed: () => _assignVolunteersToShift(context, event, shift),
                                    icon: const Icon(Icons.person_add, size: 16),
                                    label: const Text('Assign'),
                                  ),
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

              // Right panel: Assigned volunteers
              Expanded(
                flex: 3,
                child: Card(
                  margin: const EdgeInsets.all(8),
                  child: _selectedEvent == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text('Select an event to view assignments', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                            ],
                          ),
                        )
                      : Consumer<ShiftAssignmentProvider>(
                          builder: (context, assignmentProvider, child) {
                            if (assignmentProvider.isLoading) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final assignments = assignmentProvider.assignments;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text('Assigned Volunteers', style: Theme.of(context).textTheme.titleLarge),
                                ),
                                const Divider(),
                                Expanded(
                                  child: assignments.isEmpty
                                      ? Center(
                                          child: Text('No volunteers assigned yet', style: TextStyle(color: Colors.grey[600])),
                                        )
                                      : ListView.builder(
                                          itemCount: assignments.length,
                                          itemBuilder: (context, index) {
                                            final assignment = assignments[index];
                                            final volunteer = eventsProvider.systemUsers.where((u) => u.phone == assignment.volunteerId).firstOrNull;

                                            return ListTile(
                                              leading: Icon(Icons.person, color: assignment.status == ShiftAssignmentStatus.EXCUSED ? Colors.orange : Colors.green),
                                              title: Text(volunteer?.name ?? 'Unknown'),
                                              subtitle: Text('${volunteer?.phone ?? ''} - ${assignment.status.name}'),
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
        },
      ),
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
