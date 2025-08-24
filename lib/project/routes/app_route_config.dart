import 'package:flutter/foundation.dart' show kIsWeb;
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
import 'package:puvi/src/forgetpassword/forgetpassword.view.dart';
import 'package:puvi/src/forgetpassword/resetpassword.view.dart';
import 'package:puvi/src/homepage/hompage.view.dart';
import 'package:puvi/src/login/login.view.dart';
import 'package:puvi/src/orderdetails/orderdetails.view.dart';
import 'package:puvi/src/orderlist/orderlist.view.dart';
import 'package:puvi/src/ordersummary/ordersummary.view.dart';
import 'package:puvi/src/payment/payment.view.dart';
import 'package:puvi/src/payment/paymentresultscreen.dart';
import 'package:puvi/src/productdetails/productdetails.view.dart';
import 'package:puvi/src/settings/settings.view.dart';
import 'package:puvi/src/userdetails/userdetails.view.dart';
import 'package:puvi/src/widget/errorpage.view.dart';
import 'package:puvi/src/widget/successscreen.dart';
import 'package:universal_html/html.dart' as html;

class MyAppRouter {
  late GoRouter router;

  MyAppRouter() {
    router = GoRouter(
      redirect: (context, state) {
        if (state.matchedLocation == AppRouteConstants.root) {
          return AppRouteConstants.homeScreen;
        }
        // Handle Razorpay payment retry redirect on web
        if (kIsWeb) {
          final ls = html.window.localStorage;
          final paymentRetry = ls['paymentRetry'];
          if (paymentRetry == '1') {
            // Read retry data
            final retryFlow = ls['retryFlow'] ?? '';
            final retrySlug = ls['retrySlug'];

            // Clear retry flags to avoid loops
            ls.remove('paymentRetry');
            ls.remove('retryFlow');
            ls.remove('retrySlug');

            // Build query params
            final queryParams = <String, String>{'retry': '1'};
            if (retryFlow.isNotEmpty) {
              queryParams['retryFlow'] = retryFlow;
            }
            if (retryFlow == 'buyNow' &&
                retrySlug != null &&
                retrySlug.isNotEmpty) {
              queryParams['slug'] = retrySlug;
            }

            final queryString = Uri(queryParameters: queryParams).query;
            final redirectPath =
                '${AppRouteConstants.orderSummary}?$queryString';

            // Return redirect path so GoRouter will navigate here
            return redirectPath;
          }
        }
        return null;
      },
      routes: [
        GoRoute(
            path: AppRouteConstants.homeScreen,
            name: AppRouteConstants.homeScreenName,
            pageBuilder: (context, state) {
              final disableBack =
                  state.uri.queryParameters['disableBack'] == '1';
              return MaterialPage(child: HomeScreen(disableBack: disableBack));
            }),
        GoRoute(
          path: AppRouteConstants.cart,
          name: AppRouteConstants.cartName,
          builder: (_, __) => const CartScreen(),
        ),
        GoRoute(
          path: '${AppRouteConstants.productDetails}/:slug',
          name: AppRouteConstants.productDetailsName,
          pageBuilder: (context, state) {
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
              next: state.uri.queryParameters['next'],
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
            // ⬇ Preserve flow + slug for retry tracking
            final flow = state.uri.queryParameters['flow'];
            final slug = state.uri.queryParameters['slug'];
            if (flow != null) {
              html.window.localStorage['retryFlow'] = flow;
            }
            if (slug != null) {
              html.window.localStorage['retrySlug'] = slug;
            }
            return MaterialPage(
              child: PaymentScreen(secureKey: secureKey),
            );
          },
        ),
        GoRoute(
          path: AppRouteConstants.orderSummary,
          builder: (context, state) {
            final slug = state.uri.queryParameters['slug'];
            final retryFlow = state.uri.queryParameters['retryFlow'];
            final autoRetry = (state.uri.queryParameters['retry'] == '1') ||
                (state.uri.queryParameters['autoRetry'] == '1');

            return OrderSummaryScreen(
              slug: slug,
              retryFlow: retryFlow,
              autoRetry: autoRetry,
            );
          },
        ),
        GoRoute(
          path: '/success',
          builder: (_, __) => const SuccessScreen(),
        ),
        GoRoute(
          path: AppRouteConstants.orders,
          name: AppRouteConstants.ordersName,
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
          builder: (context, state) => OrderListScreen(),
        ),
        GoRoute(path: '/404', builder: (context, state) => ErrorPage()),
        GoRoute(
          path: AppRouteConstants.blogList,
          builder: (context, state) => BlogListScreen(),
        ),
        GoRoute(
          path: AppRouteConstants.paymentstatus,
          name: AppRouteConstants.paymentStatusName,
          builder: (context, state) {
            final secureKey = state.uri.queryParameters['secureKey'];
            if (secureKey == null || secureKey.isEmpty) {
              return const Scaffold(
                body: Center(child: Text("Invalid secure key.")),
              );
            }
            return PaymentStatusScreen(secureKey: secureKey);
          },
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
          builder: (context, state) {
            final flow = state.uri.queryParameters['flow'];
            final slug = state.uri.queryParameters['slug'];
            final next = state.uri.queryParameters['next'];

            // ✅ Preserve retry flags when redirecting to login
            if (html.window.localStorage.containsKey('retryFlow')) {
              return LoginScreen(
                flow: html.window.localStorage['retryFlow'],
                slug: html.window.localStorage['retrySlug'],
                next: next,
              );
            }
            return LoginScreen(flow: flow, slug: slug, next: next);
          },
        ),
        GoRoute(
          path: AppRouteConstants.forgotPassword,
          builder: (context, state) {
            return ForgotPasswordScreen();
          },
        ),
        GoRoute(
          path: AppRouteConstants.resetPassword,
          builder: (context, state) {
            final mobile = state.uri.queryParameters['mobile'];
            if (mobile == null) {
              return const Scaffold(
                body: Center(child: Text("Mobile number missing")),
              );
            }
            return ResetPasswordScreen(mobile: mobile);
          },
        )
      ],
      errorPageBuilder: (context, state) => MaterialPage(child: ErrorPage()),
    );
  }
}
