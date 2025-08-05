import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:puvi/project/routes/app_route_constants.dart';
import 'package:puvi/src/accounts/accounts.view.dart';
import 'package:puvi/src/blog/benefitscolepressedoil.dart';
import 'package:puvi/src/blog/bloglist.view.dart';
import 'package:puvi/src/blog/herbalpowderuses.dart';
import 'package:puvi/src/blog/howwemake.dart';
import 'package:puvi/src/blog/whypuvipureblog.view.dart';
import 'package:puvi/src/cart/cart.view.dart';
import 'package:puvi/src/homepage/hompage.view.dart';
import 'package:puvi/src/login/login.view.dart';
import 'package:puvi/src/orderdetails/orderdetails.view.dart';
import 'package:puvi/src/orderlist/orderlist.view.dart';
import 'package:puvi/src/ordersummary/ordersummary.view.dart';
import 'package:puvi/src/payment/payment.view.dart';
import 'package:puvi/src/productdetails/productdetails.view.dart';
import 'package:puvi/src/settings/settings.view.dart';
import 'package:puvi/src/userdetails/userdetails.view.dart';
import 'package:puvi/src/widget/errorpage.view.dart';
import 'package:puvi/src/widget/successscreen.dart';

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
          builder: (context, state) {
            return UserDetailsScreen(
              flow: state.uri.queryParameters['flow'],
              slug: state.uri.queryParameters['slug'],
              next: state.uri.queryParameters['next'], // 👈 include next
            );
          },
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
        GoRoute(
          path: '${AppRouteConstants.payment}/:secureKey',
          name: AppRouteConstants.paymentName,
          pageBuilder: (context, state) {
            final secureKey = state.pathParameters['secureKey']!;
            return MaterialPage(child: PaymentScreen(secureKey: secureKey));
          },
        ),
        GoRoute(
          path: AppRouteConstants.orderSummary,
          builder: (context, state) {
            final slug = state.uri.queryParameters['slug'];
            return OrderSummaryScreen(slug: slug);
          },
        ),
        GoRoute(
          path: '/success',
          builder: (_, __) => const SuccessScreen(),
        ),
        GoRoute(
          path: '/orders',
          builder: (_, __) => OrderListScreen(),
        ),
        GoRoute(
          path: '/order-detail/:secureKey',
          builder: (context, state) {
            final secureKey = state.pathParameters['secureKey']!;
            return OrderDetailScreen(secureKey: secureKey);
          },
        ),
        GoRoute(
          path: '/orders',
          builder: (context, state) =>
              OrderListScreen(), // <-- replace with your actual widget
        ),
        GoRoute(path: '/404', builder: (context, state) => ErrorPage()),
        GoRoute(
          path: AppRouteConstants.blogList,
          builder: (context, state) => BlogListScreen(),
        ),
        GoRoute(
          path: '/blog/why-puvipure',
          builder: (_, __) => const WhyPuviPureBlog(),
        ),
        GoRoute(
          path: '/blog/benefits-cold-pressed-oils',
          builder: (_, __) => const BenefitsColdPressedOilsBlog(),
        ),
        GoRoute(
          path: '/blog/herbal-powders-uses',
          builder: (_, __) => const HerbalPowdersUsesBlog(),
        ),
        GoRoute(
          path: '/blog/how-we-make',
          builder: (_, __) => const HowWeMakeBlog(),
        ),
        GoRoute(
          path: AppRouteConstants.login,
          builder: (context, state) => LoginScreen(
            flow: state.uri.queryParameters['flow'],
            slug: state.uri.queryParameters['slug'],
            next: state.uri.queryParameters['next'],
          ),
        ),
      ],
      errorPageBuilder: (context, state) => MaterialPage(child: ErrorPage()),
    );
  }
}
