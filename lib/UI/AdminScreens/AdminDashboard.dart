import 'package:azimuth_vms/Providers/CarouselProvider.dart';
import 'package:azimuth_vms/Providers/EventsProvider.dart';
import 'package:azimuth_vms/Providers/LocationsProvider.dart';
import 'package:azimuth_vms/Providers/NotificationsProvider.dart';
import 'package:azimuth_vms/Providers/TeamLeadersProvider.dart';
import 'package:azimuth_vms/Providers/VolunteersProvider.dart';
import 'package:azimuth_vms/Providers/TeamsProvider.dart';
import 'package:azimuth_vms/UI/AdminScreens/EventsMgmt.dart';
import 'package:azimuth_vms/UI/AdminScreens/LocationsMgmt.dart';
import 'package:azimuth_vms/UI/AdminScreens/TeamLeadersMgmt.dart';
import 'package:azimuth_vms/UI/AdminScreens/TeamsMgmt.dart';
import 'package:azimuth_vms/UI/AdminScreens/VolunteersMgmt.dart';
import 'package:azimuth_vms/UI/AdminScreens/SendNotificationScreen.dart';
import 'package:azimuth_vms/UI/AdminScreens/ThemeSettingsScreen.dart';
import 'package:azimuth_vms/UI/Widgets/ChangePasswordScreen.dart';
import 'package:azimuth_vms/UI/Widgets/ImageCarouselSlider.dart';
import 'package:azimuth_vms/UI/Widgets/NotificationPanel.dart';
import 'package:azimuth_vms/UI/Widgets/LanguageSwitcher.dart';
import 'package:azimuth_vms/UI/Theme/Breakpoints.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:azimuth_vms/l10n/app_localizations.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  int _currentScreenIndex = 0; // Actual screen being displayed
  String _userPhone = '';

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _userPhone = user?.email?.split('@').first ?? '';

    // Load data for dashboard stats
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().loadNotifications(_userPhone);
      context.read<EventsProvider>().loadEvents();
      context.read<VolunteersProvider>().loadVolunteers();
      context.read<TeamLeadersProvider>().loadTeamLeaders();
      context.read<TeamsProvider>().loadTeams();
      context.read<LocationsProvider>().loadLocations();
      context.read<CarouselProvider>().loadImages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final screens = [
      _DashboardHome(
        userPhone: _userPhone,
        onNavigate: (index) => setState(() {
          _selectedIndex = index;
          _currentScreenIndex = index;
        }),
      ),
      const EventsMgmt(),
      const VolunteersMgmt(),
      const TeamLeadersMgmt(),
      _MoreMenu(
        onNavigate: (route) {
          // Keep "More" tab selected (index 4) but change the screen
          if (route == '/teams') {
            setState(() {
              _selectedIndex = 4; // Keep More selected
              _currentScreenIndex = 5;
            });
          } else if (route == '/locations') {
            setState(() {
              _selectedIndex = 4;
              _currentScreenIndex = 6;
            });
          } else if (route == '/send-notification') {
            setState(() {
              _selectedIndex = 4;
              _currentScreenIndex = 7;
            });
          } else if (route == '/theme-settings') {
            setState(() {
              _selectedIndex = 4;
              _currentScreenIndex = 8;
            });
          }
        },
      ),
      const TeamsMgmt(),
      const LocationsMgmt(),
      const SendNotificationScreen(),
      const ThemeSettingsScreen(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) => setState(() {
                    _selectedIndex = index;
                    _currentScreenIndex = index;
                  }),
                  labelType: NavigationRailLabelType.none,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(Icons.admin_panel_settings, color: Theme.of(context).colorScheme.primary, size: 20),
                    ),
                  ),
                  destinations: [
                    NavigationRailDestination(icon: const Icon(Icons.dashboard_outlined), selectedIcon: const Icon(Icons.dashboard), label: Text(l10n.dashboard)),
                    NavigationRailDestination(icon: const Icon(Icons.event_outlined), selectedIcon: const Icon(Icons.event), label: Text(l10n.events)),
                    NavigationRailDestination(icon: const Icon(Icons.people_outline), selectedIcon: const Icon(Icons.people), label: Text(l10n.volunteers)),
                    NavigationRailDestination(icon: const Icon(Icons.supervisor_account_outlined), selectedIcon: const Icon(Icons.supervisor_account), label: Text(l10n.leaders)),
                    NavigationRailDestination(icon: const Icon(Icons.more_horiz), selectedIcon: const Icon(Icons.menu), label: const Text('More')),
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
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: IndexedStack(index: _currentScreenIndex, children: screens),
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            body: IndexedStack(index: _currentScreenIndex, children: screens),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => setState(() {
                _selectedIndex = index;
                _currentScreenIndex = index;
              }),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              destinations: [
                NavigationDestination(icon: const Icon(Icons.dashboard_outlined), selectedIcon: const Icon(Icons.dashboard), label: l10n.home),
                NavigationDestination(icon: const Icon(Icons.event_outlined), selectedIcon: const Icon(Icons.event), label: l10n.events),
                NavigationDestination(icon: const Icon(Icons.people_outline), selectedIcon: const Icon(Icons.people), label: l10n.volunteers),
                NavigationDestination(icon: const Icon(Icons.supervisor_account_outlined), selectedIcon: const Icon(Icons.supervisor_account), label: l10n.leaders),
                NavigationDestination(icon: const Icon(Icons.more_horiz), selectedIcon: const Icon(Icons.menu), label: 'More'),
              ],
            ),
          );
        }
      },
    );
  }
}

