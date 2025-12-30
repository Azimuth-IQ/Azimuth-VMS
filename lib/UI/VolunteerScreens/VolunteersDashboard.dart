import 'package:azimuth_vms/Helpers/VolunteerFormHelperFirebase.dart';
import 'package:azimuth_vms/Models/VolunteerForm.dart';
import 'package:azimuth_vms/Providers/CarouselProvider.dart';
import 'package:azimuth_vms/Providers/LanguageProvider.dart';
import 'package:azimuth_vms/Providers/NotificationsProvider.dart';
import 'package:azimuth_vms/Providers/ShiftAssignmentProvider.dart';
import 'package:azimuth_vms/Providers/VolunteerRatingProvider.dart';
import 'package:azimuth_vms/UI/Widgets/ImageCarouselSlider.dart';
import 'package:azimuth_vms/UI/Widgets/LanguageSwitcher.dart';
import 'package:azimuth_vms/UI/Widgets/NotificationPanel.dart';
import 'package:azimuth_vms/UI/Theme/Breakpoints.dart';
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
        ChangeNotifierProvider(create: (_) => CarouselProvider()..startListening()),
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: Text(l10n.volunteerDashboard), backgroundColor: theme.colorScheme.surface),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: theme.colorScheme.onSurface.withOpacity(0.3)),
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;

        final body = SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image Carousel Slider
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
              if (isFullyApproved) ...[
                // 2. Upcoming Shifts
                FadeInSlide(
                  delay: 0.1,
                  child: Text(
                    l10n.upcomingShift,
                    style: TextStyle(fontSize: Breakpoints.isMobile(context) ? 13 : 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                FadeInSlide(
                  delay: 0.15,
                  child: Consumer<ShiftAssignmentProvider>(
                    builder: (context, provider, child) {
                      if (provider.assignments.isEmpty) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(child: Text(l10n.noUpcomingShifts)),
                          ),
                        );
                      }
                      return UpcomingShiftCard(assignment: provider.assignments.first);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // 3. My Assignments
                FadeInSlide(
                  delay: 0.2,
                  child: Text(
                    l10n.myAssignments,
                    style: TextStyle(fontSize: Breakpoints.isMobile(context) ? 13 : 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                FadeInSlide(
                  delay: 0.25,
                  child: Consumer<ShiftAssignmentProvider>(
                    builder: (context, assignmentProvider, child) {
                      final assignmentCount = assignmentProvider.assignments.length;
                      return _buildActionCardWithBadge(context, l10n.myScheduleLocations, l10n.viewUpcomingShifts, Icons.calendar_month, Colors.blue, assignmentCount, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider.value(
                              value: assignmentProvider,
                              child: VolunteerScheduleScreen(volunteerPhone: userPhone),
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // 4. Activities
                FadeInSlide(
                  delay: 0.3,
                  child: Text(
                    l10n.activity,
                    style: TextStyle(fontSize: Breakpoints.isMobile(context) ? 13 : 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                FadeInSlide(delay: 0.35, child: VolunteerStatsChart(userPhone: userPhone)),
                SizedBox(height: isDesktop ? 24 : 80), // Extra space for bottom navigation on mobile
              ],
            ],
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
                      case 1: // Schedule
                        Navigator.push(context, MaterialPageRoute(builder: (context) => VolunteerScheduleScreen(volunteerPhone: userPhone)));
                        break;
                      case 2: // Profile
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VolunteerProfileScreen(form: form, userPhone: userPhone),
                          ),
                        );
                        break;
                      case 3: // Feedback
                        Navigator.pushNamed(context, '/submit-feedback');
                        break;
                      case 4: // Language
                        _showLanguageDialog(context);
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
                    NavigationRailDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: Text(l10n.mySchedule)),
                    NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text(l10n.profile)),
                    NavigationRailDestination(icon: Icon(Icons.feedback_outlined), selectedIcon: Icon(Icons.feedback), label: Text(l10n.submitFeedback)),
                    NavigationRailDestination(icon: Icon(Icons.language), selectedIcon: Icon(Icons.language), label: Text(l10n.language)),
                  ],
                  trailing: Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(icon: const Icon(Icons.logout), onPressed: () => _showLogoutDialog(context), tooltip: l10n.signOut),
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
                        title: Text(l10n.volunteerDashboard),
                        backgroundColor: theme.scaffoldBackgroundColor,
                        elevation: 0,
                        foregroundColor: theme.colorScheme.onSurface,
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
              title: Text(l10n.dashboard),
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              foregroundColor: theme.colorScheme.onSurface,
              actions: [
                const LanguageSwitcher(showLabel: false, isIconButton: true),
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
              ],
            ),
            body: body,
            bottomNavigationBar: _buildBottomNavigation(context, form),
          );
        }
      },
    );
  }

  Widget _buildBottomNavigation(BuildContext context, VolunteerForm form) {
    final theme = Theme.of(context);
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
      currentIndex: 0,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (index) {
        switch (index) {
          case 0:
            // Already on dashboard
            break;
          case 1:
            Navigator.push(context, MaterialPageRoute(builder: (context) => VolunteerScheduleScreen(volunteerPhone: userPhone)));
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VolunteerProfileScreen(form: form, userPhone: userPhone),
              ),
            );
            break;
          case 3:
            Navigator.pushNamed(context, '/submit-feedback');
            break;
          case 4:
            _showLanguageDialog(context);
            break;
          case 5:
            _showLogoutDialog(context);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.feedback), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.language), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.logout), label: ''),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = context.read<LanguageProvider>();
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('English'),
              trailing: languageProvider.isEnglish ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
              onTap: () async {
                await languageProvider.setLocale(const Locale('en'));
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('العربية'),
              trailing: languageProvider.isArabic ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
              onTap: () async {
                await languageProvider.setLocale(const Locale('ar'));
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.signOut),
        content: Text(l10n.areYouSureSignOut),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/sign-in');
            },
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
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
                    Text(
                      title,
                      style: TextStyle(fontSize: Breakpoints.isMobile(context) ? 12 : 18, fontWeight: FontWeight.bold),
                    ),
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
