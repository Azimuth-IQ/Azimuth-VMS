import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../Models/AttendanceRecord.dart';
import '../../Models/Event.dart';
import '../../Models/ShiftAssignment.dart';
import '../../Providers/AttendanceProvider.dart';
import '../../Providers/EventsProvider.dart';
import '../../Providers/ShiftAssignmentProvider.dart';
import 'LocationReassignmentDialog.dart';

class PresenceCheckScreen extends StatelessWidget {
  const PresenceCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => EventsProvider()
            ..loadEvents()
            ..loadSystemUsers(),
        ),
        ChangeNotifierProvider(create: (_) => ShiftAssignmentProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
      ],
      child: const PresenceCheckView(),
    );
  }
}

class PresenceCheckView extends StatefulWidget {
  const PresenceCheckView({super.key});

  @override
  State<PresenceCheckView> createState() => _PresenceCheckViewState();
}

class _PresenceCheckViewState extends State<PresenceCheckView> with SingleTickerProviderStateMixin {
  Event? _selectedEvent;
  String? _currentUserPhone;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserPhone = user.email!.split('@').first;
      });
    }
  }

  Future<void> _markAttendance(BuildContext context, String volunteerId, String shiftId, AttendanceCheckType checkType, bool present) async {
    if (_selectedEvent == null || _currentUserPhone == null) return;

    try {
      final provider = context.read<AttendanceProvider>();

      final record = AttendanceRecord(
        id: const Uuid().v4(),
        userId: volunteerId,
        eventId: _selectedEvent!.id,
        shiftId: shiftId,
        checkType: checkType,
        timestamp: DateTime.now().toIso8601String(),
        checkedBy: _currentUserPhone!,
        present: present,
      );

      provider.createRecord(record);
    } catch (e) {
      print('Error marking attendance: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presence Check'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.directions_bus), text: 'Check 1: Departure'),
            Tab(icon: Icon(Icons.location_on), text: 'Check 2: Arrival'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<EventsProvider>().loadEvents();
              if (_selectedEvent != null) {
                context.read<ShiftAssignmentProvider>().startListeningToEvent(_selectedEvent!.id);
                context.read<AttendanceProvider>().startListeningToEvent(_selectedEvent!.id);
              }
            },
          ),
        ],
      ),
      body: Consumer<EventsProvider>(
        builder: (context, eventsProvider, child) {
          if (eventsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 900;

              if (isDesktop) {
                return Row(
                  children: [
                    // Left panel: Event selection
                    Expanded(
                      child: Card(margin: const EdgeInsets.all(8), child: _buildEventList(context, eventsProvider)),
                    ),

                    // Right panel: Attendance list
                    Expanded(
                      flex: 2,
                      child: Card(
                        margin: const EdgeInsets.all(8),
                        child: _selectedEvent == null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.how_to_reg, size: 64, color: Colors.grey[400]),
                                    const SizedBox(height: 16),
                                    Text('Select an event to start presence check', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                                  ],
                                ),
                              )
                            : TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildCheckTab(context, eventsProvider, AttendanceCheckType.DEPARTURE),
                                  _buildCheckTab(context, eventsProvider, AttendanceCheckType.ARRIVAL),
                                ],
                              ),
                      ),
                    ),
                  ],
                );
              } else {
                // Mobile Layout
                if (_selectedEvent != null) {
                  return WillPopScope(
                    onWillPop: () async {
                      setState(() {
                        _selectedEvent = null;
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
                                  });
                                },
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_selectedEvent!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(_selectedEvent!.startDate, style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildCheckTab(context, eventsProvider, AttendanceCheckType.DEPARTURE),
                              _buildCheckTab(context, eventsProvider, AttendanceCheckType.ARRIVAL),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return _buildEventList(context, eventsProvider);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildEventList(BuildContext context, EventsProvider eventsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Select Event', style: Theme.of(context).textTheme.titleLarge),
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: eventsProvider.events.length,
            itemBuilder: (context, index) {
              final event = eventsProvider.events[index];
              final isSelected = _selectedEvent?.id == event.id;

              return ListTile(
                selected: isSelected,
                leading: const Icon(Icons.event),
                title: Text(event.name),
                subtitle: Text(event.startDate),
                trailing: _buildPermissionBadge(event.presenceCheckPermissions),
                onTap: () {
                  setState(() {
                    _selectedEvent = event;
                  });
                  context.read<ShiftAssignmentProvider>().startListeningToEvent(event.id);
                  context.read<AttendanceProvider>().startListeningToEvent(event.id);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionBadge(PresenceCheckPermissions permission) {
    Color color;
    String text;

    switch (permission) {
      case PresenceCheckPermissions.ADMIN_ONLY:
        color = Colors.blue;
        text = 'Admin Only';
        break;
      case PresenceCheckPermissions.TEAMLEADER_ONLY:
        color = Colors.green;
        text = 'TL Only';
        break;
      case PresenceCheckPermissions.BOTH:
        color = Colors.orange;
        text = 'Both';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCheckTab(BuildContext context, EventsProvider eventsProvider, AttendanceCheckType checkType) {
    return Consumer2<ShiftAssignmentProvider, AttendanceProvider>(
      builder: (context, assignmentProvider, attendanceProvider, child) {
        if (assignmentProvider.isLoading || attendanceProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final assignments = assignmentProvider.assignments;

        if (assignments.isEmpty) {
          return Center(
            child: Text('No volunteers assigned to this event', style: TextStyle(color: Colors.grey[600])),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(checkType == AttendanceCheckType.DEPARTURE ? 'Departure Check (On Bus)' : 'Arrival Check (On Location)', style: Theme.of(context).textTheme.titleMedium),
                  _buildCheckStats(assignments, attendanceProvider, checkType),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: assignments.length,
                itemBuilder: (context, index) {
                  final assignment = assignments[index];
                  final volunteer = eventsProvider.systemUsers.where((u) => u.phone == assignment.volunteerId).firstOrNull;

                  if (volunteer == null) {
                    return const SizedBox.shrink();
                  }

                  final attendanceRecord = attendanceProvider.getCheckRecord(volunteer.phone, checkType, date: DateTime.now());

                  final shift = _selectedEvent!.shifts.where((s) => s.id == assignment.shiftId).firstOrNull;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: _buildStatusIcon(attendanceRecord),
                      title: Text(volunteer.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(volunteer.phone),
                          if (shift != null) Text('Shift: ${shift.startTime} - ${shift.endTime}', style: const TextStyle(fontSize: 12)),
                          if (assignment.status == ShiftAssignmentStatus.EXCUSED)
                            const Text(
                              'EXCUSED (Leave Approved)',
                              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (shift != null)
                            IconButton(
                              icon: const Icon(Icons.swap_horiz, color: Colors.blue),
                              tooltip: 'Reassign Location',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => LocationReassignmentDialog(assignment: assignment, event: _selectedEvent!, shift: shift),
                                );
                              },
                            ),
                          if (attendanceRecord != null)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  attendanceRecord.present ? 'PRESENT' : 'ABSENT',
                                  style: TextStyle(color: attendanceRecord.present ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                                ),
                                Text(DateTime.parse(attendanceRecord.timestamp).toString().split('.')[0].split(' ')[1], style: const TextStyle(fontSize: 10)),
                              ],
                            )
                          else
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: assignment.status == ShiftAssignmentStatus.EXCUSED
                                      ? null
                                      : () => _markAttendance(context, volunteer.phone, assignment.shiftId, checkType, false),
                                  icon: const Icon(Icons.close),
                                  color: Colors.red,
                                  tooltip: 'Mark Absent',
                                ),
                                IconButton(
                                  onPressed: assignment.status == ShiftAssignmentStatus.EXCUSED
                                      ? null
                                      : () => _markAttendance(context, volunteer.phone, assignment.shiftId, checkType, true),
                                  icon: const Icon(Icons.check),
                                  color: Colors.green,
                                  tooltip: 'Mark Present',
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusIcon(AttendanceRecord? record) {
    if (record == null) {
      return const Icon(Icons.radio_button_unchecked, color: Colors.grey);
    }
    return Icon(record.present ? Icons.check_circle : Icons.cancel, color: record.present ? Colors.green : Colors.red);
  }

  Widget _buildCheckStats(List<ShiftAssignment> assignments, AttendanceProvider attendanceProvider, AttendanceCheckType checkType) {
    int present = 0;
    int absent = 0;
    int notChecked = 0;
    int excused = 0;

    for (var assignment in assignments) {
      if (assignment.status == ShiftAssignmentStatus.EXCUSED) {
        excused++;
        continue;
      }

      final record = attendanceProvider.getCheckRecord(assignment.volunteerId, checkType, date: DateTime.now());

      if (record == null) {
        notChecked++;
      } else if (record.present) {
        present++;
      } else {
        absent++;
      }
    }

    return Wrap(
      spacing: 8,
      children: [
        _buildStatChip('Present', present, Colors.green),
        _buildStatChip('Absent', absent, Colors.red),
        _buildStatChip('Not Checked', notChecked, Colors.grey),
        if (excused > 0) _buildStatChip('Excused', excused, Colors.orange),
      ],
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Chip(
      label: Text('$label: $count'),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }
}
