import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../Helpers/ShiftAssignmentHelperFirebase.dart';
import '../../Helpers/EventHelperFirebase.dart';
import '../../Models/ShiftAssignment.dart';
import '../../Models/Event.dart';

class VolunteerScheduleScreen extends StatefulWidget {
  final String volunteerPhone;

  const VolunteerScheduleScreen({super.key, required this.volunteerPhone});

  @override
  State<VolunteerScheduleScreen> createState() => _VolunteerScheduleScreenState();
}

class _VolunteerScheduleScreenState extends State<VolunteerScheduleScreen> {
  final ShiftAssignmentHelperFirebase _assignmentHelper = ShiftAssignmentHelperFirebase();
  final EventHelperFirebase _eventHelper = EventHelperFirebase();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<ShiftAssignment> _allAssignments = [];
  Map<String, Event> _eventCache = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    setState(() => _isLoading = true);
    try {
      print('📅 Loading assignments for volunteer: ${widget.volunteerPhone}');
      final assignments = await _assignmentHelper.GetShiftAssignmentsByVolunteer(widget.volunteerPhone);
      print('📅 Found ${assignments.length} assignments');

      // Load event details for each assignment
      for (var assignment in assignments) {
        if (!_eventCache.containsKey(assignment.eventId)) {
          final event = await _eventHelper.GetEventById(assignment.eventId);
          if (event != null) {
            _eventCache[assignment.eventId] = event;
            print('📅 Loaded event: ${event.name} (${event.startDate})');
          } else {
            print('⚠️ Event not found: ${assignment.eventId}');
          }
        }
      }

      setState(() {
        _allAssignments = assignments;
        _isLoading = false;
      });
      print('✓ Schedule loaded successfully');
    } catch (e) {
      print('❌ Error loading assignments: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading schedule: $e')));
      }
      setState(() => _isLoading = false);
    }
  }

  List<ShiftAssignment> _getAssignmentsForDay(DateTime day) {
    final assignments = _allAssignments.where((assignment) {
      final event = _eventCache[assignment.eventId];
      if (event == null) return false;

      // Parse event start date (DD-MM-YYYY)
      final parts = event.startDate.split('-');
      if (parts.length != 3) {
        print('⚠️ Invalid date format: ${event.startDate}');
        return false;
      }

      final eventDate = DateTime(
        int.parse(parts[2]), // year
        int.parse(parts[1]), // month
        int.parse(parts[0]), // day
      );

      return isSameDay(eventDate, day);
    }).toList();

    if (assignments.isNotEmpty) {
      print('📅 Found ${assignments.length} assignments for ${DateFormat('yyyy-MM-dd').format(day)}');
    }

    return assignments;
  }

  EventShift? _getShiftForAssignment(ShiftAssignment assignment) {
    final event = _eventCache[assignment.eventId];
    if (event == null) return null;

    return event.shifts.firstWhere((shift) => shift.id == assignment.shiftId, orElse: () => event.shifts.first);
  }

  Color _getStatusColor(ShiftAssignmentStatus status) {
    switch (status) {
      case ShiftAssignmentStatus.ASSIGNED:
        return Colors.blue;
      case ShiftAssignmentStatus.EXCUSED:
        return Colors.orange;
      case ShiftAssignmentStatus.COMPLETED:
        return Colors.green;
    }
  }

  String _getStatusLabel(ShiftAssignmentStatus status) {
    switch (status) {
      case ShiftAssignmentStatus.ASSIGNED:
        return 'Assigned';
      case ShiftAssignmentStatus.EXCUSED:
        return 'Excused';
      case ShiftAssignmentStatus.COMPLETED:
        return 'Completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedule'),
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAssignments, tooltip: 'Refresh')],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Calendar
                Card(
                  margin: const EdgeInsets.all(16),
                  elevation: 2,
                  child: TableCalendar(
                    firstDay: DateTime.utc(2024, 1, 1),
                    lastDay: DateTime.utc(2026, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: _getAssignmentsForDay,
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(color: Colors.blue.withOpacity(0.3), shape: BoxShape.circle),
                      selectedDecoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                      markerDecoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      outsideDaysVisible: false,
                    ),
                    headerStyle: const HeaderStyle(formatButtonVisible: true, titleCentered: true, formatButtonShowsNext: false),
                  ),
                ),

                const SizedBox(height: 8),

                // Selected day's assignments
                Expanded(child: _buildAssignmentsList()),
              ],
            ),
    );
  }

  Widget _buildAssignmentsList() {
    if (_selectedDay == null) {
      return const Center(child: Text('Select a day to view assignments'));
    }

    final assignments = _getAssignmentsForDay(_selectedDay!);

    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No shifts on ${DateFormat('MMM d, y').format(_selectedDay!)}', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        final event = _eventCache[assignment.eventId];
        final shift = _getShiftForAssignment(assignment);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _showAssignmentDetails(assignment, event, shift),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event name
                  Row(
                    children: [
                      Icon(Icons.event, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(event?.name ?? 'Unknown Event', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: _getStatusColor(assignment.status).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          _getStatusLabel(assignment.status),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _getStatusColor(assignment.status)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Shift time
                  if (shift != null)
                    Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.grey[600], size: 16),
                        const SizedBox(width: 8),
                        Text('${shift.startTime} - ${shift.endTime}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                      ],
                    ),
                  const SizedBox(height: 8),

                  // Location
                  if (shift != null)
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Location ID: ${shift.locationId}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAssignmentDetails(ShiftAssignment assignment, Event? event, EventShift? shift) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(event?.name ?? 'Unknown Event', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 8),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: _getStatusColor(assignment.status).withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                child: Text(
                  _getStatusLabel(assignment.status),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _getStatusColor(assignment.status)),
                ),
              ),
              const SizedBox(height: 24),

              // Event Description
              if (event?.description != null && event!.description.isNotEmpty) ...[
                _buildDetailRow(Icons.description, 'Description', event.description),
                const SizedBox(height: 16),
              ],

              // Shift Time
              if (shift != null) ...[_buildDetailRow(Icons.access_time, 'Shift Time', '${shift.startTime} - ${shift.endTime}'), const SizedBox(height: 16)],

              // Location
              if (shift != null) ...[_buildDetailRow(Icons.location_on, 'Location', shift.locationId), const SizedBox(height: 16)],

              // Sublocation
              if (assignment.sublocationId != null) ...[_buildDetailRow(Icons.place, 'Sublocation', assignment.sublocationId!), const SizedBox(height: 16)],

              // Assignment Date
              _buildDetailRow(Icons.calendar_today, 'Assigned On', DateFormat('MMM d, y - HH:mm').format(DateTime.parse(assignment.timestamp))),
              const SizedBox(height: 16),

              // Assigned By
              _buildDetailRow(Icons.person, 'Assigned By', assignment.assignedBy),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
