import 'package:azimuth_vms/Helpers/SystemUserHelperFirebase.dart';
import 'package:azimuth_vms/Models/Seed.dart';
import 'package:azimuth_vms/Models/SystemUser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      // Check User Role from Database
      SystemUserHelperFirebase systemUserHelperFirebase = SystemUserHelperFirebase();
      SystemUser? systemUser = await systemUserHelperFirebase.GetSystemUserByPhone(user.email!.split('@').first);
      print("Fetched user: ${systemUser?.name}");
      print("User role: ${systemUser?.role}");
      if (systemUser != null) {
        //TODO: Implement Teamleader and Volunteer Dashboards
        //TODO: Implement Current User Provider
        if (systemUser.role == SystemUserRole.ADMIN) {
          Navigator.pushNamed(context, '/admin-dashboard');
        }
      }
    } else {}
  }

  //SignIn
  void signIn(BuildContext context, String phone, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: phone + "@azimuth-vms.com", password: password);
      print("Signed in: ${userCredential.user?.uid}");
      // Check User Role from Database
      SystemUserHelperFirebase systemUserHelperFirebase = SystemUserHelperFirebase();
      print("Fetching user with phone: ${userCredential.user?.email}");
      SystemUser? systemUser = await systemUserHelperFirebase.GetSystemUserByPhone(phone);
      print("Fetched user: ${systemUser?.name}");
      print("User role: ${systemUser?.role}");
      if (systemUser != null) {
        //TODO: Implement Teamleader and Volunteer Dashboards
        if (systemUser.role == SystemUserRole.ADMIN) {
          Navigator.pushNamed(context, '/admin-dashboard');
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
                      const Text(
                        'Azimuth VMS',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1F36)),
                      ),
                      const SizedBox(height: 8),
                      Text('Volunteer Management System', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
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
                      const Text(
                        'Sign In',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36)),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          signIn(context, phoneController.text, passwordController.text);
                        },
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
                    label: const Text('Seed Development Data'),
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
