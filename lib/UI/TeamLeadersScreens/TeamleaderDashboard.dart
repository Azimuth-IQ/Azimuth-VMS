import 'package:azimuth_vms/Helpers/EventHelperFirebase.dart';
import 'package:azimuth_vms/Helpers/SystemUserHelperFirebase.dart';
import 'package:azimuth_vms/Helpers/TeamHelperFirebase.dart';
import 'package:azimuth_vms/Models/Event.dart';
import 'package:azimuth_vms/Models/SystemUser.dart';
import 'package:azimuth_vms/Models/Team.dart';
import 'package:azimuth_vms/UI/Widgets/ChangePasswordScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TeamleaderDashboard extends StatefulWidget {
  const TeamleaderDashboard({super.key});

  @override
  State<TeamleaderDashboard> createState() => _TeamleaderDashboardState();
}

class _TeamleaderDashboardState extends State<TeamleaderDashboard> {
  final EventHelperFirebase _eventHelper = EventHelperFirebase();
  final TeamHelperFirebase _teamHelper = TeamHelperFirebase();
  final SystemUserHelperFirebase _userHelper = SystemUserHelperFirebase();

  List<Event> _myEvents = [];
  List<Team> _myTeams = [];
  List<SystemUser> _volunteers = [];
  String? _currentUserPhone;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Get current user phone
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      _currentUserPhone = user.email!.split('@').first;

      // Load all volunteers
      final allUsers = await _userHelper.GetAllSystemUsers();
      _volunteers = allUsers.where((u) => u.role == SystemUserRole.VOLUNTEER).toList();

      // Load teams where current user is the team leader
      final allTeams = await _teamHelper.GetAllTeams();
      _myTeams = allTeams.where((team) => team.teamLeaderId == _currentUserPhone).toList();

      // Load all events
      final allEvents = await _eventHelper.GetAllEvents();

      // Filter events where my teams are assigned
      _myEvents = allEvents.where((event) {
        return event.shifts.any((shift) {
          // Check if my team is assigned to main shift
          if (shift.teamId != null && _myTeams.any((team) => team.id == shift.teamId)) {
            return true;
          }
          // Check if my team is assigned to any sublocation
          if (shift.subLocations.any((subLoc) => subLoc.teamId != null && _myTeams.any((team) => team.id == subLoc.teamId))) {
            return true;
          }
          // Check if I'm the leader of a temp team in main shift
          if (shift.tempTeam != null && shift.tempTeam!.teamLeaderId == _currentUserPhone) {
            return true;
          }
          // Check if I'm the leader of a temp team in any sublocation
          if (shift.subLocations.any((subLoc) => subLoc.tempTeam != null && subLoc.tempTeam!.teamLeaderId == _currentUserPhone)) {
            return true;
          }
          return false;
        });
      }).toList();

      setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading team leader data: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  void _showEventDetails(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventAssignmentPage(event: event, myTeams: _myTeams, volunteers: _volunteers, currentUserPhone: _currentUserPhone!, onUpdate: () => _loadData()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Team Leader Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) {
              if (value == 'change_password') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordScreen(userPhone: _currentUserPhone ?? '')));
              } else if (value == 'logout') {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/sign-in');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'change_password',
                child: Row(children: [Icon(Icons.lock_reset, size: 20), SizedBox(width: 8), Text('Change Password')]),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(children: [Icon(Icons.logout, size: 20), SizedBox(width: 8), Text('Sign Out')]),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Management Section
                  const Text(
                    'Management',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36)),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
                    children: [
                      _buildManagementCard(
                        context,
                        title: 'Manage Shifts',
                        subtitle: 'Assign volunteers to shifts',
                        icon: Icons.assignment,
                        color: Colors.blue,
                        onTap: () => Navigator.pushNamed(context, '/teamleader-shift-management'),
                      ),
                      _buildManagementCard(
                        context,
                        title: 'Leave Requests',
                        subtitle: 'Review volunteer leave requests',
                        icon: Icons.report_problem,
                        color: Colors.orange,
                        onTap: () => Navigator.pushNamed(context, '/leave-request-management'),
                      ),
                      _buildManagementCard(
                        context,
                        title: 'Presence Checks',
                        subtitle: 'Check volunteer attendance',
                        icon: Icons.how_to_reg,
                        color: Colors.green,
                        onTap: () => Navigator.pushNamed(context, '/presence-check-teamleader'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Events Section
                  const Text(
                    'My Events',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36)),
                  ),
                  const SizedBox(height: 16),

                  if (_myEvents.isEmpty)
                    const Center(
                      child: Column(
                        children: [
                          SizedBox(height: 40),
                          Icon(Icons.event_busy, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No events assigned to your teams yet', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    )
                  else
                    ...List.generate(_myEvents.length, (index) => _buildEventCard(_myEvents[index])),
                ],
              ),
            ),
    );
  }

  Widget _buildManagementCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    final myShifts = event.shifts.where((shift) {
      if (shift.teamId != null && _myTeams.any((team) => team.id == shift.teamId)) return true;
      if (shift.tempTeam != null && shift.tempTeam!.teamLeaderId == _currentUserPhone) return true;
      if (shift.subLocations.any((subLoc) => subLoc.teamId != null && _myTeams.any((team) => team.id == subLoc.teamId))) return true;
      if (shift.subLocations.any((subLoc) => subLoc.tempTeam != null && subLoc.tempTeam!.teamLeaderId == _currentUserPhone)) return true;
      return false;
    }).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showEventDetails(event),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.event, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${event.startDate} - ${event.endDate}', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                event.description,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  '$myShifts Shift${myShifts != 1 ? 's' : ''} Assigned',
                  style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventAssignmentPage extends StatefulWidget {
  final Event event;
  final List<Team> myTeams;
  final List<SystemUser> volunteers;
  final String currentUserPhone;
  final VoidCallback onUpdate;

  const EventAssignmentPage({super.key, required this.event, required this.myTeams, required this.volunteers, required this.currentUserPhone, required this.onUpdate});

  @override
  State<EventAssignmentPage> createState() => _EventAssignmentPageState();
}

