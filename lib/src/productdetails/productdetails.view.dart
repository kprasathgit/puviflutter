import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:puvi/project/routes/app_route_constants.dart';
import 'package:puvi/src/cart/cart.controller.dart';
import 'package:puvi/src/common/buynowsession.dart';
import 'package:puvi/src/common/commonappbar.dart';
import 'package:puvi/src/common/commonmethods.dart';
import 'package:puvi/src/common/constantvalues.dart';
import 'package:puvi/src/common/keyboardscrollable.dart';
import 'package:puvi/src/common/storageutil.dart';
import 'package:puvi/src/homepage/homapage.controller.dart';
import 'package:puvi/src/models/product.dart';
import 'package:puvi/src/notification/notification.helper.dart';
import 'package:puvi/src/widget/commonwidget.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String slug;
  const ProductDetailsScreen({super.key, required this.slug});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late CartController cartController;
  late Future<Product?> productFuture;
  final ScrollController scrollController = ScrollController();
  int qty = 1;
  bool isLoadingAddToCart = false;
  bool isLoadingBuyNow = false;

  @override
  void initState() {
    super.initState();
    cartController = Provider.of<CartController>(context, listen: false);
    final controller =
        Provider.of<HomescreenController>(context, listen: false);
    productFuture = controller.getProductBySlug(widget.slug);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> addToCart(Product product) async {
    if (isLoadingAddToCart) return; // prevent double tap
    setState(() {
      isLoadingAddToCart = true;
    });

    try {
      final uid = StorageUtil.uid;
      if (uid == null) {
        final nextUrl =
            '${AppRouteConstants.productDetails}/${Uri.encodeComponent(product.slug)}';
        final redirectUrl = CommonMethods.buildRedirectUrl(
            AppRouteConstants.login,
            next: nextUrl,
            flow: ConstantValues.productCheckout,
            slug: product.slug);
        context.go(redirectUrl);
        return;
      }
      await cartController.add(product, qty);
      CommonWidget.showTopToast(
        context,
        message: '✔ Added to Cart',
        icon: Icons.shopping_cart,
        backgroundColor: const Color.fromARGB(255, 188, 204, 95),
      );
    } finally {
      setState(() {
        isLoadingAddToCart = false;
      });
    }
  }

// inside buyNow()
  Future<void> buyNow(Product product) async {
    if (isLoadingBuyNow) return;
    setState(() {
      isLoadingBuyNow = true;
    });
    try {
      final uid = StorageUtil.uid;
      if (uid == null) {
        final nextUrl = CommonMethods.buildRedirectUrl(
            AppRouteConstants.orderSummary,
            slug: product.slug);
        final redirectUrl = CommonMethods.buildRedirectUrl(
          AppRouteConstants.login,
          next: nextUrl,
          flow: ConstantValues.orderSummaryCheckout,
          slug: product.slug,
        );
        context.go(redirectUrl);
        return;
      }
      // cartController.clear();
      // cartController.add(product, qty);
      BuyNowSession.set(product: product, qty: qty);
      context.go(CommonMethods.buildRedirectUrl(AppRouteConstants.orderSummary,
          slug: product.slug));

      // 🔔 Ask for notification permission (soft + browser prompt)
      Future.delayed(const Duration(seconds: 1), () {
        NotificationHelper.requestPermission();
      });
    } finally {
      setState(() {
        isLoadingBuyNow = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return FutureBuilder<Product?>(
      future: productFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.green)),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('⚠️ Error: ${snapshot.error}')),
          );
        }

        final product = snapshot.data;
        if (product == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("❌ Product not found",
                      style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text("Back to Home"),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: CommonAppBar(title: product.proname),
          body: KeyboardScrollable(
            controller: scrollController,
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildImageSection(product)),
                        const SizedBox(width: 30),
                        Expanded(child: _buildDetailsSection(product)),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImageSection(product),
                        _buildDetailsSection(product),
                      ],
                    ),
            ),
          ),
          bottomNavigationBar: !isWide
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: _actionButton("Add to Cart",
                            onTap: () => addToCart(product),
                            color: const Color(0xFFFFD600)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _actionButton("Buy Now",
                            onTap: () => buyNow(product),
                            color: const Color(0xFF3B1E8F),
                            textColor: Colors.white),
                      ),
                    ],
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildImageSection(Product product) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(product.imageurl, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 13),

        // ✅ Quantity Selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _qtyButton(
                  Icons.remove, qty > 1 ? () => setState(() => qty--) : null),
              const SizedBox(width: 12),
              Text(
                '$qty',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              _qtyButton(Icons.add, () => setState(() => qty++)),
            ],
          ),
        ),

        const SizedBox(height: 16),

        if (isWide)
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  isLoadingAddToCart ? "" : "Add to Cart",
                  onTap: () => isLoadingAddToCart ? null : addToCart(product),
                  color: const Color(0xFFFFD600),
                  childWidget: isLoadingAddToCart
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.black),
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionButton(
                  isLoadingBuyNow ? "" : "Buy Now",
                  onTap: () => isLoadingBuyNow ? null : buyNow(product),
                  color: const Color(0xFF3B1E8F),
                  textColor: Colors.white,
                  childWidget: isLoadingBuyNow
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDetailsSection(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.proname,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('₹${product.price}',
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.green)),
        const SizedBox(height: 12),
        Text(product.description, style: const TextStyle(fontSize: 16)),
        _buildSection("Ingredients", "Aloe Vera, Neem, Tulsi, Rose Water"),
        _buildSection(
            "Benefits", "Hydrates skin, clears acne, refreshes tone."),
        _buildSection("How to Use", "Apply gently to clean skin twice a day."),
        _buildSection("Reviews",
            "⭐️⭐️⭐️⭐️☆ (4.2)\nExcellent product for daily use! - A user"),
        _buildSection("You May Also Like", "Related product cards here..."),
        _buildPagination(),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
      ],
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Wrap(
        spacing: 10,
        children: List.generate(5, (index) {
          return OutlinedButton(
            onPressed: () {
              // TODO: Navigate to respective product
            },
            child: Text('${index + 1}'),
          );
        }),
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback? onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade600),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon,
            size: 20, color: onPressed == null ? Colors.grey : Colors.black),
      ),
    );
  }

  Widget _actionButton(String text,
      {required VoidCallback onTap,
      required Color color,
      Color textColor = Colors.black,
      Widget? childWidget}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        foregroundColor: textColor,
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      child: childWidget ?? Text(text),
    );
  }
}
