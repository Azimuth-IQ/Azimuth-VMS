import 'package:azimuth_vms/Helpers/VolunteerFormHelperFirebase.dart';
import 'package:azimuth_vms/Models/VolunteerForm.dart';
import 'package:azimuth_vms/Providers/CarouselProvider.dart';
import 'package:azimuth_vms/Providers/NotificationsProvider.dart';
import 'package:azimuth_vms/Providers/ShiftAssignmentProvider.dart';
import 'package:azimuth_vms/Providers/VolunteerRatingProvider.dart';
import 'package:azimuth_vms/UI/Widgets/ChangePasswordScreen.dart';
import 'package:azimuth_vms/UI/Widgets/ImageCarouselSlider.dart';
import 'package:azimuth_vms/UI/Widgets/NotificationPanel.dart';
import 'package:azimuth_vms/UI/VolunteerScreens/VolunteerScheduleScreen.dart';
import 'package:azimuth_vms/UI/VolunteerScreens/VolunteerProfileScreen.dart';
import 'package:azimuth_vms/UI/Widgets/VolunteerStatsChart.dart';
import 'package:azimuth_vms/UI/Widgets/UpcomingShiftCard.dart';
import 'package:azimuth_vms/UI/Widgets/FadeInSlide.dart';
import 'package:azimuth_vms/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          final l10n = AppLocalizations.of(context)!;
          return _buildErrorScreen(context, l10n.errorLoadingInfo);
        }

        final form = snapshot.data;
        if (form == null) {
          final l10n = AppLocalizations.of(context)!;
          return _buildErrorScreen(context, l10n.noVolunteerFormFound);
        }

        final status = form.status ?? VolunteerFormStatus.Rejected2;

        switch (status) {
          case VolunteerFormStatus.Sent:
            // Navigate to form fill page
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _handleFormFill(context, form);
            });
            final l10n = AppLocalizations.of(context)!;
            return Scaffold(
              body: Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 16), Text(l10n.redirectingToForm)]),
              ),
            );

          case VolunteerFormStatus.Pending:
            return _buildPendingScreen();

          case VolunteerFormStatus.Approved1:
            final l10n = AppLocalizations.of(context)!;
            return _buildApprovedDashboard(context, form, l10n.firstLevelApprovalTitle, l10n.firstLevelApprovalDesc);

          case VolunteerFormStatus.Approved2:
            final l10n = AppLocalizations.of(context)!;
            return _buildApprovedDashboard(context, form, l10n.fullyApproved, l10n.fullyApprovedDesc, isFullyApproved: true);

          case VolunteerFormStatus.Completed:
            final l10n = AppLocalizations.of(context)!;
            return _buildApprovedDashboard(context, form, l10n.activeVolunteer, l10n.activeVolunteerDesc, isFullyApproved: true);

          case VolunteerFormStatus.Rejected1:
            final l10n = AppLocalizations.of(context)!;
            return _buildRejectedScreen(context, l10n.applicationRejected, l10n.applicationRejectedFirstStage);

          case VolunteerFormStatus.Rejected2:
            final l10n = AppLocalizations.of(context)!;
            return _buildRejectedScreen(context, l10n.applicationRejected, l10n.applicationRejectedFinalStage);
        }
      },
    );
  }

  Widget _buildPendingScreen() {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Scaffold(
          appBar: AppBar(automaticallyImplyLeading: false, title: Text(l10n.volunteerDashboard), backgroundColor: Colors.orange),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_empty, size: 80, color: Colors.orange),
                  const SizedBox(height: 24),
                  Text(
                    l10n.applicationUnderReview,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.applicationUnderReviewDesc, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildApprovedDashboard(BuildContext context, VolunteerForm form, String title, String message, {bool isFullyApproved = false}) {
    final userPhone = FirebaseAuth.instance.currentUser?.email?.split('@').first ?? '';

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationsProvider()..loadNotifications(userPhone)),
        ChangeNotifierProvider(create: (_) => ShiftAssignmentProvider()..startListeningToVolunteer(userPhone)),
        ChangeNotifierProvider(create: (_) => VolunteerRatingProvider()),
      ],
      child: _ApprovedDashboardView(form: form, title: title, message: message, isFullyApproved: isFullyApproved, userPhone: userPhone),
    );
  }

  Widget _buildRejectedScreen(BuildContext context, String title, String message) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: Text(l10n.volunteerDashboard), backgroundColor: Colors.red),
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
                label: Text(l10n.signOut),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String message) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: Text(l10n.volunteerDashboard), backgroundColor: Colors.grey),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.grey),
              const SizedBox(height: 24),
              Text(
                l10n.error,
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
                label: Text(l10n.signOut),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApprovedDashboardView extends StatelessWidget {
  final VolunteerForm form;
  final String title;
  final String message;
  final bool isFullyApproved;
  final String userPhone;

  const _ApprovedDashboardView({required this.form, required this.title, required this.message, required this.isFullyApproved, required this.userPhone});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.volunteerDashboard),
        backgroundColor: Colors.green,
        actions: [
          // Notification Bell
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
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInSlide(child: _buildWelcomeHeader(form.fullName)),
            const SizedBox(height: 24),
            // Image Carousel Slider
            FadeInSlide(
              delay: 0.05,
              child: Consumer<CarouselProvider>(
                builder: (context, carouselProvider, child) {
                  final visibleImages = carouselProvider.images.where((img) => img.isVisible).toList();
                  if (visibleImages.isEmpty) {
                    return const SizedBox.shrink(); // Don't show carousel if no images
                  }
                  return ImageCarouselSlider(images: visibleImages, height: 200);
                },
              ),
            ),
            const SizedBox(height: 24),
            if (isFullyApproved) ...[
              const FadeInSlide(
                delay: 0.1,
                child: Text('My Assignments', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              FadeInSlide(
                delay: 0.2,
                child: Consumer<ShiftAssignmentProvider>(
                  builder: (context, assignmentProvider, child) {
                    final assignmentCount = assignmentProvider.assignments.length;
                    return _buildActionCardWithBadge(
                      context,
                      'My Schedule & Locations',
                      'View your upcoming shifts, times, and locations',
                      Icons.calendar_month,
                      Colors.blue,
                      assignmentCount,
                      () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => VolunteerScheduleScreen(volunteerPhone: userPhone)));
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const FadeInSlide(
                delay: 0.3,
                child: Text('Upcoming Shift', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              FadeInSlide(
                delay: 0.4,
                child: Consumer<ShiftAssignmentProvider>(
                  builder: (context, provider, child) {
                    if (provider.assignments.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: Text("No upcoming shifts assigned.")),
                        ),
                      );
                    }
                    return UpcomingShiftCard(assignment: provider.assignments.first);
                  },
                ),
              ),
              const SizedBox(height: 24),
              FadeInSlide(
                delay: 0.5,
                child: Text(l10n.activity, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              FadeInSlide(delay: 0.6, child: VolunteerStatsChart(userPhone: userPhone)),
              const SizedBox(height: 24),
              FadeInSlide(
                delay: 0.7,
                child: Text(l10n.actions, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              FadeInSlide(
                delay: 0.8,
                child: _buildActionCard(context, l10n.myProfile, l10n.viewRatingAndInfo, Icons.person, Colors.teal, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VolunteerProfileScreen(form: form, userPhone: userPhone),
                    ),
                  );
                }),
              ),
              FadeInSlide(
                delay: 0.9,
                child: _buildActionCard(context, l10n.submitFeedback, l10n.reportBugsOrSuggest, Icons.feedback, Colors.orange, () {
                  Navigator.pushNamed(context, '/submit-feedback');
                }),
              ),
            ],
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
            gradient: LinearGradient(colors: [Colors.green.shade800, Colors.green.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Stack(
            children: [
              Positioned(right: -20, top: -20, child: Icon(Icons.volunteer_activism, size: 150, color: Colors.white.withOpacity(0.1))),
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
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green.shade800),
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
                          name ?? l10n.volunteer,
                          style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
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

  Widget _buildActionCard(BuildContext context, String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return _buildActionCardWithBadge(context, title, description, icon, color, 0, onTap);
  }

  Widget _buildActionCardWithBadge(BuildContext context, String title, String description, IconData icon, Color color, int badgeCount, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Icon(icon, color: color, size: 32),
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                        child: Text(
                          badgeCount > 9 ? '9+' : '$badgeCount',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
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
}
