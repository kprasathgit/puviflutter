import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:puvi/project/routes/app_route_constants.dart';
import 'package:puvi/src/common/commonappbar.dart';
import 'package:puvi/src/common/keyboardscrollable.dart';
import 'package:puvi/src/homepage/homapage.controller.dart';
import 'package:puvi/src/models/product.dart';
import 'package:puvi/src/widget/appdrawer.dart';
import 'package:puvi/src/widget/productcard.dart';
import 'package:universal_html/html.dart' as html;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.disableBack = false});
  static const routeName = "/HomeScreen";
  final bool disableBack;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Product>> future;
  late HomescreenController homescreenController;
  ScrollController? _scrollController;

  String selectedTitle = 'All';
  String? selectedCatCode;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    homescreenController =
        Provider.of<HomescreenController>(context, listen: false);

    if (kIsWeb && widget.disableBack) {
      // Push initial state to history to avoid back navigation to previous page
      html.window.history.pushState(null, 'Home', AppRouteConstants.homeScreen);

      // Listen to browser back button or arrow key events
      html.window.onPopState.listen((event) {
        // Immediately push same state to prevent back navigation
        html.window.history
            .pushState(null, 'Home', AppRouteConstants.homeScreen);
        // Optional: show a message or keep silent
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text("Back navigation disabled on this screen")),
        // );
      });
    }
    future = homescreenController.fetchProducts(forceRefresh: true);
  }

  @override
  void dispose() {
    if (_scrollController != null) {
      _scrollController!.dispose();
      _scrollController = null;
    }

    super.dispose();
  }

  void onCategoryChanged(String? catcode, String name) {
    setState(() {
      selectedTitle = name;
      selectedCatCode = catcode;
      future = homescreenController.fetchProducts(
        catcode: catcode,
        forceRefresh: false,
      );
    });
  }

  bool _onWillPop() {
    // return !(widget.disableBack);
  return false;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900
        ? 4
        : screenWidth > 600
            ? 3
            : 2;

    final scrollController = _scrollController;

    return PopScope(
      canPop: _onWillPop(),
      child: Scaffold(
        appBar: CommonAppBar(
          title: 'PUVIPURE - $selectedTitle',
        ),
        drawer: AppDrawer(onCategorySelected: onCategoryChanged),
        body: FutureBuilder<List<Product>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final products = snapshot.data ?? [];

            return KeyboardScrollable(
              controller: scrollController,
              child: RefreshIndicator(
                onRefresh: () async {
                  final newFuture = homescreenController.fetchProducts(
                    catcode: selectedCatCode,
                    forceRefresh: true,
                  );
                  if (!mounted) return;
                  setState(() {
                    future = newFuture;
                  });
                  await newFuture;
                  if (!mounted) return;
                },
                child: GridView.builder(
                  key: PageStorageKey('home_grid'),
                  controller: scrollController,
                  padding: const EdgeInsets.all(10),
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          final slug = p.slug;
                          context.go(
                              '${AppRouteConstants.productDetails}/${Uri.encodeComponent(slug)}');
                        },
                        child: ProductCard(product: p),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
