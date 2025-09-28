import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:puvi/src/models/product.dart';

class GalleryScreen extends StatelessWidget {
  final Product product;
  final int initialIndex;

  const GalleryScreen({
    super.key,
    required this.product,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> imageUrls =
        (product.images != null && product.images!.isNotEmpty)
            ? (product.images!
                  ..sort((a, b) => a.displayorder.compareTo(b.displayorder)))
                .map((img) => img.imageurl)
                .toList()
            : [product.imageurl ?? ""];

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown, // Shrinks text if too long
          alignment: Alignment.centerLeft,
          child: Text(
            product.proname,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.share),
        //     onPressed: () {},
        //   ),
        //   IconButton(
        //     icon: const Icon(Icons.favorite_border),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return Center(
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: InteractiveViewer(
                    panEnabled: true,
                    scaleEnabled: true,
                    minScale: 0.5,
                    maxScale: 3.0,
                    constrained: true, // ⚡️ important for Web
                    boundaryMargin: const EdgeInsets.all(20),
                    child: CachedNetworkImage(
                      imageUrl: imageUrls[index],
                      fit: BoxFit.contain,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.broken_image, size: 80),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