class _EventAssignmentPageState extends State<EventAssignmentPage> {
  final EventHelperFirebase _eventHelper = EventHelperFirebase();
  late Event _event;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
  }

  void _assignMemberToShift(EventShift shift, String memberId, bool assign) {
    setState(() {
      if (shift.tempTeam != null && shift.tempTeam!.teamLeaderId == widget.currentUserPhone) {
        // Working with temp team
        if (assign && !shift.tempTeam!.memberIds.contains(memberId)) {
          shift.tempTeam!.memberIds.add(memberId);
        } else if (!assign) {
          shift.tempTeam!.memberIds.remove(memberId);
        }
      }
    });

    // Save to Firebase
    _eventHelper.UpdateEvent(_event);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(assign ? 'Member assigned' : 'Member removed'), duration: const Duration(seconds: 1)));
    }
  }

  List<SystemUser> _getAvailableVolunteers(EventShift shift) {
    // Get team members based on team type
    if (shift.tempTeam != null && shift.tempTeam!.teamLeaderId == widget.currentUserPhone) {
      // For temp teams, we can assign anyone
      return widget.volunteers;
    } else if (shift.teamId != null) {
      // For existing teams, only show team members
      final team = widget.myTeams.where((t) => t.id == shift.teamId).firstOrNull;
      if (team != null) {
        return widget.volunteers.where((v) => team.memberIds.contains(v.phone)).toList();
      }
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    final myShifts = _event.shifts.where((shift) {
      if (shift.teamId != null && widget.myTeams.any((team) => team.id == shift.teamId)) return true;
      if (shift.tempTeam != null && shift.tempTeam!.teamLeaderId == widget.currentUserPhone) return true;
      // Include shifts that have sublocations where I'm the leader
      if (shift.subLocations.any(
        (subLoc) =>
            (subLoc.teamId != null && widget.myTeams.any((team) => team.id == subLoc.teamId)) ||
            (subLoc.tempTeam != null && subLoc.tempTeam!.teamLeaderId == widget.currentUserPhone),
      )) {
        return true;
      }
      return false;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(_event.name)),
      body: myShifts.isEmpty
          ? const Center(child: Text('No shifts assigned to your teams'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myShifts.length,
              itemBuilder: (context, index) {
                final shift = myShifts[index];
                return _buildShiftCard(shift);
              },
            ),
    );
  }

  Widget _buildShiftCard(EventShift shift) {
    // Check if I manage the main shift
    final manageMainShift =
        (shift.teamId != null && widget.myTeams.any((team) => team.id == shift.teamId)) || (shift.tempTeam != null && shift.tempTeam!.teamLeaderId == widget.currentUserPhone);

    // Get my sublocations that I manage
    final mySubLocations = shift.subLocations
        .where(
          (subLoc) =>
              (subLoc.teamId != null && widget.myTeams.any((team) => team.id == subLoc.teamId)) ||
              (subLoc.tempTeam != null && subLoc.tempTeam!.teamLeaderId == widget.currentUserPhone),
        )
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Main shift section
          if (manageMainShift)
            ExpansionTile(
              leading: const Icon(Icons.schedule),
              title: Text('Main Shift: ${shift.startTime} - ${shift.endTime}'),
              subtitle: _buildAssignmentSubtitle(shift.tempTeam?.memberIds.length ?? 0, _getAvailableVolunteers(shift).length),
              children: [
                _buildMemberAssignmentList(shift.tempTeam?.memberIds ?? [], _getAvailableVolunteers(shift), (memberId, assign) => _assignMemberToShift(shift, memberId, assign)),
              ],
            ),
          // Sublocation sections
          if (mySubLocations.isNotEmpty)
            ...mySubLocations.map((subLoc) {
              final availableVolunteers = _getAvailableVolunteersForSubLocation(shift, subLoc);
              final assignedMemberIds = subLoc.tempTeam?.memberIds ?? [];

              return ExpansionTile(
                leading: const Icon(Icons.place),
                title: Text('SubLocation: ${subLoc.subLocationId}'),
                subtitle: _buildAssignmentSubtitle(assignedMemberIds.length, availableVolunteers.length),
                children: [_buildMemberAssignmentList(assignedMemberIds, availableVolunteers, (memberId, assign) => _assignMemberToSubLocation(shift, subLoc, memberId, assign))],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildAssignmentSubtitle(int assigned, int total) {
    return Text('$assigned/$total members assigned');
  }

  Widget _buildMemberAssignmentList(List<String> assignedMemberIds, List<SystemUser> availableVolunteers, Function(String, bool) onAssign) {
    if (availableVolunteers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No team members available',
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: availableVolunteers.map((volunteer) {
        final isAssigned = assignedMemberIds.contains(volunteer.phone);
        return CheckboxListTile(title: Text(volunteer.name), subtitle: Text(volunteer.phone), value: isAssigned, onChanged: (value) => onAssign(volunteer.phone, value ?? false));
      }).toList(),
    );
  }

  List<SystemUser> _getAvailableVolunteersForSubLocation(EventShift shift, ShiftSubLocation subLoc) {
    if (subLoc.tempTeam != null && subLoc.tempTeam!.teamLeaderId == widget.currentUserPhone) {
      return widget.volunteers;
    } else if (subLoc.teamId != null) {
      final team = widget.myTeams.where((t) => t.id == subLoc.teamId).firstOrNull;
      if (team != null) {
        return widget.volunteers.where((v) => team.memberIds.contains(v.phone)).toList();
      }
    }
    return [];
  }

  void _assignMemberToSubLocation(EventShift shift, ShiftSubLocation subLoc, String memberId, bool assign) {
    setState(() {
      if (subLoc.tempTeam != null && subLoc.tempTeam!.teamLeaderId == widget.currentUserPhone) {
        if (assign && !subLoc.tempTeam!.memberIds.contains(memberId)) {
          subLoc.tempTeam!.memberIds.add(memberId);
        } else if (!assign) {
          subLoc.tempTeam!.memberIds.remove(memberId);
        }
      }
    });

    _eventHelper.UpdateEvent(_event);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(assign ? 'Member assigned to sublocation' : 'Member removed from sublocation'), duration: const Duration(seconds: 1)));
    }
  }
}
