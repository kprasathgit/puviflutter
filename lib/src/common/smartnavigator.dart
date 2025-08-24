import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SmartNavigator {
  static void go(BuildContext context, String route,
      {Map<String, String>? params}) {
    if (!context.mounted) return;

    String finalRoute = route;

    if (params != null && params.isNotEmpty) {
      final queryString = Uri(queryParameters: params).query;
      finalRoute = '$route?$queryString';
    }

    final nav = Navigator.of(context);

    if (nav.canPop()) {
      nav.pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Future.microtask(() => context.go(finalRoute));
        }
      });
    } else {
      Future.microtask(() {
        if (context.mounted) context.go(finalRoute);
      });
    }
  }
}
