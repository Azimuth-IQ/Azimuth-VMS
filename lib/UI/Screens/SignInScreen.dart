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
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          height: MediaQuery.of(context).size.height / 2,
          child: Card(
            elevation: 8,
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text("Sign In Screen"),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: 'Phone'),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Handle sign-in logic here
                      signIn(context, phoneController.text, passwordController.text);
                    },
                    child: Text('Sign In'),
                  ),
                  SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () {
                      Seed().seedSystemUsers();
                      Seed().seedLocations();
                    },
                    child: Text("Seed Data"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
