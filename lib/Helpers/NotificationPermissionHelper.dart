import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NotificationPermissionHelper {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Request permission for browser notifications (web only)
  static Future<bool> requestPermission() async {
    if (!kIsWeb) {
      print('Notification permission is only required for web platform');
      return false;
    }

    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('User notification permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted notification permission');
        return true;
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('User granted provisional notification permission');
        return true;
      } else {
        print('User declined or has not accepted notification permission');
        return false;
      }
    } catch (e) {
      print('Error requesting notification permission: $e');
      return false;
    }
  }

  // Get FCM token for this device/browser
  static Future<String?> getToken() async {
    if (!kIsWeb) {
      print('FCM token is only needed for web platform');
      return null;
    }

    try {
      String? token = await _messaging.getToken(vapidKey: 'BDEQjN1UbATEWI8TY1tTHakqvCw5EpryE6OGIirk4hqBG7CCLO-0O0eL97nVmEAKa6Ms7EoI9MaezpKndlgeOHs');
      print('FCM Token: $token');
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Save FCM token to Firebase for a specific user
  static Future<void> saveTokenToDatabase(String userPhone, String token) async {
    try {
      await _dbRef.child('ihs/systemusers/$userPhone/fcmToken').set(token);
      await _dbRef.child('ihs/systemusers/$userPhone/fcmTokenUpdatedAt').set(DateTime.now().toIso8601String());
      print('✅ FCM token saved to database for user: $userPhone');
    } catch (e) {
      print('❌ Error saving FCM token to database: $e');
    }
  }

  // Get FCM token for a specific user from database
  static Future<String?> getTokenFromDatabase(String userPhone) async {
    try {
      final snapshot = await _dbRef.child('ihs/systemusers/$userPhone/fcmToken').get();
      if (snapshot.exists) {
        return snapshot.value as String?;
      }
      return null;
    } catch (e) {
      print('Error getting FCM token from database: $e');
      return null;
    }
  }

  // Get FCM token and save it to database for current user
  static Future<String?> getAndSaveToken(String userPhone) async {
    final token = await getToken();
    if (token != null) {
      await saveTokenToDatabase(userPhone, token);
    }
    return token;
  }

  // Listen to foreground messages
  static void setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.messageId}');

      if (message.notification != null) {
        print('Message notification: ${message.notification!.title}');
        print('Message body: ${message.notification!.body}');
      }

      if (message.data.isNotEmpty) {
        print('Message data: ${message.data}');
      }
    });
  }

  // Handle background messages (must be top-level function)
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('Handling background message: ${message.messageId}');

    if (message.notification != null) {
      print('Background notification: ${message.notification!.title}');
    }
  }

  // Setup background message handler
  static void setupBackgroundMessageHandler() {
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  // Handle notification taps (when user clicks on notification)
  static void setupMessageOpenedHandler(Function(RemoteMessage) onMessageOpened) {
    // Handle when app is opened from a notification (when app was in background)
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpened);

    // Handle when app is opened from a notification (when app was terminated)
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        onMessageOpened(message);
      }
    });
  }

  // Check current permission status
  static Future<AuthorizationStatus> getPermissionStatus() async {
    NotificationSettings settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus;
  }

  // Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    AuthorizationStatus status = await getPermissionStatus();
    return status == AuthorizationStatus.authorized || status == AuthorizationStatus.provisional;
  }
}
