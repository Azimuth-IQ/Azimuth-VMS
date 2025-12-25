import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Helpers/NotificationHelperFirebase.dart';
import '../../Helpers/ShiftAssignmentHelperFirebase.dart';
import '../../Models/Event.dart';
import '../../Models/LeaveRequest.dart';
import '../../Models/ShiftAssignment.dart';
import '../../Providers/EventsProvider.dart';
import '../../Providers/LeaveRequestProvider.dart';

class LeaveRequestManagementScreen extends StatelessWidget {
  const LeaveRequestManagementScreen({super.key});

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
        ChangeNotifierProvider(create: (_) => LeaveRequestProvider()),
      ],
      child: const LeaveRequestManagementView(),
    );
  }
}

class LeaveRequestManagementView extends StatefulWidget {
  const LeaveRequestManagementView({super.key});

  @override
  State<LeaveRequestManagementView> createState() => _LeaveRequestManagementViewState();
}

class _LeaveRequestManagementViewState extends State<LeaveRequestManagementView> {
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
          if (shift.teamId != null) {
            final team = eventsProvider.teams.where((t) => t.id == shift.teamId).firstOrNull;
            if (team != null && team.teamLeaderId == _currentUserPhone) {
              return true;
            }
          }
          if (shift.tempTeam != null && shift.tempTeam!.teamLeaderId == _currentUserPhone) {
            return true;
          }
          return false;
        });
      }).toList();
    });
  }

  Future<void> _approveLeaveRequest(BuildContext context, LeaveRequest request, Event event) async {
    try {
      final leaveProvider = context.read<LeaveRequestProvider>();
      final notifHelper = NotificationHelperFirebase();
      final assignmentHelper = ShiftAssignmentHelperFirebase();

      // Update leave request status
      final updatedRequest = request.copyWith(status: LeaveRequestStatus.APPROVED, reviewedBy: _currentUserPhone, reviewedAt: DateTime.now().toIso8601String());
      leaveProvider.updateRequest(updatedRequest);

      // Update shift assignment to EXCUSED status
      final assignments = await assignmentHelper.GetShiftAssignmentsByEvent(event.id);
      final volunteerAssignment = assignments.firstWhere(
        (a) => a.volunteerId == request.volunteerId && a.shiftId == request.shiftId,
        orElse: () => throw Exception('Assignment not found'),
      );

      final updatedAssignment = volunteerAssignment.copyWith(status: ShiftAssignmentStatus.EXCUSED);
      assignmentHelper.UpdateShiftAssignment(updatedAssignment);

      // Send notification to volunteer
      notifHelper.sendLeaveApprovedNotification(request.volunteerId, event.name);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leave request approved')));
    } catch (e) {
      print('Error approving leave request: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _rejectLeaveRequest(BuildContext context, LeaveRequest request, Event event) async {
    try {
      final leaveProvider = context.read<LeaveRequestProvider>();
      final notifHelper = NotificationHelperFirebase();

      // Update leave request status
      final updatedRequest = request.copyWith(status: LeaveRequestStatus.REJECTED, reviewedBy: _currentUserPhone, reviewedAt: DateTime.now().toIso8601String());
      leaveProvider.updateRequest(updatedRequest);

      // Send notification to volunteer
      notifHelper.sendLeaveRejectedNotification(request.volunteerId, event.name);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leave request rejected')));
    } catch (e) {
      print('Error rejecting leave request: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<EventsProvider>().loadEvents();
              _filterMyEvents();
              if (_selectedEvent != null) {
                context.read<LeaveRequestProvider>().startListeningToEvent(_selectedEvent!.id);
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

                            return ListTile(
                              selected: isSelected,
                              leading: const Icon(Icons.event),
                              title: Text(event.name),
                              subtitle: Text('${event.startDate} to ${event.endDate}'),
                              onTap: () {
                                setState(() {
                                  _selectedEvent = event;
                                });
                                context.read<LeaveRequestProvider>().startListeningToPendingRequests(event.id);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Right panel: Leave requests
              Expanded(
                flex: 2,
                child: Card(
                  margin: const EdgeInsets.all(8),
                  child: _selectedEvent == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.assignment_late, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text('Select an event to view leave requests', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                            ],
                          ),
                        )
                      : Consumer<LeaveRequestProvider>(
                          builder: (context, leaveProvider, child) {
                            if (leaveProvider.isLoading) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final pendingRequests = leaveProvider.pendingRequests;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Text('Pending Leave Requests', style: Theme.of(context).textTheme.titleLarge),
                                      const SizedBox(width: 8),
                                      if (pendingRequests.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)),
                                          child: Text(
                                            '${pendingRequests.length}',
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const Divider(),
                                Expanded(
                                  child: pendingRequests.isEmpty
                                      ? Center(
                                          child: Text('No pending leave requests', style: TextStyle(color: Colors.grey[600])),
                                        )
                                      : ListView.builder(
                                          itemCount: pendingRequests.length,
                                          itemBuilder: (context, index) {
                                            final request = pendingRequests[index];
                                            final volunteer = eventsProvider.systemUsers.where((u) => u.phone == request.volunteerId).firstOrNull;

                                            // Get shift info
                                            final shift = _selectedEvent!.shifts.where((s) => s.id == request.shiftId).firstOrNull;

                                            return Card(
                                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              child: Padding(
                                                padding: const EdgeInsets.all(16),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Icon(Icons.person, size: 20),
                                                        const SizedBox(width: 8),
                                                        Text(volunteer?.name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    if (shift != null) ...[
                                                      Row(
                                                        children: [
                                                          const Icon(Icons.schedule, size: 16),
                                                          const SizedBox(width: 8),
                                                          Text('Shift: ${shift.startTime} - ${shift.endTime}'),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 4),
                                                    ],
                                                    Row(
                                                      children: [
                                                        const Icon(Icons.event, size: 16),
                                                        const SizedBox(width: 8),
                                                        Text('Requested: ${DateTime.parse(request.requestedAt).toString().split('.')[0]}'),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Text('Reason:', style: const TextStyle(fontWeight: FontWeight.bold)),
                                                    const SizedBox(height: 4),
                                                    Text(request.reason),
                                                    const SizedBox(height: 16),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        TextButton.icon(
                                                          onPressed: () => _rejectLeaveRequest(context, request, _selectedEvent!),
                                                          icon: const Icon(Icons.close, color: Colors.red),
                                                          label: const Text('Reject', style: TextStyle(color: Colors.red)),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        ElevatedButton.icon(
                                                          onPressed: () => _approveLeaveRequest(context, request, _selectedEvent!),
                                                          icon: const Icon(Icons.check),
                                                          label: const Text('Approve'),
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
