import 'dart:async';
import 'package:flutter/material.dart';
import 'package:puvi/src/app.dart';
import 'package:puvi/src/common/storageutil.dart';
import 'package:puvi/src/firebase/firebase.service.dart';
import 'package:puvi/src/notification/notification.controller.dart';
import 'package:puvi/src/notification/notification.service.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_strategy/url_strategy.dart';

late NotificationController notificationController;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase + Notifications before runApp
  await FirebaseService.init();
  // ✅ Setup app-wide Notification Controller
  notificationController = NotificationController(NotificationService());

// ✅ Load cached notifications immediately (non-blocking UI)
  unawaited(notificationController.loadFromCache());

// ✅ Fetch fresh notifications in background
  if (StorageUtil.uid != null) {
    unawaited(
        notificationController.fetchFromNotificationServer(StorageUtil.uid!));
  }

  // ✅ Web routing (remove # in URL)
  setPathUrlStrategy();

  runApp(const MyApp());

  // // ✅ Ask for notification permission AFTER home screen load
  // WidgetsBinding.instance.addPostFrameCallback((_) {
  //   _askNotificationPermission();
  // });

  // ✅ Check for service worker update
  checkForUpdate();
}

/// Request notification permission once home screen is ready
// Future<void> _askNotificationPermission() async {
//   if (html.Notification.supported) {
//     final permission = await html.Notification.requestPermission();
//     if (permission == "granted") {
//       print("✅ Notifications allowed by user");
//     } else {
//       print("❌ Notifications denied by user");
//     }
//   }
// }

/// Checks service worker updates and reloads page if new version is installed
void checkForUpdate() {
  final swContainer = html.window.navigator.serviceWorker;
  if (swContainer != null) {
    swContainer.getRegistration().then((reg) {
      if (reg != null) {
        reg.update();

        // Watch for state changes of the new worker
        final newWorker = reg.installing ?? reg.waiting;
        if (newWorker != null) {
          newWorker.on['statechange'].listen((event) {
            if (newWorker.state == 'activated') {
              // ✅ reload only once after full activation
              html.window.location.reload();
            }
          });
        }
      }
    });
  }
}
