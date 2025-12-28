import 'package:azimuth_vms/Helpers/SystemUserHelperFirebase.dart';
import 'package:azimuth_vms/Models/Seed.dart';
import 'package:azimuth_vms/Models/SystemUser.dart';
import 'package:azimuth_vms/UI/Theme/ThemeProvider.dart';
import 'package:azimuth_vms/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});

  //Variables
  final TextEditingController phoneController = TextEditingController(text: "07705371953");
  final TextEditingController passwordController = TextEditingController(text: "rootroot");

  //Auth Check
  void checkAuthStatus(BuildContext context) async {
    //1- Check with Firebase Auth
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    if (user != null) {
      print("User is already signed in: ${user.email!.split('@').first}");
      // Check User Role from Database
      final SystemUserHelperFirebase systemUserHelperFirebase = SystemUserHelperFirebase();
      final SystemUser? systemUser = await systemUserHelperFirebase.GetSystemUserByPhone(user.email!.split('@').first);
      print("Fetched user: ${systemUser?.name}");
      print("User role: ${systemUser?.role}");
      if (systemUser != null) {
        // Set theme based on user role
        final ThemeProvider themeProvider = context.read<ThemeProvider>();
        final UserRole userRole = _mapSystemUserRoleToUserRole(systemUser.role);
        themeProvider.setThemeByRole(userRole);
        
        //TODO: Implement Teamleader and Volunteer Dashboards
        //TODO: Implement Current User Provider
        if (systemUser.role == SystemUserRole.ADMIN) {
          Navigator.pushReplacementNamed(context, '/admin-dashboard');
        } else if (systemUser.role == SystemUserRole.TEAMLEADER) {
          Navigator.pushReplacementNamed(context, '/teamleaders-dashboard');
        } else if (systemUser.role == SystemUserRole.VOLUNTEER) {
          Navigator.pushReplacementNamed(context, '/volunteer-dashboard');
        }
      }
    } else {
      print("No user is signed in.");
    }
  }

  //SignIn
  void signIn(BuildContext context, String phone, String password) async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: "$phone@azimuth-vms.com", password: password);
      print("Signed in: ${userCredential.user?.uid}");
      // Check User Role from Database
      final SystemUserHelperFirebase systemUserHelperFirebase = SystemUserHelperFirebase();
      print("Fetching user with phone: ${userCredential.user?.email}");
      final SystemUser? systemUser = await systemUserHelperFirebase.GetSystemUserByPhone(phone);
      print("Fetched user: ${systemUser?.name}");
      print("User role: ${systemUser?.role}");
      if (systemUser != null) {
        // Set theme based on user role
        final ThemeProvider themeProvider = context.read<ThemeProvider>();
        final UserRole userRole = _mapSystemUserRoleToUserRole(systemUser.role);
        themeProvider.setThemeByRole(userRole);
        
        if (systemUser.role == SystemUserRole.ADMIN) {
          Navigator.pushReplacementNamed(context, '/admin-dashboard');
        } else if (systemUser.role == SystemUserRole.TEAMLEADER) {
          Navigator.pushReplacementNamed(context, '/teamleaders-dashboard');
        } else if (systemUser.role == SystemUserRole.VOLUNTEER) {
          Navigator.pushReplacementNamed(context, '/volunteer-dashboard');
        }
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code}');
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }
  
  /// Map SystemUserRole to UserRole enum
  UserRole _mapSystemUserRoleToUserRole(SystemUserRole role) {
    switch (role) {
      case SystemUserRole.ADMIN:
        return UserRole.admin;
      case SystemUserRole.TEAMLEADER:
        return UserRole.teamLeader;
      case SystemUserRole.VOLUNTEER:
        return UserRole.volunteer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    checkAuthStatus(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo/Title Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.volunteer_activism, size: 48, color: Colors.blue),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.appTitle,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1F36)),
                      ),
                      const SizedBox(height: 8),
                      Text(l10n.volunteerManagementSystem, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Sign In Card
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.signIn,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36)),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: phoneController,
                        decoration: InputDecoration(labelText: l10n.phoneNumber, prefixIcon: const Icon(Icons.phone)),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(labelText: l10n.password, prefixIcon: const Icon(Icons.lock)),
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          signIn(context, phoneController.text, passwordController.text);
                        },
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: Text(l10n.signIn, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Development Tools
                if (true) // Set to false in production
                  TextButton.icon(
                    onPressed: () {
                      Seed().seedSystemUsers();
                      Seed().seedLocations();
                    },
                    icon: const Icon(Icons.storage, size: 18),
                    label: Text(l10n.seedDevelopmentData),
                    style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
