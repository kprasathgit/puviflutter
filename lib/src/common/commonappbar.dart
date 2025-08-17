import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puvi/src/accounts/accounts.view.dart';
import 'package:puvi/src/cart/cart.controller.dart';
import 'package:puvi/src/cart/cart.view.dart';
import 'package:puvi/src/common/themeprovider.dart';
import 'package:puvi/src/widget/rightpanel.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CommonAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0B6623),
            Color(0xFF4CAF50),
            Color.fromARGB(255, 22, 186, 126),
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          // 🔹 Theme Dropdown Icon
          PopupMenuButton<ThemeMode>(
            icon: const Icon(Icons.brightness_6),
            tooltip: "Change Theme",
            onSelected: (mode) => themeProvider.setTheme(mode),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: ThemeMode.light,
                child: ListTile(
                  leading: Icon(Icons.light_mode),
                  title: Text("Light"),
                ),
              ),
              PopupMenuItem(
                value: ThemeMode.dark,
                child: ListTile(
                  leading: Icon(Icons.dark_mode),
                  title: Text("Dark"),
                ),
              ),
              PopupMenuItem(
                value: ThemeMode.system,
                child: ListTile(
                  leading: Icon(Icons.settings_suggest),
                  title: Text("System Default"),
                ),
              ),
            ],
          ),

          // 🔹 Person/Profile Icon
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: "Your Account",
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) =>
                    const RightPanel(child: AccountScreen()),
              );
            },
          ),

          // 🔹 Settings Icon
          // IconButton(
          //   icon: const Icon(Icons.settings),
          //   tooltip: "Settings",
          //   onPressed: () {
          //     showDialog(
          //       context: context,
          //       builder: (_) =>
          //           const RightPanel(child: SettingsScreen()),
          //     );
          //   },
          // ),

          // 🔹 Cart Icon
          Consumer<CartController>(
            builder: (context, cartController, _) {
              final cartCount = cartController.items.fold<int>(
                0,
                (sum, item) => sum + item.qty,
              );

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => const RightPanel(child: CartScreen()),
                    ),
                  ),
                  if (cartCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: CircleAvatar(
                        radius: 9,
                        backgroundColor: Colors.red,
                        child: Text(
                          '$cartCount',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}
