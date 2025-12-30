import 'package:azimuth_vms/Helpers/EventHelperFirebase.dart';
import 'package:azimuth_vms/Helpers/SystemUserHelperFirebase.dart';
import 'package:azimuth_vms/Helpers/TeamHelperFirebase.dart';
import 'package:azimuth_vms/Models/Event.dart';
import 'package:azimuth_vms/Models/SystemUser.dart';
import 'package:azimuth_vms/Models/Team.dart';
import 'package:azimuth_vms/Providers/CarouselProvider.dart';
import 'package:azimuth_vms/Providers/NotificationsProvider.dart';
import 'package:azimuth_vms/UI/Widgets/ChangePasswordScreen.dart';
import 'package:azimuth_vms/UI/Widgets/ImageCarouselSlider.dart';
import 'package:azimuth_vms/UI/Widgets/NotificationPanel.dart';
import 'package:azimuth_vms/UI/Widgets/UpcomingShiftCard.dart';
import 'package:azimuth_vms/UI/Widgets/VolunteerStatsChart.dart';
import 'package:azimuth_vms/UI/Widgets/FadeInSlide.dart';
import 'package:azimuth_vms/UI/Widgets/LanguageSwitcher.dart';
import 'package:azimuth_vms/UI/Theme/Breakpoints.dart';
import 'package:azimuth_vms/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  SystemUser? _currentUser;
  bool _isLoading = true;
  bool _hasLoadedNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load notifications after context is available
    if (!_hasLoadedNotifications && _currentUserPhone != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hasLoadedNotifications) {
          _hasLoadedNotifications = true;
          context.read<NotificationsProvider>().loadNotifications(_currentUserPhone!);
        }
      });
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Get current user phone
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      _currentUserPhone = user.email!.split('@').first;

      // Load current user details
      _currentUser = await _userHelper.GetSystemUserByPhone(_currentUserPhone!);

      // Trigger didChangeDependencies to load notifications
      if (mounted && !_hasLoadedNotifications) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_hasLoadedNotifications) {
            _hasLoadedNotifications = true;
            context.read<NotificationsProvider>().loadNotifications(_currentUserPhone!);
          }
        });
      }

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

      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading team leader data: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorLoadingData(e.toString()))));
          }
        });
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
    final theme = Theme.of(context);
    // Find next upcoming event
    Event? nextEvent;
    EventShift? nextShift;

    if (_myEvents.isNotEmpty) {
      final now = DateTime.now();
      final futureEvents = _myEvents.where((e) {
        try {
          return DateTime.parse(e.startDate).isAfter(now.subtract(const Duration(days: 1)));
        } catch (_) {
          return true;
        }
      }).toList();

      futureEvents.sort((a, b) => a.startDate.compareTo(b.startDate));

      if (futureEvents.isNotEmpty) {
        nextEvent = futureEvents.first;
        if (nextEvent.shifts.isNotEmpty) {
          nextShift = nextEvent.shifts.first;
        }
      }
    }

    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;

        final body = _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Carousel Slider
                      FadeInSlide(
                        child: Consumer<CarouselProvider>(
                          builder: (context, carouselProvider, child) {
                            final visibleImages = carouselProvider.images.where((img) => img.isVisible).toList();
                            if (visibleImages.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return ImageCarouselSlider(images: visibleImages, height: 200);
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (nextEvent != null && nextShift != null) ...[
                        FadeInSlide(
                          child: Text(
                            l10n.upcomingShift,
                            style: TextStyle(fontSize: Breakpoints.isMobile(context) ? 13 : 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInSlide(
                          delay: 0.05,
                          child: UpcomingShiftCard(event: nextEvent, shift: nextShift),
                        ),
                        const SizedBox(height: 24),
                      ],
                      FadeInSlide(
                        delay: 0.1,
                        child: Text(
                          l10n.activity,
                          style: TextStyle(fontSize: Breakpoints.isMobile(context) ? 13 : 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeInSlide(delay: 0.15, child: VolunteerStatsChart(userPhone: _currentUserPhone ?? '')),
                      const SizedBox(height: 24),
                      FadeInSlide(
                        delay: 0.2,
                        child: Text(
                          l10n.management,
                          style: TextStyle(fontSize: Breakpoints.isMobile(context) ? 13 : 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeInSlide(
                        delay: 0.25,
                        child: GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.9,
                          children: [
                            _buildManagementCard(
                              context,
                              title: l10n.manageShifts,
                              subtitle: l10n.assignVolunteersToShifts,
                              icon: Icons.assignment,
                              color: Colors.blue,
                              onTap: () => Navigator.pushNamed(context, '/teamleader-shift-management'),
                            ),
                            _buildManagementCard(
                              context,
                              title: l10n.leaveRequests,
                              subtitle: l10n.reviewVolunteerLeaveRequests,
                              icon: Icons.report_problem,
                              color: Colors.orange,
                              onTap: () => Navigator.pushNamed(context, '/leave-request-management'),
                            ),
                            _buildManagementCard(
                              context,
                              title: l10n.presenceChecks,
                              subtitle: l10n.checkVolunteerAttendance,
                              icon: Icons.how_to_reg,
                              color: Colors.green,
                              onTap: () => Navigator.pushNamed(context, '/presence-check-teamleader'),
                            ),
                            _buildManagementCard(
                              context,
                              title: l10n.submitFeedback,
                              subtitle: l10n.reportBugsOrSuggestIdeas,
                              icon: Icons.feedback,
                              color: Colors.purple,
                              onTap: () => Navigator.pushNamed(context, '/submit-feedback'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Events Section
                      FadeInSlide(
                        delay: 0.3,
                        child: Text(
                          l10n.myEvents,
                          style: TextStyle(fontSize: Breakpoints.isMobile(context) ? 13 : 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (_myEvents.isEmpty)
                        FadeInSlide(
                          delay: 0.35,
                          child: Center(
                            child: Column(
                              children: [
                                const SizedBox(height: 40),
                                Icon(Icons.event_busy, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.3)),
                                const SizedBox(height: 16),
                                Text(l10n.noEventsAssignedYet, style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                              ],
                            ),
                          ),
                        )
                      else
                        ...List.generate(_myEvents.length, (index) => FadeInSlide(delay: 0.4 + (index * 0.05), child: _buildEventCard(_myEvents[index]))),
                      SizedBox(height: isDesktop ? 24 : 80),
                    ],
                  ),
                ),
              );

        if (isDesktop) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: 0,
                  onDestinationSelected: (index) {
                    switch (index) {
                      case 0: // Dashboard - already here
                        break;
                      case 1: // Manage Shifts
                        Navigator.pushNamed(context, '/teamleader-shift-management');
                        break;
                      case 2: // Presence Checks
                        Navigator.pushNamed(context, '/presence-check-teamleader');
                        break;
                      case 3: // Leave Requests
                        Navigator.pushNamed(context, '/leave-request-management');
                        break;
                      case 4: // Profile/Settings
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordScreen(userPhone: _currentUserPhone ?? '')));
                        break;
                    }
                  },
                  labelType: NavigationRailLabelType.selected,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Consumer<NotificationsProvider>(
                      builder: (context, notifProvider, child) {
                        return Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined, size: 28),
                              onPressed: () {
                                final provider = context.read<NotificationsProvider>();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChangeNotifierProvider.value(value: provider, child: const NotificationPanel()),
                                  ),
                                );
                              },
                              tooltip: l10n.notifications,
                            ),
                            if (notifProvider.unreadCount > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                  child: Text(
                                    notifProvider.unreadCount > 9 ? '9+' : '${notifProvider.unreadCount}',
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  destinations: [
                    NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text(l10n.home)),
                    NavigationRailDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: Text(l10n.manageShifts)),
                    NavigationRailDestination(icon: Icon(Icons.how_to_reg_outlined), selectedIcon: Icon(Icons.how_to_reg), label: Text(l10n.presenceCheck)),
                    NavigationRailDestination(icon: Icon(Icons.report_problem_outlined), selectedIcon: Icon(Icons.report_problem), label: Text(l10n.leaveRequests)),
                    NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text(l10n.profile)),
                  ],
                  trailing: Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.logout),
                          onPressed: () {
                            FirebaseAuth.instance.signOut();
                            Navigator.pushReplacementNamed(context, '/sign-in');
                          },
                          tooltip: l10n.signOut,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: Column(
                    children: [
                      AppBar(
                        automaticallyImplyLeading: false,
                        title: Text(l10n.teamLeaderDashboard),
                        backgroundColor: theme.scaffoldBackgroundColor,
                        elevation: 0,
                        foregroundColor: theme.colorScheme.onSurface,
                        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData)],
                      ),
                      Expanded(child: body),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(l10n.teamLeaderDashboard),
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              foregroundColor: theme.colorScheme.onSurface,
              actions: [
                const LanguageSwitcher(showLabel: false, isIconButton: true),
                IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
                Consumer<NotificationsProvider>(
                  builder: (context, notifProvider, child) {
                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () {
                            final provider = context.read<NotificationsProvider>();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangeNotifierProvider.value(value: provider, child: const NotificationPanel()),
                              ),
                            );
                          },
                          tooltip: l10n.notifications,
                        ),
                        if (notifProvider.unreadCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                              child: Text(
                                notifProvider.unreadCount > 9 ? '9+' : '${notifProvider.unreadCount}',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
            body: body,
            bottomNavigationBar: _buildBottomNavigation(context),
          );
        }
      },
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.4),
      currentIndex: 0,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (index) {
        switch (index) {
          case 0: // Dashboard - already here
            break;
          case 1: // Manage Shifts
            Navigator.pushNamed(context, '/teamleader-shift-management');
            break;
          case 2: // Presence Checks
            Navigator.pushNamed(context, '/presence-check-teamleader');
            break;
          case 3: // Leave Requests
            Navigator.pushNamed(context, '/leave-request-management');
            break;
          case 4: // More menu
            _showMoreMenu(context);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.how_to_reg), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.report_problem), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: ''),
      ],
    );
  }

  void _showMoreMenu(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('More', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.person, color: Colors.blue),
              ),
              title: Text(l10n.changePassword),
              subtitle: const Text('Update your password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordScreen(userPhone: _currentUserPhone ?? '')));
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.logout, color: Colors.red),
              ),
              title: Text(l10n.signOut),
              subtitle: const Text('Sign out of your account'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/sign-in');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(String? name) {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue.shade800, Colors.blue.shade500], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Stack(
            children: [
              Positioned(right: -20, top: -20, child: Icon(Icons.admin_panel_settings, size: 150, color: Colors.white.withOpacity(0.1))),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      child: Text(
                        name?.substring(0, 1).toUpperCase() ?? '?',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.welcomeBackName,
                          style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          name ?? l10n.teamLeader,
                          style: TextStyle(color: Colors.white, fontSize: Breakpoints.isMobile(context) ? 17 : 26, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
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

    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
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
                            Text(
                              event.name,
                              style: TextStyle(fontSize: Breakpoints.isMobile(context) ? 12 : 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text('${event.startDate} - ${event.endDate}', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event.description,
                    style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      l10n.shiftsAssigned(myShifts, myShifts != 1 ? 's' : ''),
                      style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(assign ? l10n.memberAssigned : l10n.memberRemoved), duration: const Duration(seconds: 1)));
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

  Widget _buildAssignmentSubtitle(int assignedCount, int totalCount) {
    return Text('$assignedCount / $totalCount volunteers assigned', style: TextStyle(fontSize: 14, color: Colors.grey[600]));
  }

  Widget _buildMemberAssignmentList(List<String> assignedMemberIds, List<SystemUser> availableVolunteers, Function(String, bool) onAssign) {
    if (availableVolunteers.isEmpty) {
      return const Padding(padding: EdgeInsets.all(16.0), child: Text('No volunteers available for assignment'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: availableVolunteers.length,
      itemBuilder: (context, index) {
        final volunteer = availableVolunteers[index];
        final isAssigned = assignedMemberIds.contains(volunteer.phone);

        return CheckboxListTile(
          title: Text(volunteer.name),
          subtitle: Text(volunteer.phone),
          value: isAssigned,
          onChanged: (bool? value) {
            if (value != null) {
              onAssign(volunteer.phone, value);
            }
          },
        );
      },
    );
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
          ? Center(child: Text(AppLocalizations.of(context)!.noShiftsAssignedToYourTeams))
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
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Column(
            children: [
              // Main shift section
              if (manageMainShift)
                ExpansionTile(
                  leading: const Icon(Icons.schedule),
                  title: Text('${l10n.mainShift}: ${shift.startTime} - ${shift.endTime}'),
                  subtitle: _buildAssignmentSubtitle(shift.tempTeam?.memberIds.length ?? 0, _getAvailableVolunteers(shift).length),
                  children: [
                    _buildMemberAssignmentList(
                      shift.tempTeam?.memberIds ?? [],
                      _getAvailableVolunteers(shift),
                      (memberId, assign) => _assignMemberToShift(shift, memberId, assign),
                    ),
                  ],
                ),
              // Sublocation sections
              if (mySubLocations.isNotEmpty)
                ...mySubLocations.map((subLoc) {
                  final availableVolunteers = _getAvailableVolunteersForSubLocation(shift, subLoc);
                  final assignedMemberIds = subLoc.tempTeam?.memberIds ?? [];

                  return ExpansionTile(
                    leading: const Icon(Icons.place),
                    title: Text('${l10n.subLocation}: ${subLoc.id}'),
                    subtitle: _buildAssignmentSubtitle(assignedMemberIds.length, availableVolunteers.length),
                    children: [
                      _buildMemberAssignmentList(assignedMemberIds, availableVolunteers, (memberId, assign) => _assignMemberToSubLocation(shift, subLoc, memberId, assign)),
                    ],
                  );
                }),
            ],
          );
        },
      ),
    );
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(assign ? l10n.memberAssignedToSublocation : l10n.memberRemovedFromSublocation), duration: const Duration(seconds: 1)));
    }
  }
}
