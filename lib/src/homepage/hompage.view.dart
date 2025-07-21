import 'dart:async';

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


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const routeName = "/HomeScreen";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Product>> future;
  late HomescreenController homescreenController;
  final ScrollController _scrollController = ScrollController();

  String selectedTitle = 'All Products';
  String? selectedCatCode;

  @override
  void initState() {
    super.initState();
    homescreenController =
        Provider.of<HomescreenController>(context, listen: false);
    future = homescreenController.fetchProducts(forceRefresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900
        ? 4
        : screenWidth > 600
            ? 3
            : 2;

    return Scaffold(
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
            controller: _scrollController,
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  future = homescreenController.fetchProducts(
                    catcode: selectedCatCode,
                    forceRefresh: true,
                  );
                });
                await future;
              },
              child: GridView.builder(
                controller: _scrollController,
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
    );
  }
}
