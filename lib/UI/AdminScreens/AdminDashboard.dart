import 'package:azimuth_vms/Models/Event.dart';
import 'package:azimuth_vms/Providers/EventsProvider.dart';
import 'package:azimuth_vms/Providers/NotificationsProvider.dart';
import 'package:azimuth_vms/Providers/TeamLeadersProvider.dart';
import 'package:azimuth_vms/Providers/VolunteersProvider.dart';
import 'package:azimuth_vms/UI/AdminScreens/EventsMgmt.dart';
import 'package:azimuth_vms/UI/AdminScreens/LocationsMgmt.dart';
import 'package:azimuth_vms/UI/AdminScreens/TeamLeadersMgmt.dart';
import 'package:azimuth_vms/UI/AdminScreens/TeamsMgmt.dart';
import 'package:azimuth_vms/UI/AdminScreens/VolunteersMgmt.dart';
import 'package:azimuth_vms/UI/Widgets/ChangePasswordScreen.dart';
import 'package:azimuth_vms/UI/Widgets/NotificationPanel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _DashboardHome(userPhone: _userPhone, onNavigate: (index) => setState(() => _selectedIndex = index)),
      const EventsMgmt(),
      const VolunteersMgmt(),
      const TeamLeadersMgmt(),
      const TeamsMgmt(),
      const LocationsMgmt(),
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
                  onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(Icons.admin_panel_settings, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Dashboard')),
                    NavigationRailDestination(icon: Icon(Icons.event_outlined), selectedIcon: Icon(Icons.event), label: Text('Events')),
                    NavigationRailDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: Text('Volunteers')),
                    NavigationRailDestination(icon: Icon(Icons.supervisor_account_outlined), selectedIcon: Icon(Icons.supervisor_account), label: Text('Leaders')),
                    NavigationRailDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups), label: Text('Teams')),
                    NavigationRailDestination(icon: Icon(Icons.location_on_outlined), selectedIcon: Icon(Icons.location_on), label: Text('Locations')),
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
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: screens,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            body: IndexedStack(
              index: _selectedIndex,
              children: screens,
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => setState(() => _selectedIndex = index),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.event_outlined), selectedIcon: Icon(Icons.event), label: 'Events'),
                NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Volunteers'),
                NavigationDestination(icon: Icon(Icons.supervisor_account_outlined), selectedIcon: Icon(Icons.supervisor_account), label: 'Leaders'),
                NavigationDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups), label: 'Teams'),
                NavigationDestination(icon: Icon(Icons.location_on_outlined), selectedIcon: Icon(Icons.location_on), label: 'Locations'),
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
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Welcome back, $userPhone', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
          ],
        ),
        actions: [
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
              const PopupMenuItem(value: 'change_password', child: Row(children: [Icon(Icons.lock_reset, size: 20), SizedBox(width: 8), Text('Change Password')])),
              const PopupMenuItem(value: 'logout', child: Row(children: [Icon(Icons.logout, size: 20), SizedBox(width: 8), Text('Sign Out')])),
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
          context.read<NotificationsProvider>().loadNotifications(userPhone);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsRow(context),
              const SizedBox(height: 32),
              Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildQuickActionsGrid(context),
              const SizedBox(height: 32),
              Text('Active Events', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildActiveEventsList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final children = [
          Consumer<EventsProvider>(
            builder: (context, provider, _) => _StatCard(
              title: 'Active Events',
              value: provider.activeEvents.length.toString(),
              icon: Icons.event_available,
              color: Colors.blue,
            ),
          ),
          Consumer<VolunteersProvider>(
            builder: (context, provider, _) => _StatCard(
              title: 'Volunteers',
              value: provider.volunteers.length.toString(),
              icon: Icons.people,
              color: Colors.green,
            ),
          ),
          Consumer<TeamLeadersProvider>(
            builder: (context, provider, _) => _StatCard(
              title: 'Team Leaders',
              value: provider.teamLeaders.length.toString(),
              icon: Icons.supervisor_account,
              color: Colors.orange,
            ),
          ),
          Consumer<NotificationsProvider>(
            builder: (context, provider, _) => _StatCard(
              title: 'Notifications',
              value: provider.unreadCount.toString(),
              icon: Icons.notifications_active,
              color: Colors.purple,
            ),
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
            children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: c))).toList(),
          );
        }
      },
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      _QuickAction(
        title: 'Shift Assignment',
        icon: Icons.assignment_ind,
        color: Colors.indigo,
        onTap: () => Navigator.pushNamed(context, '/shift-assignment'),
      ),
      _QuickAction(
        title: 'Presence Check',
        icon: Icons.fact_check,
        color: Colors.teal,
        onTap: () => Navigator.pushNamed(context, '/presence-check'),
      ),
      _QuickAction(
        title: 'Forms Mgmt',
        icon: Icons.description,
        color: Colors.amber.shade700,
        onTap: () => Navigator.pushNamed(context, '/form-mgmt'),
      ),
      _QuickAction(
        title: 'Ratings',
        icon: Icons.star,
        color: Colors.pink,
        onTap: () => Navigator.pushNamed(context, '/volunteer-rating'),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth > 900 ? 4 : constraints.maxWidth > 600 ? 2 : 2;
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
    return Consumer<EventsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        if (provider.activeEvents.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.event_busy, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('No active events', style: TextStyle(color: Colors.grey.shade500)),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.activeEvents.take(5).length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
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
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.event, color: Colors.blue.shade700),
                ),
                title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  '${event.startDate} - ${event.endDate}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () => onNavigate(1), // Navigate to Events tab
              ),
            );
          },
        );
      },
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500)),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }
}
