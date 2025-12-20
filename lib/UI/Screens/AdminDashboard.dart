import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushNamed(context, '/sign-in');
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
}
