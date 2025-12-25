import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NotificationPermissionHelper {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

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
      String? token = await _messaging.getToken(
        vapidKey: 'YOUR_VAPID_KEY_HERE', // TODO: Replace with actual VAPID key from Firebase console
      );
      print('FCM Token: $token');
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
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
