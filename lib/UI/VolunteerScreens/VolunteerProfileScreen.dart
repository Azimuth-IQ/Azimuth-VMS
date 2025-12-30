import 'package:azimuth_vms/Helpers/SystemUserHelperFirebase.dart';
import 'package:azimuth_vms/Models/VolunteerForm.dart';
import 'package:azimuth_vms/Providers/VolunteerRatingProvider.dart';
import 'package:azimuth_vms/UI/Widgets/ChangePasswordScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

class VolunteerProfileScreen extends StatelessWidget {
  final VolunteerForm form;
  final String userPhone;

  const VolunteerProfileScreen({super.key, required this.form, required this.userPhone});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.myProfile),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
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
                child: Row(
                  children: [
                    Icon(Icons.lock_reset, size: 20, color: theme.colorScheme.onSurface),
                    const SizedBox(width: 8),
                    Text(l10n.changePassword),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: theme.colorScheme.onSurface),
                    const SizedBox(width: 8),
                    Text(l10n.signOut),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildRatingSection(context),
              const SizedBox(height: 16),
              _buildInfoSection(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: CircleAvatar(
                radius: isMobile ? 40 : 50,
                backgroundColor: Colors.white,
                child: Text(
                  form.fullName?.substring(0, 1).toUpperCase() ?? '?',
                  style: TextStyle(fontSize: isMobile ? 32 : 40, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
              ),
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              form.fullName ?? l10n.unknownName,
              style: TextStyle(color: Colors.white, fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 6 : 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 6 : 8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.phone, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    form.mobileNumber ?? l10n.noPhone,
                    style: TextStyle(color: Colors.white, fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Consumer<VolunteerRatingProvider>(
      builder: (context, ratingProvider, child) {
        return FutureBuilder(
          future: SystemUserHelperFirebase().GetSystemUserByPhone(userPhone),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()),
              );
            }

            double average = 0.0;
            if (snapshot.hasData && snapshot.data?.volunteerRating != null) {
              average = ratingProvider.getAverageScore(snapshot.data!.volunteerRating!);
            }

            return Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.amber.shade600, size: isMobile ? 20 : 24),
                        const SizedBox(width: 8),
                        Text(l10n.performanceScore, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: isMobile ? 16 : 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          average.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: isMobile ? 44 : 56,
                            fontWeight: FontWeight.bold,
                            color: average >= 4.0 ? Colors.green : (average >= 3.0 ? Colors.amber.shade700 : Colors.red),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text('/ 5.0', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) => Icon(index < average.round() ? Icons.star : Icons.star_border, color: Colors.amber.shade600, size: isMobile ? 24 : 28)),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(20)),
                      child: Text(l10n.basedOnIHSCriteria, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.primary, size: isMobile ? 20 : 24),
                const SizedBox(width: 8),
                Text(l10n.personalInformation, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            child: Column(
              children: [
                _buildInfoRow(l10n.education, form.education, Icons.school_outlined, context),
                const Divider(height: 32),
                _buildInfoRow(l10n.birthDate, form.birthDate, Icons.cake_outlined, context),
                const Divider(height: 32),
                _buildInfoRow(l10n.address, form.currentAddress, Icons.location_on_outlined, context),
                const Divider(height: 32),
                _buildInfoRow(l10n.profession, form.profession, Icons.work_outline, context),
                const Divider(height: 32),
                _buildInfoRow(l10n.jobTitle, form.jobTitle, Icons.badge_outlined, context),
                const Divider(height: 32),
                _buildInfoRow(l10n.department, form.departmentName, Icons.business_outlined, context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value, IconData icon, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: isMobile ? 18 : 20, color: theme.colorScheme.primary),
        ),
        SizedBox(width: isMobile ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w500, letterSpacing: 0.5),
              ),
              const SizedBox(height: 4),
              Text(value ?? l10n.notApplicable, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
