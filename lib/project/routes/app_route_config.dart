import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:puvi/project/routes/app_route_constants.dart';
import 'package:puvi/src/accounts/accounts.view.dart';
import 'package:puvi/src/cart/cart.view.dart';
import 'package:puvi/src/homepage/hompage.view.dart';
import 'package:puvi/src/models/product.dart';
import 'package:puvi/src/productdetails/productdetails.view.dart';
import 'package:puvi/src/settings/settings.view.dart';
import 'package:puvi/src/userdetails/userdetails.view.dart';
import 'package:puvi/src/widget/errorpage.view.dart';

class MyAppRouter {
  late GoRouter router;

  MyAppRouter() {
    router = GoRouter(
      redirect: (context, state) {
        if (state.matchedLocation == AppRouteConstants.root) {
          return AppRouteConstants.homeScreen;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: AppRouteConstants.homeScreen,
          name: AppRouteConstants.homeScreenName,
          pageBuilder: (context, state) => MaterialPage(child: HomeScreen()),
        ),
        GoRoute(
          path: AppRouteConstants.cart,
          name: AppRouteConstants.cartName,
          builder: (_, __) => const CartScreen(),
        ),
        GoRoute(
          path: '${AppRouteConstants.productDetails}/:slug',
          name: AppRouteConstants.productDetailsName,
          pageBuilder: (context, state) {
            //  final procode = state.pathParameters['procode']!;
            // Uri.decodeComponent() reverses the encoding so you get the original procode back, even if it had /, spaces, etc.
            final slug = Uri.decodeComponent(state.pathParameters['slug']!);
            return MaterialPage(child: ProductDetailsScreen(slug: slug));
          },
        ),

        GoRoute(
          path: AppRouteConstants.userDetails,
          name: AppRouteConstants.userDetailsName,
          pageBuilder: (context, st) =>
              MaterialPage(child: UserDetailsScreen()),
        ),
        GoRoute(
          path: AppRouteConstants.account,
          name: AppRouteConstants.accountName,
          pageBuilder: (context, st) => MaterialPage(child: AccountScreen()),
        ),
        GoRoute(
          path: AppRouteConstants.settings,
          name: AppRouteConstants.settingsName,
          pageBuilder: (context, st) => MaterialPage(child: SettingsScreen()),
        ),
        // GoRoute(
        //     path: '/payment',
        //     name: 'payment',
        //     builder: (_, state) =>
        //         PaymentScreen(userInfo: state.extra as Map<String, String>)),
        // GoRoute(
        //     path: '/delivery',
        //     name: 'delivery',
        //     builder: (_, state) =>
        //         DeliveryStatusScreen(orderId: state.extra as String)),
      ],
      errorPageBuilder: (context, state) => MaterialPage(child: ErrorPage()),
    );
  }
}
