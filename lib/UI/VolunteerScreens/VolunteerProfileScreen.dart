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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(l10n.myProfile),
        backgroundColor: Colors.grey[50],
        elevation: 0,
        foregroundColor: Colors.black87,
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green.shade700, Colors.green.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Text(
                form.fullName?.substring(0, 1).toUpperCase() ?? '?',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.green.shade700),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            form.fullName ?? l10n.unknownName,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.phone, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  form.mobileNumber ?? l10n.noPhone,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber.shade600, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        l10n.performanceScore,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        average.toStringAsFixed(1),
                        style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: average >= 4.0 ? Colors.green : (average >= 3.0 ? Colors.amber.shade700 : Colors.red)),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text('/ 5.0', style: TextStyle(fontSize: 20, color: Colors.grey)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) => Icon(index < average.round() ? Icons.star : Icons.star_border, color: Colors.amber.shade600, size: 28)),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      l10n.basedOnIHSCriteria,
                      style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.green.shade700, size: 24),
                const SizedBox(width: 8),
                Text(l10n.personalInformation, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 20, color: Colors.green.shade700),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 12, letterSpacing: 0.5),
              ),
              const SizedBox(height: 4),
              Text(
                value ?? l10n.notApplicable,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
