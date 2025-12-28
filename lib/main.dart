import 'package:azimuth_vms/Providers/AppProvider.dart';
import 'package:azimuth_vms/Providers/EventsProvider.dart';
import 'package:azimuth_vms/Providers/ShiftAssignmentProvider.dart';
import 'package:azimuth_vms/Providers/NotificationsProvider.dart';
import 'package:azimuth_vms/Providers/LanguageProvider.dart';
import 'package:azimuth_vms/Providers/VolunteerRatingProvider.dart';
import 'package:azimuth_vms/Providers/SystemFeedbackProvider.dart';
import 'package:azimuth_vms/Providers/VolunteerEventFeedbackProvider.dart';
import 'package:azimuth_vms/Providers/VolunteersProvider.dart';
import 'package:azimuth_vms/Providers/TeamLeadersProvider.dart';
import 'package:azimuth_vms/Providers/TeamsProvider.dart';
import 'package:azimuth_vms/Providers/LocationsProvider.dart';
import 'package:azimuth_vms/Providers/CarouselProvider.dart';
import 'package:azimuth_vms/UI/Theme/ThemeProvider.dart';
import 'package:azimuth_vms/UI/AdminScreens/AdminDashboard.dart';
import 'package:azimuth_vms/UI/AdminScreens/EventsMgmt.dart';
import 'package:azimuth_vms/UI/AdminScreens/FormFillPage.dart' as Admin;
import 'package:azimuth_vms/UI/AdminScreens/FormMgmt.dart';
import 'package:azimuth_vms/UI/AdminScreens/LocationsMgmt.dart';
import 'package:azimuth_vms/UI/AdminScreens/SignInScreen.dart';
import 'package:azimuth_vms/UI/AdminScreens/TeamsMgmt.dart';
import 'package:azimuth_vms/UI/AdminScreens/TeamLeadersMgmt.dart';
import 'package:azimuth_vms/UI/AdminScreens/VolunteersMgmt.dart';
import 'package:azimuth_vms/UI/AdminScreens/ShiftAssignmentScreen.dart';
import 'package:azimuth_vms/UI/AdminScreens/PresenceCheckScreen.dart';
import 'package:azimuth_vms/UI/AdminScreens/SendNotificationScreen.dart';
import 'package:azimuth_vms/UI/AdminScreens/VolunteerRatingScreen.dart';
import 'package:azimuth_vms/UI/AdminScreens/VolunteerWorkflowScreen.dart';
import 'package:azimuth_vms/UI/AdminScreens/CarouselManagementScreen.dart';
import 'package:azimuth_vms/Models/VolunteerForm.dart';
import 'package:azimuth_vms/UI/AdminScreens/RatingCriteriaManagementScreen.dart';
import 'package:azimuth_vms/UI/AdminScreens/ManageFeedbackScreen.dart';
import 'package:azimuth_vms/UI/AdminScreens/EventFeedbackReportScreen.dart';
import 'package:azimuth_vms/UI/Shared/SubmitFeedbackScreen.dart';
import 'package:azimuth_vms/UI/VolunteerScreens/SubmitEventFeedbackScreen.dart';
import 'package:azimuth_vms/UI/TeamLeadersScreens/TeamleaderDashboard.dart';
import 'package:azimuth_vms/UI/TeamLeadersScreens/TeamLeaderShiftManagementScreen.dart';
import 'package:azimuth_vms/UI/TeamLeadersScreens/LeaveRequestManagementScreen.dart';
import 'package:azimuth_vms/UI/TeamLeadersScreens/TeamLeaderPresenceCheckScreen.dart';
import 'package:azimuth_vms/UI/VolunteerScreens/VolunteersDashboard.dart';
import 'package:azimuth_vms/UI/VolunteerScreens/FormFillPage.dart' as Volunteer;
import 'package:azimuth_vms/UI/VolunteerScreens/VolunteerEventDetailsScreen.dart';
import 'package:azimuth_vms/UI/VolunteerScreens/LeaveRequestScreen.dart';
import 'package:azimuth_vms/firebase_options.dart';
import 'package:azimuth_vms/Helpers/SystemUserHelperFirebase.dart';
import 'package:azimuth_vms/Models/SystemUser.dart';
import 'package:azimuth_vms/Models/Event.dart';
import 'package:azimuth_vms/Models/ShiftAssignment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:azimuth_vms/l10n/app_localizations.dart';

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
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<LanguageProvider>(create: (_) => LanguageProvider()),
        ChangeNotifierProvider<AppProvider>(create: (_) => AppProvider()),
        ChangeNotifierProvider<EventsProvider>(create: (_) => EventsProvider()),
        ChangeNotifierProvider<ShiftAssignmentProvider>(create: (_) => ShiftAssignmentProvider()),
        ChangeNotifierProvider<NotificationsProvider>(create: (_) => NotificationsProvider()),
        ChangeNotifierProvider<VolunteerRatingProvider>(create: (_) => VolunteerRatingProvider()),
        ChangeNotifierProvider<SystemFeedbackProvider>(create: (_) => SystemFeedbackProvider()),
        ChangeNotifierProvider<VolunteerEventFeedbackProvider>(create: (_) => VolunteerEventFeedbackProvider()),
        ChangeNotifierProvider<CarouselProvider>(create: (_) => CarouselProvider()),
        // Add missing providers for Dashboard stats
        ChangeNotifierProvider<VolunteersProvider>(create: (_) => VolunteersProvider()),
        ChangeNotifierProvider<TeamLeadersProvider>(create: (_) => TeamLeadersProvider()),
        ChangeNotifierProvider<TeamsProvider>(create: (_) => TeamsProvider()),
        ChangeNotifierProvider<LocationsProvider>(create: (_) => LocationsProvider()),
      ],
      child: Consumer2<LanguageProvider, ThemeProvider>(
        builder: (context, languageProvider, themeProvider, child) => MaterialApp(
          title: 'Azimuth VMS',
          debugShowCheckedModeBanner: false,
          locale: languageProvider.currentLocale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('ar')],
          theme: themeProvider.currentTheme,
          home: SignInScreen(),
          onGenerateRoute: (settings) => _generateRoute(settings),
        ),
      ),
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    // Public routes (no authentication required)
    if (settings.name == '/sign-in' || settings.name == '/') {
      return MaterialPageRoute(builder: (_) => SignInScreen());
    }

    // Protected routes - require authentication
    return MaterialPageRoute(
      settings: settings, // Pass settings so ModalRoute can access arguments
      builder: (_) => AuthGuard(routeName: settings.name ?? '', arguments: settings.arguments),
    );
  }
}

