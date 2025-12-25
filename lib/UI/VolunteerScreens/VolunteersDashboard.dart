import 'package:azimuth_vms/Helpers/VolunteerFormHelperFirebase.dart';
import 'package:azimuth_vms/Models/VolunteerForm.dart';
import 'package:azimuth_vms/UI/Widgets/ChangePasswordScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VolunteersDashboard extends StatelessWidget {
  const VolunteersDashboard({super.key});

  Future<VolunteerForm?> _getVolunteerForm() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user == null) {
      return null;
    }

    VolunteerFormHelperFirebase helper = VolunteerFormHelperFirebase();
    return await helper.GetFormByMobileNumber(user.email!.split('@').first);
  }

  Future<void> _handleFormFill(BuildContext context, VolunteerForm form) async {
    final result = await Navigator.pushNamed(context, '/form-fill', arguments: form);
    if (result == true && context.mounted) {
      Navigator.pushReplacementNamed(context, '/volunteer-dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VolunteerForm?>(
      future: _getVolunteerForm(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          print('Error loading volunteer form: ${snapshot.error}');
          return _buildErrorScreen(context, 'Error loading your information. Please try again.');
        }

        final form = snapshot.data;
        if (form == null) {
          return _buildErrorScreen(context, 'No volunteer form found. Please contact support.');
        }

        final status = form.status ?? VolunteerFormStatus.Rejected2;

        switch (status) {
          case VolunteerFormStatus.Sent:
            // Navigate to form fill page
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _handleFormFill(context, form);
            });
            return const Scaffold(
              body: Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Redirecting to form...')]),
              ),
            );

          case VolunteerFormStatus.Pending:
            return _buildPendingScreen();

          case VolunteerFormStatus.Approved1:
            return _buildApprovedDashboard(context, form, 'First Level Approval', 'Your application has been approved at the first level. Waiting for final approval.');

          case VolunteerFormStatus.Approved2:
            return _buildApprovedDashboard(context, form, 'Fully Approved', 'Congratulations! Your application has been fully approved.', isFullyApproved: true);

          case VolunteerFormStatus.Completed:
            return _buildApprovedDashboard(context, form, 'Active Volunteer', 'You are an active volunteer in the system.', isFullyApproved: true);

          case VolunteerFormStatus.Rejected1:
            return _buildRejectedScreen(context, 'Application Rejected', 'Your application was rejected at the first review stage.');

          case VolunteerFormStatus.Rejected2:
            return _buildRejectedScreen(context, 'Application Rejected', 'Your application was rejected at the final review stage.');
        }
      },
    );
  }

  Widget _buildPendingScreen() {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: const Text('Volunteer Dashboard'), backgroundColor: Colors.orange),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_empty, size: 80, color: Colors.orange),
              const SizedBox(height: 24),
              const Text(
                'Application Under Review',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Your volunteer application has been submitted and is currently under review. You will be notified once a decision has been made.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApprovedDashboard(BuildContext context, VolunteerForm form, String title, String message, {bool isFullyApproved = false}) {
    final userPhone = FirebaseAuth.instance.currentUser?.email?.split('@').first ?? '';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Volunteer Dashboard'),
        backgroundColor: Colors.green,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) {
              if (value == 'change_password') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordScreen(userPhone: userPhone)));
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard('Welcome ', form.fullName),
            if (isFullyApproved) ...[
              const SizedBox(height: 24),
              const Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildActionCard(context, 'My Events', 'View your assigned events and shifts', Icons.event, Colors.blue, () {
                Navigator.pushNamed(context, '/volunteer/events');
              }),
              _buildActionCard(context, 'My Schedule', 'View your volunteer schedule', Icons.calendar_today, Colors.purple, () {
                // TODO: Navigate to schedule page
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Schedule feature coming soon')));
              }),
              _buildActionCard(context, 'Profile', 'View and update your profile', Icons.person, Colors.teal, () {
                // TODO: Navigate to profile page
                Navigator.pushNamed(context, '/form-fill', arguments: form);
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String? value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        subtitle: Text(
          value ?? 'N/A',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRejectedScreen(BuildContext context, String title, String message) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: const Text('Volunteer Dashboard'), backgroundColor: Colors.red),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cancel, size: 80, color: Colors.red),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(message, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/sign-in');
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: const Text('Volunteer Dashboard'), backgroundColor: Colors.grey),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.grey),
              const SizedBox(height: 24),
              const Text(
                'Error',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(message, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/sign-in');
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
