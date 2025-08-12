import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:puvi/project/routes/app_route_config.dart';
import 'package:puvi/src/cart/cart.controller.dart';
import 'package:puvi/src/firestore/firestore.controller.dart';
import 'package:puvi/src/firestore/firestore.service.dart';
import 'package:puvi/src/homepage/homapage.controller.dart';
import 'package:puvi/src/homepage/homepage.service.dart';
import 'package:puvi/src/login/login.controller.dart';
import 'package:puvi/src/login/login.service.dart';
import 'package:puvi/src/ordersummary/ordersummary.controller.dart';
import 'package:puvi/src/ordersummary/ordersummary.service.dart';
import 'package:puvi/src/userdetails/userdetails.controller.dart';
import 'package:puvi/src/userdetails/userdetails.service.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final GoRouter appRouter = MyAppRouter().router;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => HomescreenController(HomescreenService()),
        ),
        ChangeNotifierProvider(
          create: (context) => CartController(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserDetailsController(UserDetailsService()),
        ),
        ChangeNotifierProvider(
          create: (context) => OrderSummaryController(
              OrderSummaryService(), HomescreenService()),
        ),
        ChangeNotifierProvider(
          create: (context) => LoginController(LoginService()),
        ),
        ChangeNotifierProvider(
          create: (context) => FirestoreController(FirestoreService()),
        )
      ],
      child: MaterialApp.router(
        restorationScopeId: 'app',
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        title: "PuviPure",
        theme: ThemeData(
          fontFamily: 'Poppins',
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        darkTheme: ThemeData.dark(),
        supportedLocales: const [
          Locale('en', ''), // English
        ],
        //home: HomeScreen(),
        // themeMode: settingsController.themeMode,

        // Define a function to handle named routes in order to support
        // Flutter web url navigation and deep linking.
        // onGenerateRoute: (RouteSettings routeSettings) {
        //   return MaterialPageRoute<void>(
        //     settings: routeSettings,
        //     builder: (BuildContext context) {
        //       switch (routeSettings.name) {
        //         default:
        //           return Container(
        //             color: const Color.fromARGB(255, 150, 205, 152),
        //             child: Center(
        //               child: Center(
        //                 child: Text(
        //                   "PUVI PURE (Under Construction)",
        //                   maxLines: 1,
        //                   overflow: TextOverflow.ellipsis,
        //                   textAlign: TextAlign.center,
        //                   style: TextStyle(
        //                     color: const Color.fromARGB(255, 13, 155, 220),
        //                     fontSize: 18,
        //                     decoration: TextDecoration.none,
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           );
        //       }
        //     },
        //   );
        // },
      ),

      // child: MaterialApp(
      //   restorationScopeId: 'app',
      //   debugShowCheckedModeBanner: false,
      //   title: "PuviPure",
      //   theme: ThemeData(),
      //   darkTheme: ThemeData.dark(),
      //   supportedLocales: const [
      //     Locale('en', ''), // English
      //   ],
      //   home: HomeScreen(),
      //   routes: {
      //     HomeScreen.routeName: (context) => const HomeScreen(),
      //   },
      //   onGenerateRoute: (RouteSettings routeSettings) {
      //     return MaterialPageRoute<void>(
      //       settings: routeSettings,
      //       builder: (BuildContext context) {
      //         switch (routeSettings.name) {
      //           case HomeScreen.routeName:
      //             return const HomeScreen();
      //           default:
      //             return const HomeScreen();
      //         }
      //       },
      //     );
      //   },
      // ),
    );
  }
}
