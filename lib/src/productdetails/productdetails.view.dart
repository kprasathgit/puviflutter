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
import 'package:puvi/src/productdetails/galleryscreen.dart';
import 'package:puvi/src/widget/commonwidget.dart';

// ... all imports remain the same

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
  int selectedImageIndex = 0;

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

  @override
  void didUpdateWidget(covariant ProductDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detect if slug has changed
    if (oldWidget.slug != widget.slug) {
      final controller =
          Provider.of<HomescreenController>(context, listen: false);

      setState(() {
        productFuture = controller.getProductBySlug(widget.slug);
        selectedImageIndex = 0; // Reset image carousel
        qty = 1; // Reset quantity
        isLoadingAddToCart = false;
        isLoadingBuyNow = false;
      });

      // Optional: scroll to top
      scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> addToCart(Product product) async {
    if (isLoadingAddToCart) return;
    setState(() => isLoadingAddToCart = true);
    try {
      final uid = StorageUtil.uid;
      if (uid == null) {
        final nextUrl =
            '${AppRouteConstants.productDetails}/${Uri.encodeComponent(product.slug)}';
        final redirectUrl = CommonMethods.buildRedirectUrl(
          AppRouteConstants.login,
          next: nextUrl,
          flow: ConstantValues.productCheckout,
          slug: product.slug,
        );
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
      setState(() => isLoadingAddToCart = false);
    }
  }

  Future<void> buyNow(Product product) async {
    if (isLoadingBuyNow) return;
    setState(() => isLoadingBuyNow = true);
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
      BuyNowSession.set(product: product, qty: qty);
      context.go(CommonMethods.buildRedirectUrl(AppRouteConstants.orderSummary,
          slug: product.slug));
      Future.delayed(const Duration(seconds: 1), () {
        NotificationHelper.requestPermission();
      });
    } finally {
      setState(() => isLoadingBuyNow = false);
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
              body: Center(child: Text('⚠️ Error: ${snapshot.error}')));
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
          appBar: CommonAppBar(
            title: product.proname,
          ),
          body: KeyboardScrollable(
            controller: scrollController,
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main content: image + details
                  isWide
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

                  const SizedBox(height: 10),

                  // Related products section (unchanged)
                  _buildRelatedProductsSection(product),

                  const SizedBox(height: 30),

                  // Future sections placeholder
                  // Example: _buildFAQSection(product),
                  // Example: _buildSimilarProductsSection(product),
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
                        child: _actionButton(
                          "Add to Cart",
                          onTap: () => addToCart(product),
                          color: const Color(0xFFFFD600),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _actionButton(
                          "Buy Now",
                          onTap: () => buyNow(product),
                          color: const Color(0xFF3B1E8F),
                          textColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : null,
        );
      },
    );
  }

  // 🔹 IMAGE SECTION + THUMBNAILS
  Widget _buildImageSection(Product product) {
    final List<String> imageUrls =
        (product.images != null && product.images!.isNotEmpty)
            ? (product.images!
                  ..sort((a, b) => a.displayorder.compareTo(b.displayorder)))
                .map((img) => img.imageurl)
                .toList()
            : [product.imageurl ?? ""];
    final isWide = MediaQuery.of(context).size.width > 700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Main image (responsive width)
        GestureDetector(
          onTap: () {
            // ✅ Use path parameters with AppRouteConstants
            context.push(
              '${AppRouteConstants.gallery}/${product.slug}/$selectedImageIndex',
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: isWide ? 400 : 300,
              width: double.infinity, // expand to full available width
              child: Image.network(
                imageUrls[selectedImageIndex],
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 13),

        // Thumbnail strip
        if (imageUrls.length > 1)
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imageUrls.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => setState(() => selectedImageIndex = index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selectedImageIndex == index
                          ? Colors.blue
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.network(imageUrls[index],
                      width: 70, height: 70, fit: BoxFit.cover),
                ),
              ),
            ),
          ),

        const SizedBox(height: 16),

        // Quantity selector (responsive)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _qtyButton(
                    Icons.remove, qty > 1 ? () => setState(() => qty--) : null),
                const SizedBox(width: 12),
                Text('$qty',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                _qtyButton(Icons.add, () => setState(() => qty++)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // CTA buttons (wide screens)
        if (isWide)
          Row(
            children: [
              Flexible(
                fit: FlexFit.tight,
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
                              valueColor: AlwaysStoppedAnimation(Colors.black)),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                fit: FlexFit.tight,
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
                              valueColor: AlwaysStoppedAnimation(Colors.white)),
                        )
                      : null,
                ),
              ),
            ],
          ),
      ],
    );
  }

  // 🔹 DETAILS + SECTIONS
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
        // 🔥 Dynamic details from backend
        for (var detail in product.details)
          _buildSection(detail.title, detail.content),
        // _buildSection("Ingredients", "Aloe Vera, Neem, Tulsi, Rose Water"),
        // _buildSection(
        //     "Benefits", "Hydrates skin, clears acne, refreshes tone."),
        // _buildSection("How to Use", "Apply gently to clean skin twice a day."),
        // _buildSection("Reviews",
        //     "⭐️⭐️⭐️⭐️☆ (4.2)\nExcellent product for daily use! - A user"),
        // _buildSection("You May Also Like", "Related product cards here..."),
        //_buildPagination(),
      ],
    );
  }

// 🔹 RELATED PRODUCTS SECTION (FROM CACHED listProduct)
  Widget _buildRelatedProductsSection(Product currentProduct) {
    final homescreenController =
        Provider.of<HomescreenController>(context, listen: false);

    // Filter related products from cached list, exclude current product
    final relatedProducts = homescreenController.listProduct
        .where((p) =>
            p.procode != currentProduct.procode &&
            p.category.categorycode == currentProduct.category.categorycode)
        .toList();

    if (relatedProducts.isEmpty)
      return const SizedBox(); // Hide section if none

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text("You May Also Like",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: relatedProducts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = relatedProducts[index];
              return GestureDetector(
                onTap: () {
                  // Navigate to product details for selected related product
                  context.go(
                    '${AppRouteConstants.productDetails}/${Uri.encodeComponent(product.slug)}',
                  );
                },
                child: SizedBox(
                  width: 160,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imageurl ?? '',
                          width: 160,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(product.proname,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('₹${product.price}',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.green)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
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
        children: List.generate(
            5,
            (index) => OutlinedButton(
                  onPressed: () {
                    // TODO: Navigate to respective product
                  },
                  child: Text('${index + 1}'),
                )),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      child: childWidget ?? Text(text),
    );
  }
}
