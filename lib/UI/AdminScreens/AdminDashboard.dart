import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../Providers/EventsProvider.dart';
import '../../Models/Event.dart';
import '../../Models/Location.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/sign-in');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.blue.shade600], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(user?.email?.split('@').first ?? 'Admin', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Active Events Section
            const Text(
              'Active Events',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36)),
            ),

            const SizedBox(height: 16),

            _buildActiveEventsCard(context),

            const SizedBox(height: 32),

            const Text(
              'Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36)),
            ),

            const SizedBox(height: 16),

            // Management Cards Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 800
                    ? 3
                    : constraints.maxWidth > 500
                    ? 2
                    : 1;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                  children: [
                    _buildManagementCard(
                      context,
                      title: 'Events',
                      subtitle: 'Manage events and schedules',
                      icon: Icons.event,
                      color: Colors.purple,
                      onTap: () => Navigator.pushNamed(context, '/event-mgmt'),
                    ),
                    _buildManagementCard(
                      context,
                      title: 'Volunteers',
                      subtitle: 'Manage volunteer profiles',
                      icon: Icons.volunteer_activism,
                      color: Colors.teal,
                      onTap: () => Navigator.pushNamed(context, '/volunteers-mgmt'),
                    ),
                    _buildManagementCard(
                      context,
                      title: 'Team Leaders',
                      subtitle: 'Manage team leader profiles',
                      icon: Icons.person_pin_circle,
                      color: Colors.indigo,
                      onTap: () => Navigator.pushNamed(context, '/team-leaders-mgmt'),
                    ),
                    _buildManagementCard(
                      context,
                      title: 'Locations',
                      subtitle: 'Manage locations and zones',
                      icon: Icons.location_on,
                      color: Colors.orange,
                      onTap: () => Navigator.pushNamed(context, '/locations-mgmt'),
                    ),
                    _buildManagementCard(
                      context,
                      title: 'Teams',
                      subtitle: 'Manage teams and members',
                      icon: Icons.groups,
                      color: Colors.green,
                      onTap: () => Navigator.pushNamed(context, '/teams-mgmt'),
                    ),
                    _buildManagementCard(
                      context,
                      title: 'Volunteer Forms',
                      subtitle: 'Manage volunteer forms',
                      icon: Icons.description,
                      color: Colors.red,
                      onTap: () => Navigator.pushNamed(context, '/form-mgmt'),
                    ),
                    _buildManagementCard(
                      context,
                      title: 'Shift Assignment',
                      subtitle: 'Assign volunteers to shifts',
                      icon: Icons.assignment,
                      color: Colors.blue,
                      onTap: () => Navigator.pushNamed(context, '/shift-assignment'),
                    ),
                    _buildManagementCard(
                      context,
                      title: 'Presence Checks',
                      subtitle: 'Check volunteer attendance',
                      icon: Icons.how_to_reg,
                      color: Colors.pink,
                      onTap: () => Navigator.pushNamed(context, '/presence-check-admin'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36)),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveEventsCard(BuildContext context) {
    return Consumer<EventsProvider>(
      builder: (context, eventsProvider, _) {
        // Load events and system users if not already loaded
        if (eventsProvider.events.isEmpty && !eventsProvider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            eventsProvider.loadEvents();
            eventsProvider.loadSystemUsers();
            eventsProvider.loadLocations();
            eventsProvider.loadTeams();
          });
        }

        // Filter for active events (today's events)
        final today = DateFormat('dd-MM-yyyy').format(DateTime.now());
        print('Today\'s date for filtering: $today');
        print('Total events loaded: ${eventsProvider.events.length}');

        final activeEvents = eventsProvider.events.where((event) {
          print('Event: ${event.name}, Start Date: ${event.startDate}');
          return today.compareTo(event.endDate) <= 0;
        }).toList();

        print('Active events found: ${activeEvents.length}');

        if (activeEvents.isEmpty) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No Active Events',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: activeEvents.map((event) {
              // Get location info from first shift (if exists)
              final firstShift = event.shifts.isNotEmpty ? event.shifts.first : null;
              final locationId = firstShift?.locationId ?? '';

              // Find the actual location to get coordinates
              final location = eventsProvider.locations.firstWhere(
                (loc) => loc.id == locationId,
                orElse: () => eventsProvider.locations.isNotEmpty
                    ? eventsProvider.locations.first
                    : Location(id: '', name: 'Unknown', description: '', latitude: '33.3152', longitude: '44.3661', subLocations: []),
              );

              final locationName = location.name;
              final subLocationName = firstShift?.subLocations.isNotEmpty == true ? firstShift!.subLocations.first.subLocationId : 'No sublocation';
              final lat = double.tryParse(location.latitude) ?? 33.3152;
              final lng = double.tryParse(location.longitude) ?? 44.3661;

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.event, color: Colors.purple, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36)),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text('$locationName - $subLocationName', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Active',
                                style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Map and Teams Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Map View
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(target: LatLng(lat, lng), zoom: 14),
                              markers: {
                                Marker(
                                  markerId: const MarkerId('event_location'),
                                  position: LatLng(lat, lng),
                                  infoWindow: InfoWindow(title: event.name, snippet: subLocationName),
                                ),
                              },
                              zoomControlsEnabled: false,
                              mapToolbarEnabled: false,
                              myLocationButtonEnabled: false,
                              liteModeEnabled: true,
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Assigned Teams
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 200,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.groups, size: 16, color: Colors.grey[700]),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Assigned Teams',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Expanded(child: _buildTeamsList(event, eventsProvider)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildTeamsList(Event event, EventsProvider eventsProvider) {
    // Collect all teams and temp teams from all shifts
    final teamsList = <Widget>[];

    for (final shift in event.shifts) {
      for (final sublocation in shift.subLocations) {
        if (sublocation.teamId != null) {
          // Regular team - find the team first, then its leader
          try {
            final team = eventsProvider.teams.firstWhere((t) => t.id == sublocation.teamId);
            final teamLeader = eventsProvider.teamLeaders.firstWhere((tl) => tl.phone == team.teamLeaderId);

            teamsList.add(_buildTeamCard(teamName: team.name, leaderName: teamLeader.name, memberCount: team.memberIds.length));
          } catch (e) {
            print('Error finding team or leader: $e');
            teamsList.add(_buildTeamCard(teamName: 'Team ${sublocation.teamId}', leaderName: 'Unknown', memberCount: 0));
          }
        } else if (sublocation.tempTeam != null) {
          // Temp team - find team leader and volunteers
          try {
            final teamLeader = eventsProvider.teamLeaders.firstWhere((tl) => tl.phone == sublocation.tempTeam!.teamLeaderId);

            // Get volunteer names
            final volunteers = <String>[];
            for (final memberId in sublocation.tempTeam!.memberIds) {
              try {
                final volunteer = eventsProvider.volunteers.firstWhere((v) => v.phone == memberId);
                volunteers.add(volunteer.name);
              } catch (e) {
                volunteers.add('Unknown');
              }
            }

            teamsList.add(_buildTeamCard(teamName: 'Temp Team', leaderName: teamLeader.name, memberCount: sublocation.tempTeam!.memberIds.length, volunteers: volunteers));
          } catch (e) {
            print('Error finding temp team leader: $e');
            teamsList.add(_buildTeamCard(teamName: 'Temp Team', leaderName: 'Unknown', memberCount: sublocation.tempTeam!.memberIds.length));
          }
        }
      }
    }

    if (teamsList.isEmpty) {
      return Center(
        child: Text('No teams assigned', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      );
    }

    return ListView(children: teamsList);
  }

  Widget _buildTeamCard({required String teamName, required String leaderName, required int memberCount, List<String>? volunteers}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.groups, size: 14, color: Colors.green),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    teamName,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36)),
                  ),
                ),
                if (memberCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      '$memberCount',
                      style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.person_pin_circle, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(leaderName, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ),
              ],
            ),
            if (volunteers != null && volunteers.isNotEmpty) ...[
              const SizedBox(height: 6),
              ...volunteers.map(
                (volunteer) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 2),
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 10, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(volunteer, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
