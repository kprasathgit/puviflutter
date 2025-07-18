import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:puvi/src/homepage/hompage.view.dart';
import 'package:puvi/src/widget/errorpage.view.dart';

class MyAppRouter {
  late GoRouter router;

  MyAppRouter() {
    router = GoRouter(
  redirect: (context, state) {
    if (state.matchedLocation == '/') return '/homescreen';
    return null;
  },
  routes: [
    GoRoute(
      path: '/homescreen',
      name: "HomeScreen",
      pageBuilder: (context, state) => MaterialPage(child: HomeScreen()),
    ),
    // Add other routes here (e.g., /details/:id, /cart, etc.)
  ],
  errorPageBuilder: (context, state) => MaterialPage(child: ErrorPage()),
);

  
  }
}
