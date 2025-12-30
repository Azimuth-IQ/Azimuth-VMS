import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../Models/Event.dart';
import '../../Models/Location.dart';
import '../../Models/ShiftAssignment.dart';
import '../../Models/SystemUser.dart';
import '../../Providers/EventsProvider.dart';
import '../../Providers/ShiftAssignmentProvider.dart';
import '../../l10n/app_localizations.dart';

class VolunteerEventDetailsScreen extends StatelessWidget {
  const VolunteerEventDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use existing providers from main.dart instead of creating new ones
    return const VolunteerEventDetailsView();
  }
}

class VolunteerEventDetailsView extends StatefulWidget {
  const VolunteerEventDetailsView({super.key});

  @override
  State<VolunteerEventDetailsView> createState() => _VolunteerEventDetailsViewState();
}

class _VolunteerEventDetailsViewState extends State<VolunteerEventDetailsView> {
  String? _currentUserPhone;

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
      context.read<ShiftAssignmentProvider>().startListeningToVolunteer(_currentUserPhone!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myEvents),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_currentUserPhone != null) {
                context.read<ShiftAssignmentProvider>().startListeningToVolunteer(_currentUserPhone!);
                context.read<EventsProvider>().loadEvents();
              }
            },
          ),
        ],
      ),
      body: Consumer2<ShiftAssignmentProvider, EventsProvider>(
        builder: (context, assignmentProvider, eventsProvider, child) {
          final l10n = AppLocalizations.of(context)!;
          if (assignmentProvider.isLoading || eventsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_currentUserPhone == null) {
            return Center(child: Text(l10n.unableToIdentifyCurrentUser));
          }

          final myAssignments = assignmentProvider.assignments;
          final theme = Theme.of(context);

          if (myAssignments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(l10n.noEventsAssignedToYou, style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: myAssignments.length,
            itemBuilder: (context, index) {
              final assignment = myAssignments[index];

              // Get event
              final event = eventsProvider.events.where((e) => e.id == assignment.eventId).firstOrNull;

              if (event == null) return const SizedBox.shrink();

              // Get shift
              final shift = event.shifts.where((s) => s.id == assignment.shiftId).firstOrNull;

              if (shift == null) return const SizedBox.shrink();

              // Get location
              final location = eventsProvider.locations.where((l) => l.id == shift.locationId).firstOrNull;

              // Get team leader
              SystemUser? teamLeader;
              if (shift.teamId != null) {
                final team = eventsProvider.teams.where((t) => t.id == shift.teamId).firstOrNull;
                if (team != null) {
                  teamLeader = eventsProvider.systemUsers.where((u) => u.phone == team.teamLeaderId).firstOrNull;
                }
              } else if (shift.tempTeam != null) {
                teamLeader = eventsProvider.systemUsers.where((u) => u.phone == shift.tempTeam!.teamLeaderId).firstOrNull;
              }

              return _EventCard(event: event, shift: shift, assignment: assignment, location: location, teamLeader: teamLeader, currentUserPhone: _currentUserPhone!);
            },
          );
        },
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  final EventShift shift;
  final ShiftAssignment assignment;
  final Location? location;
  final SystemUser? teamLeader;
  final String currentUserPhone;

  const _EventCard({required this.event, required this.shift, required this.assignment, required this.location, required this.teamLeader, required this.currentUserPhone});

  void _showMapView(BuildContext context) {
    if (location == null) return;

    // Determine which location to show
    Location targetLocation = location!;
    if (assignment.sublocationId != null && location!.subLocations != null) {
      final subloc = location!.subLocations!.where((s) => s.id == assignment.sublocationId).firstOrNull;
      if (subloc != null) {
        targetLocation = subloc;
      }
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _MapViewScreen(location: targetLocation, eventName: event.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 4,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.blue.shade600]),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.event, color: Colors.white, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(event.startDate, style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                if (assignment.status == ShiftAssignmentStatus.EXCUSED)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)),
                    child: const Text(
                      'EXCUSED',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shift info
                _buildInfoRow(context, Icons.schedule, l10n.shiftTime, '${shift.startTime} - ${shift.endTime}'),
                const SizedBox(height: 12),

                // Location info
                if (location != null) ...[
                  _buildInfoRow(
                    context,
                    Icons.location_on,
                    assignment.sublocationId != null ? l10n.sublocation : l10n.location,
                    assignment.sublocationId != null ? location!.subLocations?.where((s) => s.id == assignment.sublocationId).firstOrNull?.name ?? l10n.unknown : location!.name,
                  ),
                  const SizedBox(height: 12),
                ],

                // Team leader info
                if (teamLeader != null) ...[
                  _buildInfoRow(context, Icons.person, l10n.teamLeader, teamLeader!.name),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: Text(l10n.contactLabel(teamLeader!.phone), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ),
                  const SizedBox(height: 16),
                ],

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(onPressed: location == null ? null : () => _showMapView(context), icon: const Icon(Icons.map), label: Text(l10n.viewOnMap)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: assignment.status == ShiftAssignmentStatus.EXCUSED
                            ? null
                            : () {
                                Navigator.pushNamed(context, '/volunteer/leave-request', arguments: {'event': event, 'shift': shift, 'assignment': assignment});
                              },
                        icon: const Icon(Icons.report_problem),
                        label: Text(l10n.requestLeave),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Feedback button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/submit-event-feedback', arguments: {'event': event, 'assignment': assignment});
                    },
                    icon: const Icon(Icons.rate_review),
                    label: Text(l10n.submitEventFeedback),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
            const SizedBox(height: 2),
            Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}

class _MapViewScreen extends StatefulWidget {
  final Location location;
  final String eventName;

  const _MapViewScreen({required this.location, required this.eventName});

  @override
  State<_MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<_MapViewScreen> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    final lat = double.tryParse(widget.location.latitude) ?? 33.3152;
    final lng = double.tryParse(widget.location.longitude) ?? 44.3661;

    return Scaffold(
      appBar: AppBar(title: Text(widget.location.name)),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: LatLng(lat, lng), zoom: 15),
        markers: {
          Marker(
            markerId: MarkerId(widget.location.id),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: widget.location.name, snippet: widget.eventName),
          ),
        },
        onMapCreated: (controller) {
          _mapController = controller;
        },
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
