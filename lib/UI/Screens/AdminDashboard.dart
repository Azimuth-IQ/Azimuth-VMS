import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text("Admin Dashboard"),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushNamed(context, '/sign-in');
              },
              child: Text("Sign Out"),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushNamed(context, '/locations-mgmt');
              },
              child: Text("Location Management"),
            ),
          ],
        ),
      ),
    );
  }
}
