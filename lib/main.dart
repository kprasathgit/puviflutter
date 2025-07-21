import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';
import 'dart:html' as html;
import 'dart:async';

import 'src/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  runApp(MyApp());

  // Start update check after app is rendered
  checkForUpdate();
}

/// Checks for service worker updates and reloads the page if a new version is found.
void checkForUpdate() {
  final swContainer = html.window.navigator.serviceWorker;
  if (swContainer != null) {
    swContainer.getRegistration().then((reg) {
      if (reg != null) {
        reg.update(); // Ask browser to check for new service worker

        final newWorker = reg.installing ?? reg.waiting;
        if (newWorker != null) {
          // Polling method because dart:html lacks onStateChange
          Timer.periodic(const Duration(seconds: 1), (timer) {
            print("Checking service worker state: ${newWorker.state}");
            if (newWorker.state == 'installed') {
              timer.cancel();
              print("New version detected. Reloading...");
              html.window.location.reload(); // Force reload with updated files
            }

            // Safety timeout: stop polling after 10 seconds
            if (timer.tick >= 10) {
              timer.cancel();
              print("Stopped polling after 10 seconds.");
            }
          });
        }
      }
    });
  }
}
