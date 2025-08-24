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

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // ✅ Initialize Firebase + Notifications before runApp
//   await FirebaseService.init();

//   // ✅ Setup app-wide Notification Controller
//   notificationController = NotificationController(NotificationService());

// // ✅ Load cached notifications immediately (non-blocking UI)
//   unawaited(notificationController.loadFromCache());

// // ✅ Fetch fresh notifications in background
//   if (StorageUtil.uid != null) {
//     unawaited(
//         notificationController.fetchFromNotificationServer(StorageUtil.uid!));
//   }

//   // ✅ Web routing (remove # in URL)
//   setPathUrlStrategy();

//   runApp(const MyApp());

//   // ✅ Ask permission only after UI is ready
//   WidgetsBinding.instance.addPostFrameCallback((_) {
//      FirebaseService.askNotificationPermission();
//    // NotificationHelper.requestPermission();
//   });

//   // ✅ Check for service worker updatex
//   checkForUpdate();
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Setup NotificationController (independent of Firebase)
  notificationController = NotificationController(NotificationService());

  // ✅ Use clean web URLs (remove #)
  setPathUrlStrategy();

  await FirebaseService.init();

  // ✅ Run UI immediately (no blocking)
  runApp(const MyApp());

  // ✅ Initialize Firebase/Notifications in background (safe)
  unawaited(_initServices());
}

Future<void> _initServices() async {
  try {
    // ✅ Cache notifications immediately
    unawaited(notificationController.loadFromCache());

    // ✅ Fetch server notifications only if user logged in
    if (StorageUtil.uid != null) {
      unawaited(
        notificationController.fetchFromNotificationServer(StorageUtil.uid!),
      );
    }

    // ✅ Ask notification permission only after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseService.askNotificationPermission();
    });

    // ✅ Service worker update check (for PWA)
    checkForUpdate();
  } catch (e, st) {
    debugPrint("🔥 Init services failed: $e");
    debugPrintStack(stackTrace: st);
  }
}

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
