import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:puvi/src/common/constantvalues.dart';
import 'package:puvi/src/models/product.dart';
import 'package:shimmer/shimmer.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageHeight = constraints.maxHeight * 0.68;
        final textFontSize = constraints.maxWidth * 0.05;
        final spacing = constraints.maxHeight * 0.02;
        final buttonHeight = constraints.maxHeight * 0.17;

        return GestureDetector(
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🖼 Image
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: product.imageurl.isNotEmpty
                        ? product.imageurl
                        : ConstantValues.defaultProductImageUrl,
                    height: imageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(height: imageHeight, color: Colors.white),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image),
                  ),
                ),
          
                // 📄 Product info
                Padding(
                  padding: EdgeInsets.all(spacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.proname,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: textFontSize,
                        ),
                      ),
                      SizedBox(height: spacing / 2),
                      Text(
                        "₹${product.price.toStringAsFixed(2)} / ${product.priceqty} ${product.priceqtyunit}",
                        style: TextStyle(fontSize: textFontSize * 0.9),
                      ),
                      SizedBox(height: spacing / 2),
                      Text(
                        "Stock: ${product.stockqty}",
                        style: TextStyle(fontSize: textFontSize * 0.9),
                      ),
                    ],
                  ),
                ),
          
                const Spacer(),
          
                // ➕ Add Button
                // SizedBox(
                //   width: double.infinity,
                //   height: buttonHeight,
                //   child: ElevatedButton(
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: const Color.fromARGB(255, 6, 44, 7),
                //       foregroundColor: Colors.white,
                //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                //     ),
                //     onPressed: () {
                //       // TODO: Add to cart logic
                //     },
                //     child: const Text("Add"),
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}
