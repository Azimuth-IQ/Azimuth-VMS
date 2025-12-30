import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Helpers/EventHelperFirebase.dart';
import '../../Helpers/LocationHelperFirebase.dart';
import '../../Helpers/SystemUserHelperFirebase.dart';
import '../../Models/ShiftAssignment.dart';
import '../../Models/Event.dart';
import '../../Models/Location.dart';
import '../../Providers/ShiftAssignmentProvider.dart';
import '../../l10n/app_localizations.dart';

class VolunteerScheduleScreen extends StatefulWidget {
  final String volunteerPhone;

  const VolunteerScheduleScreen({super.key, required this.volunteerPhone});

  @override
  State<VolunteerScheduleScreen> createState() => _VolunteerScheduleScreenState();
}

class _VolunteerScheduleScreenState extends State<VolunteerScheduleScreen> {
  final EventHelperFirebase _eventHelper = EventHelperFirebase();
  final LocationHelperFirebase _locationHelper = LocationHelperFirebase();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<String, Event> _eventCache = {};
  Map<String, Location> _locationCache = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<ShiftAssignmentProvider>();
      print('📅 Loading events for ${provider.assignments.length} assignments');

      if (provider.assignments.isEmpty) {
        print('⚠️ No assignments found in provider!');
      }

      // Load event details and locations for each assignment
      for (var assignment in provider.assignments) {
        print('📅 Processing assignment: ${assignment.eventId} for shift ${assignment.shiftId}');

        // Load event
        if (!_eventCache.containsKey(assignment.eventId)) {
          final event = await _eventHelper.GetEventById(assignment.eventId);
          if (event != null) {
            _eventCache[assignment.eventId] = event;
            print('📅 Loaded event: ${event.name} on ${event.startDate}');

            // Load location for this event's shift
            final shift = event.shifts.firstWhere((s) => s.id == assignment.shiftId, orElse: () => event.shifts.first);
            if (shift.locationId.isNotEmpty && !_locationCache.containsKey(shift.locationId)) {
              final location = await _locationHelper.GetLocationById(shift.locationId);
              if (location != null) {
                _locationCache[shift.locationId] = location;
                print('📍 Loaded location: ${location.name}');
              }
            }
          } else {
            print('⚠️ Event not found for ID: ${assignment.eventId}');
          }
        }
      }

      print('✓ Event cache contains ${_eventCache.length} events');
      print('✓ Location cache contains ${_locationCache.length} locations');
      setState(() => _isLoading = false);
    } catch (e) {
      print('❌ Error loading events: $e');
      setState(() => _isLoading = false);
    }
  }

  List<ShiftAssignment> _getAssignmentsForDay(DateTime day) {
    final provider = context.read<ShiftAssignmentProvider>();
    print('📅 Checking assignments for ${DateFormat('yyyy-MM-dd').format(day)}');
    print('📅 Total assignments: ${provider.assignments.length}');
    print('📅 Event cache size: ${_eventCache.length}');

    final assignments = provider.assignments.where((assignment) {
      final event = _eventCache[assignment.eventId];
      if (event == null) {
        print('⚠️ Event ${assignment.eventId} not in cache');
        return false;
      }

      print('📅 Checking event: ${event.name} (Recurring: ${event.isRecurring}, Type: ${event.recurrenceType})');

      // Use the event's occursOnDate method to check if it occurs on this day
      final matches = event.occursOnDate(day);
      print('📅 Event "${event.name}" occurs on ${DateFormat('yyyy-MM-dd').format(day)} = $matches');

      return matches;
    }).toList();

    print('📅 Found ${assignments.length} assignments for ${DateFormat('yyyy-MM-dd').format(day)}');
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mySchedule),
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadEvents, tooltip: l10n.refresh)],
      ),
      body: Consumer<ShiftAssignmentProvider>(
        builder: (context, provider, child) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
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
          );
        },
      ),
    );
  }

  Widget _buildAssignmentsList() {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedDay == null) {
      return Center(child: Text(l10n.selectDayToViewAssignments));
    }

    final assignments = _getAssignmentsForDay(_selectedDay!);

    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(l10n.noShiftsOn(DateFormat('MMM d, y').format(_selectedDay!)), style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final l10n = AppLocalizations.of(context)!;
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
                          child: Text(_getLocationDisplayName(shift, assignment), style: TextStyle(fontSize: 14, color: Colors.grey[700])),
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
              if (shift != null) ...[_buildDetailRow(Icons.location_on, 'Location', _getLocationDisplayName(shift, assignment)), const SizedBox(height: 16)],

              // Sublocation (already included in location display)
              // Removed redundant sublocation display

              // Assignment Date
              _buildDetailRow(Icons.calendar_today, 'Assigned On', DateFormat('MMM d, y - HH:mm').format(DateTime.parse(assignment.timestamp))),
              const SizedBox(height: 16),

              // Assigned By
              FutureBuilder<String>(
                future: _getAssignerName(assignment.assignedBy),
                builder: (context, snapshot) {
                  final assignerName = snapshot.data ?? assignment.assignedBy;
                  return _buildDetailRow(Icons.person, 'Assigned By', assignerName);
                },
              ),
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

  String _getLocationDisplayName(EventShift shift, ShiftAssignment assignment) {
    final l10n = AppLocalizations.of(context)!;

    // Get main location
    final mainLocation = _locationCache[shift.locationId];
    String locationName = mainLocation?.name ?? shift.locationId;

    // If assigned to sublocation, add sublocation name
    if (assignment.sublocationId != null && assignment.sublocationId!.isNotEmpty && mainLocation != null) {
      final sublocation = mainLocation.subLocations?.firstWhere(
        (sl) => sl.id == assignment.sublocationId,
        orElse: () => Location(id: '', name: assignment.sublocationId!, description: '', latitude: '', longitude: ''),
      );
      if (sublocation != null && sublocation.id.isNotEmpty) {
        locationName = '${mainLocation.name} - ${sublocation.name}';
      }
    }

    return locationName;
  }

  Future<String> _getAssignerName(String phone) async {
    try {
      final userHelper = SystemUserHelperFirebase();
      final user = await userHelper.GetSystemUserByPhone(phone);
      if (user != null) {
        return user.name;
      }
    } catch (e) {
      print('Error getting assigner name: $e');
    }
    return phone; // Fallback to phone if name not found
  }
}
