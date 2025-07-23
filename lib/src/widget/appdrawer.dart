import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final Function(String? catcode, String name) onCategorySelected;

  const AppDrawer({super.key, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'name': 'All Products', 'catcode': null, 'icon': Icons.apps},
      {'name': 'Oils', 'catcode': 'C00001', 'icon': Icons.label_outline},
      {'name': 'Honey', 'catcode': 'C00002', 'icon': Icons.label_outline},
      {'name': 'Soap', 'catcode': 'C00003', 'icon': Icons.label_outline},
      {'name': 'Sweeteners', 'catcode': 'C00004', 'icon': Icons.label_outline},
      {'name': 'Millets', 'catcode': 'C00005', 'icon': Icons.label_outline},
      {'name': 'Pulses', 'catcode': 'C00006', 'icon': Icons.label_outline},
      {'name': 'Rice', 'catcode': 'C00007', 'icon': Icons.label_outline},
      {'name': 'Herbal Powder', 'catcode': 'C00008', 'icon': Icons.label_outline},
    ];

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade900, Colors.green.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Puvi Categories',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5),
              itemBuilder: (context, index) {
                final item = items[index];
                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    onCategorySelected(
                      item['catcode'] as String?,
                      item['name'] as String,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Icon(item['icon'] as IconData, size: 20, color: Colors.grey[700]),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            item['name'] as String,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
