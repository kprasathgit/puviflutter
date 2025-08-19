// ✅ Firebase SW: Web Push Notifications
importScripts('https://www.gstatic.com/firebasejs/9.22.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.1/firebase-messaging-compat.js');

// Initialize Firebase
firebase.initializeApp({
  apiKey: "AIzaSyB2tfj5_CYQu1r-l3xgImktqhrrUmWjBhU",
  authDomain: "puvipure.firebaseapp.com",
  projectId: "puvipure",
  storageBucket: "puvipure.firebasestorage.app",
  messagingSenderId: "670887899005",
  appId: "1:670887899005:web:e90d985b86d8e577bb2614",
  measurementId: "G-Z00FGBXVP3"
});

// Get Firebase Messaging instance
const messaging = firebase.messaging();

// ✅ Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Background message:', payload);

  const notificationTitle = payload.notification?.title || "PuviPure";
  const notificationOptions = {
    body: payload.notification?.body || "New update from PuviPure",
    icon: 'assets/icons/appicon.png',
    data: payload.data || {}, // Pass data for click handling
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});

// ✅ Handle notification clicks
self.addEventListener("notificationclick", (event) => {
  console.log("[firebase-messaging-sw.js] Notification click:", event);

  event.notification.close();
  const targetUrl = event.notification.data?.click_action || "/";

  event.waitUntil(
    clients.matchAll({ type: "window", includeUncontrolled: true }).then((clientList) => {
      for (const client of clientList) {
        if (client.url === targetUrl && "focus" in client) {
          return client.focus();
        }
      }
      if (clients.openWindow) {
        return clients.openWindow(targetUrl);
      }
    })
  );
});
