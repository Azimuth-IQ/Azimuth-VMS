/**
 * Cloud Functions for Azimuth VMS
 * Handles push notifications via Firebase Cloud Messaging
 */

const { onValueCreated } = require("firebase-functions/v2/database");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");

// Initialize Firebase Admin SDK with Europe database
admin.initializeApp({
  databaseURL: "https://volunteer-management-sys-1fedf-default-rtdb.europe-west1.firebasedatabase.app",
});

// Set global options
setGlobalOptions({ maxInstances: 10 });

/**
 * Send Push Notification when notification created
 * Triggers: /ihs/systemUsers/{userId}/notifications/{notificationId}
 */
exports.sendPushNotification = onValueCreated(
  {
    ref: "/ihs/systemUsers/{userId}/notifications/{notificationId}",
    instance: "volunteer-management-sys-1fedf-default-rtdb",
    region: "europe-west1",
  },
  async (event) => {
    try {
      const userId = event.params.userId;
      const notificationId = event.params.notificationId;
      const notificationData = event.data.val();

      logger.info("New notification created", {
        userId,
        notificationId,
        data: notificationData,
      });

      // Get user's FCM token
      const tokenRef = `/ihs/systemUsers/${userId}/fcmToken`;
      const tokenSnapshot = await admin.database().ref(tokenRef).once("value");

      const fcmToken = tokenSnapshot.val();

      if (!fcmToken) {
        logger.warn(`No FCM token for user: ${userId}`);
        return null;
      }

      // Prepare push notification
      const message = {
        token: fcmToken,
        notification: {
          title: notificationData.title || "New Notification",
          body: notificationData.message || "",
        },
        data: {
          notificationId: notificationId,
          type: notificationData.type || "Info",
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        webpush: {
          fcmOptions: {
            link: "https://volunteer-management-sys-1fedf.web.app/",
          },
          notification: {
            icon: "/icons/Icon-192.png",
            badge: "/icons/Icon-192.png",
            requireInteraction: false,
          },
        },
      };

      // Send push notification
      const response = await admin.messaging().send(message);

      logger.info("Push notification sent successfully", {
        userId,
        notificationId,
        response,
      });

      return response;
    } catch (error) {
      logger.error("Error sending push notification", {
        error: error.message,
        stack: error.stack,
      });
      return null;
    }
  }
);
