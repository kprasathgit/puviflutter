import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SmartNavigator {
  static void go(BuildContext context, String route) {
    // Handle only if mounted (optional, for safety)
    if (!Navigator.of(context).mounted) return;

    final canPop = Navigator.of(context).canPop();

    if (canPop) {
      Navigator.of(context).pop(); // Pop the dialog first
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go(route); // Navigate after popping
        }
      });
    } else {
      context.go(route);
    }
  }
}
