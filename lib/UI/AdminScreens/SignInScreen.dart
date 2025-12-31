import 'package:azimuth_vms/Helpers/SystemUserHelperFirebase.dart';
import 'package:azimuth_vms/Helpers/NotificationPermissionHelper.dart';
import 'package:azimuth_vms/Models/Seed.dart';
import 'package:azimuth_vms/Models/SystemUser.dart';
import 'package:azimuth_vms/Providers/LanguageProvider.dart';
import 'package:azimuth_vms/l10n/app_localizations.dart';
import 'package:azimuth_vms/UI/Theme/Breakpoints.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});

  //Variables
  final TextEditingController phoneController = TextEditingController(text: "07705371953");
  final TextEditingController passwordController = TextEditingController(text: "rootroot");

  //Auth Check
  void checkAuthStatus(BuildContext context) async {
    //1- Check with Firebase Auth
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      print("User is already signed in: ${user.email!.split('@').first}");

      // Request notification permission and save FCM token for already signed-in users
      if (kIsWeb) {
        final hasPermission = await NotificationPermissionHelper.requestPermission();
        if (hasPermission) {
          final phone = user.email!.split('@').first;
          final token = await NotificationPermissionHelper.getAndSaveToken(phone);
          if (token != null) {
            print('✅ FCM token obtained and saved for user: $phone');
          }
        }
      }

      // Check User Role from Database
      SystemUserHelperFirebase systemUserHelperFirebase = SystemUserHelperFirebase();
      SystemUser? systemUser = await systemUserHelperFirebase.GetSystemUserByPhone(user.email!.split('@').first);
      print("Fetched user: ${systemUser?.name}");
      print("User role: ${systemUser?.role}");
      if (systemUser != null) {
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
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: "$phone@azimuth-vms.com", password: password);
      print("Signed in: ${userCredential.user?.uid}");
      // Check User Role from Database
      SystemUserHelperFirebase systemUserHelperFirebase = SystemUserHelperFirebase();
      print("Fetching user with phone: ${userCredential.user?.email}");
      SystemUser? systemUser = await systemUserHelperFirebase.GetSystemUserByPhone(phone);
      print("Fetched user: ${systemUser?.name}");
      print("User role: ${systemUser?.role}");
      if (systemUser != null) {
        // Request notification permission for web (will show browser permission dialog)
        if (kIsWeb) {
          final hasPermission = await NotificationPermissionHelper.requestPermission();
          if (hasPermission) {
            // Get and store FCM token
            final token = await NotificationPermissionHelper.getAndSaveToken(phone);
            if (token != null) {
              print('✅ FCM token obtained and saved for user: $phone');
            }
          }
        }

        if (systemUser.role == SystemUserRole.ADMIN) {
          Navigator.pushReplacementNamed(context, '/admin-dashboard');
        } else if (systemUser.role == SystemUserRole.TEAMLEADER) {
          Navigator.pushReplacementNamed(context, '/teamleaders-dashboard');
        } else if (systemUser.role == SystemUserRole.VOLUNTEER) {
          Navigator.pushReplacementNamed(context, '/volunteer-dashboard');
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    checkAuthStatus(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Language Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
                return PopupMenuButton<Locale>(
                  icon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.language, color: theme.colorScheme.onSurface),
                      const SizedBox(width: 4),
                      Text(
                        languageProvider.isEnglish ? 'EN' : 'AR',
                        style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  onSelected: (locale) async {
                    await languageProvider.setLocale(locale);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: const Locale('en'),
                      child: Row(
                        children: [
                          Icon(Icons.check, color: languageProvider.isEnglish ? theme.colorScheme.primary : Colors.transparent),
                          const SizedBox(width: 8),
                          const Text('English'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: const Locale('ar'),
                      child: Row(
                        children: [
                          Icon(Icons.check, color: !languageProvider.isEnglish ? theme.colorScheme.primary : Colors.transparent),
                          const SizedBox(width: 8),
                          const Text('العربية'),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
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
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                        child: Icon(Icons.volunteer_activism, size: 48, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.appTitle,
                        style: TextStyle(fontSize: Breakpoints.isMobile(context) ? 20 : 28, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                      ),
                      const SizedBox(height: 8),
                      Text(l10n.volunteerManagementSystem, style: TextStyle(fontSize: Breakpoints.isMobile(context) ? 12 : 16, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Sign In Card
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.signIn,
                        style: TextStyle(fontSize: Breakpoints.isMobile(context) ? 18 : 24, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: l10n.phoneNumber,
                          prefixIcon: Icon(Icons.phone, color: theme.colorScheme.primary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: l10n.password,
                          prefixIcon: Icon(Icons.lock, color: theme.colorScheme.primary),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          signIn(context, phoneController.text, passwordController.text);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
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
