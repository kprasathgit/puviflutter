import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulated user info — replace with real provider later
    final user = {
      'name': 'Krishna',
      'phone': '8489707130',
      'address': 'Salem, Tamil Nadu',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Account"),
        backgroundColor: const Color(0xFF0B6623),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ User Profile Section
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFFE8F5E9),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.person, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user['name'] ?? '',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(user['phone'] ?? ''),
                      Text(user['address'] ?? '',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 12),

          const Divider(),

          // ✅ Action Items
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text("Your Orders"),
            onTap: () {
              context. push('/orders');
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.pop(context); // Close panel
              showDialog(
                context: context,
                builder: (_) => const AlertDialog(
                  content: Text("Settings screen placeholder"),
                ),
              );
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Log Out"),
            onTap: () {
              // Clear session / storage
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Logged out successfully")));
            },
          ),
        ],
      ),
    );
  }
}
