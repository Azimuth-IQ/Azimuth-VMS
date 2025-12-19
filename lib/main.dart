import 'package:azimuth_vms/Providers/AppProvider.dart';
import 'package:azimuth_vms/UI/Screens/AdminDashboard.dart';
import 'package:azimuth_vms/UI/Screens/LocationsMgmt.dart';
import 'package:azimuth_vms/UI/Screens/SignInScreen.dart';
import 'package:azimuth_vms/UI/Screens/TeamsMgmt.dart';
import 'package:azimuth_vms/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for async operations in main
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider<AppProvider>(create: (_) => AppProvider())],
      child: MaterialApp(
        title: 'Azimuth VMS',
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent)),
        home: SignInScreen(),
        routes: {
          '/sign-in': (context) => SignInScreen(),
          '/admin-dashboard': (context) => AdminDashboard(),
          '/locations-mgmt': (context) => LocationsMgmt(),
          '/teams-mgmt': (context) => TeamsMgmt(),
        },
      ),
    );
  }
}