class _DashboardHome extends StatelessWidget {
  final String userPhone;
  final Function(int) onNavigate;

  const _DashboardHome({required this.userPhone, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dashboard,
              style: TextStyle(fontSize: Breakpoints.isMobile(context) ? 13 : 20, fontWeight: FontWeight.bold),
            ),
            Text(l10n.welcomeBack(userPhone), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
          ],
        ),
        actions: [
          const LanguageSwitcher(showLabel: false, isIconButton: true),
          Consumer<NotificationsProvider>(
            builder: (context, notifProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(value: notifProvider, child: const NotificationPanel()),
                        ),
                      );
                    },
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (value) {
              if (value == 'change_password') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordScreen(userPhone: userPhone)));
              } else if (value == 'logout') {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/sign-in');
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'change_password',
                child: Row(children: [const Icon(Icons.lock_reset, size: 20), const SizedBox(width: 8), Text(l10n.changePassword)]),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(children: [const Icon(Icons.logout, size: 20), const SizedBox(width: 8), Text(l10n.signOut)]),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<EventsProvider>().loadEvents();
          context.read<VolunteersProvider>().loadVolunteers();
          context.read<TeamLeadersProvider>().loadTeamLeaders();
          context.read<TeamsProvider>().loadTeams();
          context.read<LocationsProvider>().loadLocations();
          context.read<CarouselProvider>().loadImages();
          context.read<NotificationsProvider>().loadNotifications(userPhone);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Carousel
              Consumer<CarouselProvider>(
                builder: (context, carouselProvider, child) {
                  final List<dynamic> visibleImages = carouselProvider.images.where((img) => img.isVisible).toList();
                  if (visibleImages.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      ImageCarouselSlider(images: visibleImages.cast(), height: 200),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
              _buildStatsRow(context),
              const SizedBox(height: 32),
              Text(l10n.analytics, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildAnalyticsSection(context),
              const SizedBox(height: 32),
              Text(l10n.quickActions, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildQuickActionsGrid(context),
              const SizedBox(height: 32),
              Text(l10n.workflowScenarios, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildWorkflowScenarios(context),
              const SizedBox(height: 32),
              Text(l10n.activeEvents, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildActiveEventsList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<TeamsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        if (provider.teams.isEmpty) return const SizedBox.shrink();

        // Prepare data: Top 5 teams by member count
        final teams = List.of(provider.teams);
        teams.sort((a, b) => b.memberIds.length.compareTo(a.memberIds.length));
        final topTeams = teams.take(5).toList();
        final maxMembers = topTeams.isNotEmpty ? topTeams.first.memberIds.length : 1;

        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.volunteersPerTeam, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: topTeams.map((team) {
                    final heightFactor = team.memberIds.length / maxMembers;
                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Tooltip(
                            message: '${team.memberIds.length} ${l10n.members}',
                            child: Container(
                              height: 150 * heightFactor,
                              width: 30,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            team.name.length > 8 ? '${team.name.substring(0, 6)}..' : team.name,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final children = [
          Consumer<EventsProvider>(
            builder: (context, provider, _) =>
                _StatCard(title: l10n.activeEventsCount, value: provider.activeEvents.length.toString(), icon: Icons.event_available, color: Colors.blue),
          ),
          Consumer<VolunteersProvider>(
            builder: (context, provider, _) => _StatCard(title: l10n.volunteers, value: provider.volunteers.length.toString(), icon: Icons.people, color: Colors.green),
          ),
          Consumer<TeamLeadersProvider>(
            builder: (context, provider, _) =>
                _StatCard(title: l10n.teamLeaders, value: provider.teamLeaders.length.toString(), icon: Icons.supervisor_account, color: Colors.orange),
          ),
          Consumer<NotificationsProvider>(
            builder: (context, provider, _) => _StatCard(title: l10n.notifications, value: provider.unreadCount.toString(), icon: Icons.notifications_active, color: Colors.purple),
          ),
        ];

        if (isMobile) {
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: children,
          );
        } else {
          return Row(
            children: children
                .map(
                  (c) => Expanded(
                    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: c),
                  ),
                )
                .toList(),
          );
        }
      },
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final actions = [
      _QuickAction(title: l10n.shiftAssignment, icon: Icons.assignment_ind, color: Colors.indigo, onTap: () => Navigator.pushNamed(context, '/shift-assignment')),
      _QuickAction(title: l10n.presenceCheck, icon: Icons.fact_check, color: Colors.teal, onTap: () => Navigator.pushNamed(context, '/presence-check-admin')),
      _QuickAction(title: l10n.formsMgmt, icon: Icons.description, color: Colors.amber.shade700, onTap: () => Navigator.pushNamed(context, '/form-mgmt')),
      _QuickAction(title: l10n.carouselMgmt, icon: Icons.view_carousel, color: Colors.deepPurple, onTap: () => Navigator.pushNamed(context, '/carousel-management')),
      _QuickAction(title: l10n.ratings, icon: Icons.star, color: Colors.pink, onTap: () => Navigator.pushNamed(context, '/volunteer-rating')),
      _QuickAction(title: l10n.leaveRequests, icon: Icons.event_busy, color: Colors.orange, onTap: () => Navigator.pushNamed(context, '/leave-request-management')),
      _QuickAction(title: l10n.systemFeedback, icon: Icons.feedback, color: Colors.teal, onTap: () => Navigator.pushNamed(context, '/manage-feedback')),
      _QuickAction(title: l10n.eventFeedback, icon: Icons.rate_review, color: Colors.purple, onTap: () => Navigator.pushNamed(context, '/event-feedback-report')),
      _QuickAction(title: l10n.sendNotification, icon: Icons.send, color: Colors.cyan, onTap: () => Navigator.pushNamed(context, '/send-notification')),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth > 1100
            ? 4
            : constraints.maxWidth > 800
            ? 3
            : 2;
        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: actions,
        );
      },
    );
  }

  Widget _buildActiveEventsList(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<EventsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        if (provider.activeEvents.isEmpty) {
          final theme = Theme.of(context);
          return Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              children: [
                Icon(Icons.event_busy, size: 48, color: theme.colorScheme.onSurface.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text(l10n.noActiveEvents, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5))),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.activeEvents.take(5).length,
          separatorBuilder: (BuildContext _, int __) => const SizedBox(height: 12),
          itemBuilder: (BuildContext context, int index) {
            final event = provider.activeEvents[index];
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.event, color: Colors.blue.shade700),
                ),
                title: Text(event.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${event.startDate} - ${event.endDate}', style: TextStyle(color: Colors.grey.shade600)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () => onNavigate(1), // Navigate to Events tab
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWorkflowScenarios(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(
              child: _ScenarioCard(
                title: l10n.volunteerRegistration,
                description: l10n.volunteerRegistrationDescription,
                icon: Icons.person_add,
                color: Colors.blue,
                onTap: () => Navigator.pushNamed(context, '/form-mgmt'),
              ),
            ),
            if (constraints.maxWidth > 600) ...[
              const SizedBox(width: 16),
              Expanded(
                child: _ScenarioCard(
                  title: l10n.eventManagement,
                  description: l10n.eventManagementDescription,
                  icon: Icons.event,
                  color: Colors.purple,
                  onTap: () => onNavigate(1), // Switch to Events tab
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ScenarioCard({required this.title, required this.description, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(description, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    l10n.startWorkflow,
                    style: TextStyle(color: color, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 16, color: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 24),
              ),
              Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreMenu extends StatelessWidget {
  final Function(String) onNavigate;

  const _MoreMenu({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: const Text('More'), automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MoreMenuItem(icon: Icons.groups, title: l10n.teams, subtitle: 'Manage teams and members', color: Colors.purple, onTap: () => onNavigate('/teams')),
          const SizedBox(height: 12),
          _MoreMenuItem(icon: Icons.location_on, title: l10n.locations, subtitle: 'Manage locations and sublocations', color: Colors.orange, onTap: () => onNavigate('/locations')),
          const SizedBox(height: 12),
          _MoreMenuItem(
            icon: Icons.campaign,
            title: l10n.sendNotification,
            subtitle: l10n.sendNotificationsToGroups,
            color: Colors.cyan,
            onTap: () => onNavigate('/send-notification'),
          ),
          const SizedBox(height: 12),
          _MoreMenuItem(icon: Icons.palette, title: 'Theme Settings', subtitle: 'Change app theme and appearance', color: Colors.pink, onTap: () => onNavigate('/theme-settings')),
        ],
      ),
    );
  }
}

class _MoreMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MoreMenuItem({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withOpacity(0.4)),
            ],
          ),
        ),
      ),
    );
  }
}
