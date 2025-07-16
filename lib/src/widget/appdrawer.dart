import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final Function(String? catcode, String name) onCategorySelected;

  const AppDrawer({super.key, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'name': 'All Products', 'catcode': null, 'icon': Icons.apps},
      {'name': 'Oils', 'catcode': 'C00001', 'icon': Icons.label},
      {'name': 'Honey', 'catcode': 'C00002', 'icon': Icons.label},
      {'name': 'Soap', 'catcode': 'C00003', 'icon': Icons.label},
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
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: Icon(item['icon'] as IconData),
                  title: Text(item['name'] as String),
                  onTap: () {
                    Navigator.pop(context);
                    onCategorySelected(item['catcode'] as String?, item['name'] as String);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
