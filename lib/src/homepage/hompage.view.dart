import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
  final FocusNode _focusNode = FocusNode();
  Timer? _holdScrollTimer;

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
    _focusNode.dispose();
    _holdScrollTimer?.cancel();
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

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyRepeatEvent || event is KeyDownEvent) {
      const scrollStep = 80.0;
      const pageStep = 300.0;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final minScroll = _scrollController.position.minScrollExtent;
      final currentOffset = _scrollController.offset;

      void scrollTo(double offset) {
        _scrollController.animateTo(
          offset.clamp(minScroll, maxScroll),
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }

      switch (event.logicalKey.keyLabel) {
        case 'Arrow Down':
          scrollTo(currentOffset + scrollStep);
          return KeyEventResult.handled;
        case 'Arrow Up':
          scrollTo(currentOffset - scrollStep);
          return KeyEventResult.handled;
        case 'Page Down':
          scrollTo(currentOffset + pageStep);
          return KeyEventResult.handled;
        case 'Page Up':
          scrollTo(currentOffset - pageStep);
          return KeyEventResult.handled;
        case 'Home':
          scrollTo(minScroll);
          return KeyEventResult.handled;
        case 'End':
          scrollTo(maxScroll);
          return KeyEventResult.handled;
      }
    }

    if (event is KeyUpEvent) {
      _holdScrollTimer?.cancel();
      _holdScrollTimer = null;
    }

    return KeyEventResult.ignored;
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0B6623), // Forest green
                Color(0xFF4CAF50), // Middle green
                Color(0xFFA8E6CF), // Light mint
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme:
                const IconThemeData(color: Colors.white), // ✅ Drawer icon color
            title: Text(
              'Puvi Pure - $selectedTitle',
              style: const TextStyle(color: Colors.black), // ✅ Text color
            ),
            centerTitle: true,
          ),
        ),
      ),
      drawer: AppDrawer(onCategorySelected: onCategoryChanged),
      body: Focus(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        autofocus: true,
        child: FutureBuilder<List<Product>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final products = snapshot.data ?? [];

            return ScrollConfiguration(
              behavior: const MaterialScrollBehavior().copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                },
              ),
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                interactive: true,
                trackVisibility: true,
                thickness: 14,
                radius: const Radius.circular(8),
                scrollbarOrientation: ScrollbarOrientation.right,
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
                      return ProductCard(product: products[index]);
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