class AuthGuard extends StatefulWidget {
  final String routeName;
  final Object? arguments;

  const AuthGuard({super.key, required this.routeName, this.arguments});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool _isLoading = true;
  Widget? _authorizedWidget;

  @override
  void initState() {
    super.initState();
    _checkAuthorization();
  }

  Future<void> _checkAuthorization() async {
    try {
      // Check if user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user authenticated, redirecting to sign-in');
        if (mounted) {
          setState(() {
            _authorizedWidget = SignInScreen();
            _isLoading = false;
          });
        }
        return;
      }

      // Get user role from database
      final phone = user.email!.split('@').first;
      final systemUserHelper = SystemUserHelperFirebase();
      final systemUser = await systemUserHelper.GetSystemUserByPhone(phone);

      if (systemUser == null) {
        print('User not found in database');
        if (mounted) {
          setState(() {
            _authorizedWidget = _buildUnauthorizedScreen('User not found');
            _isLoading = false;
          });
        }
        return;
      }

      // Check if user has permission for this route
      final authorizedWidget = _getAuthorizedWidget(widget.routeName, systemUser.role, widget.arguments);

      if (mounted) {
        setState(() {
          _authorizedWidget = authorizedWidget;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error checking authorization: $e');
      if (mounted) {
        setState(() {
          _authorizedWidget = _buildUnauthorizedScreen('Authorization error');
          _isLoading = false;
        });
      }
    }
  }

  Widget? _getAuthorizedWidget(String routeName, SystemUserRole role, Object? arguments) {
    // Define route permissions
    const adminRoutes = [
      '/admin-dashboard',
      '/locations-mgmt',
      '/teams-mgmt',
      '/team-leaders-mgmt',
      '/event-mgmt',
      '/volunteers-mgmt',
      '/form-mgmt',
      '/admin-form-fill',
      '/shift-assignment',
      '/presence-check-admin',
      '/volunteer-rating',
      '/rating-criteria-management',
      '/manage-feedback',
      '/event-feedback-report',
      '/submit-feedback',
      '/send-notification',
      '/leave-request-management',
      '/carousel-management',
      '/volunteer-workflow',
    ];

    const teamLeaderRoutes = ['/teamleaders-dashboard', '/teamleader-shift-management', '/leave-request-management', '/presence-check-teamleader', '/submit-feedback'];

    const volunteerRoutes = ['/volunteer-dashboard', '/form-fill', '/volunteer/events', '/volunteer/leave-request', '/submit-feedback', '/submit-event-feedback'];

    // Check permissions
    bool hasPermission = false;

    if (role == SystemUserRole.ADMIN && adminRoutes.contains(routeName)) {
      hasPermission = true;
    } else if (role == SystemUserRole.TEAMLEADER && teamLeaderRoutes.contains(routeName)) {
      hasPermission = true;
    } else if (role == SystemUserRole.VOLUNTEER && volunteerRoutes.contains(routeName)) {
      hasPermission = true;
    }

    if (!hasPermission) {
      print('User role $role does not have permission for route $routeName');
      return _buildUnauthorizedScreen('Access denied');
    }

    // Return the appropriate widget based on route
    switch (routeName) {
      // Admin routes
      case '/admin-dashboard':
        return const AdminDashboard();
      case '/locations-mgmt':
        return const LocationsMgmt();
      case '/teams-mgmt':
        return const TeamsMgmt();
      case '/team-leaders-mgmt':
        return const TeamLeadersMgmt();
      case '/send-notification':
        return const SendNotificationScreen();
      case '/leave-request-management':
        return const LeaveRequestManagementScreen();
      case '/event-mgmt':
        return const EventsMgmt();
      case '/volunteers-mgmt':
        return const VolunteersMgmt();
      case '/form-mgmt':
        return const FormMgmt();
      case '/admin-form-fill':
        // Arguments will be passed via ModalRoute, no need to pass here
        return const Admin.FormFillPage();
      case '/volunteer-workflow':
        if (arguments is VolunteerForm) {
          return VolunteerWorkflowScreen(form: arguments as VolunteerForm);
        }
        return _buildUnauthorizedScreen('Invalid arguments');
      case '/shift-assignment':
        return const ShiftAssignmentScreen();
      case '/presence-check-admin':
        return const PresenceCheckScreen();
      case '/volunteer-rating':
        return const VolunteerRatingScreen();
      case '/rating-criteria-management':
        return const RatingCriteriaManagementScreen();
      case '/manage-feedback':
        return const ManageFeedbackScreen();
      case '/event-feedback-report':
        return const EventFeedbackReportScreen();
      case '/submit-feedback':
        return SubmitFeedbackScreen();
      case '/carousel-management':
        return const CarouselManagementScreen();

      // Team Leader routes
      case '/teamleaders-dashboard':
        return const TeamleaderDashboard();
      case '/teamleader-shift-management':
        return const TeamLeaderShiftManagementScreen();
      case '/leave-request-management':
        return const LeaveRequestManagementScreen();
      case '/presence-check-teamleader':
        return const TeamLeaderPresenceCheckScreen();

      // Volunteer routes
      case '/volunteer-dashboard':
        return const VolunteersDashboard();
      case '/form-fill':
        return Volunteer.FormFillPage();
      case '/volunteer/events':
        return const VolunteerEventDetailsScreen();
      case '/volunteer/leave-request':
        if (arguments is Map<String, dynamic>) {
          return LeaveRequestScreen(event: arguments['event'] as Event, shift: arguments['shift'] as EventShift, assignment: arguments['assignment'] as ShiftAssignment);
        }
        return _buildUnauthorizedScreen('Invalid arguments');
      case '/submit-event-feedback':
        if (arguments is Map<String, dynamic>) {
          return SubmitEventFeedbackScreen(event: arguments['event'] as Event, assignment: arguments['assignment'] as ShiftAssignment);
        }
        return _buildUnauthorizedScreen('Invalid arguments');

      default:
        return _buildUnauthorizedScreen('Route not found');
    }
  }

  Widget _buildUnauthorizedScreen(String message) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: const Text('Access Denied')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, size: 80, color: Colors.red),
              const SizedBox(height: 24),
              const Text('Access Denied', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(message, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/sign-in');
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _authorizedWidget ?? _buildUnauthorizedScreen('Unknown error');
  }
}
