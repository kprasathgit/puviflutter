import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SmartNavigator {
  static void go(BuildContext context, String route) {
    if (!context.mounted) return;

    final nav = Navigator.of(context);

    if (nav.canPop()) {
      nav.pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Future.microtask(() => context.go(route));
        }
      });
    } else {
      Future.microtask(() {
        if (context.mounted) context.go(route);
      });
    }
  }
}
