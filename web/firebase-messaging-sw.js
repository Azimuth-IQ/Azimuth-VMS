// Firebase Cloud Messaging Service Worker
// This file handles background notifications for the web app

importScripts("https://www.gstatic.com/firebasejs/9.6.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.6.1/firebase-messaging-compat.js");

// Initialize Firebase in the service worker
// Configuration from firebase_options.dart
firebase.initializeApp({
  apiKey: "AIzaSyC38DQ8KDYrnfChkVejZ8SDhBRaDlRKAyY",
  authDomain: "volunteer-management-sys-1fedf.firebaseapp.com",
  databaseURL: "https://volunteer-management-sys-1fedf-default-rtdb.europe-west1.firebasedatabase.app",
  projectId: "volunteer-management-sys-1fedf",
  storageBucket: "volunteer-management-sys-1fedf.firebasestorage.app",
  messagingSenderId: "224418209100",
  appId: "1:224418209100:web:cdb2150c84e7f4f8fd03e9",
  measurementId: "G-XM1CDER018",
});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage(function (payload) {
  console.log("[firebase-messaging-sw.js] Received background message:", payload);

  const notificationTitle = payload.notification.title || "Azimuth VMS Notification";
  const notificationOptions = {
    body: payload.notification.body || "",
    icon: "/icons/Icon-192.png",
    badge: "/icons/Icon-192.png",
    data: payload.data,
    requireInteraction: true, // Keep notification visible until user interacts
    actions: [
      {
        action: "view",
        title: "View Details",
      },
      {
        action: "dismiss",
        title: "Dismiss",
      },
    ],
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handle notification clicks
self.addEventListener("notificationclick", function (event) {
  console.log("[firebase-messaging-sw.js] Notification click:", event.action);

  event.notification.close();

  if (event.action === "view") {
    // Open the app to the relevant page based on notification data
    const urlToOpen = event.notification.data?.url || "/";
    event.waitUntil(clients.openWindow(urlToOpen));
  }
  // If action is 'dismiss', just close (already done above)
});
