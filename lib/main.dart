import 'package:azimuth_vms/Providers/AppProvider.dart';
import 'package:azimuth_vms/UI/Screens/AdminDashboard.dart';
import 'package:azimuth_vms/UI/Screens/EventsMgmt.dart';
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
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
          scaffoldBackgroundColor: const Color(0xFFF5F7FA),
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
            color: Colors.white,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: false,
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF1A1F36),
            titleTextStyle: TextStyle(color: Color(0xFF1A1F36), fontSize: 24, fontWeight: FontWeight.w600),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)))),
        ),
        home: SignInScreen(),
        routes: {
          '/sign-in': (context) => SignInScreen(),
          '/admin-dashboard': (context) => AdminDashboard(),
          '/locations-mgmt': (context) => LocationsMgmt(),
          '/teams-mgmt': (context) => TeamsMgmt(),
          '/event-mgmt': (context) => EventsMgmt(),
        },
      ),
    );
  }
}
