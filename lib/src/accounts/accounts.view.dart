import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:puvi/project/routes/app_route_constants.dart';
import 'package:puvi/src/common/storageutil.dart';
import 'package:puvi/src/models/user.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Account"),
        backgroundColor: const Color(0xFF0B6623),
      ),
      body: ValueListenableBuilder<String?>(
        valueListenable: StorageUtil.uidNotifier,
        builder: (context, uid, _) {
          if (uid == null) {
            // 🔹 Not logged in
            return _LoginPrompt();
          } else {
            // 🔹 Logged in → fetch user locally
            return FutureBuilder<User?>(
              future: StorageUtil.getUserLocally(),
              builder: (context, snapshot) {
                final user = snapshot.data;
                if (snapshot.connectionState == ConnectionState.waiting &&
                    user == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.connectionState == ConnectionState.done &&
                    user == null) {
                  return const Center(child: Text("User Not Found"));
                }
                return _AccountContent(user: user!);
              },
            );
          }
        },
      ),
    );
  }
}

/// 🔹 When user is not logged in
class _LoginPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 50),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                "Login to continue",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.push(AppRouteConstants.login);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B6623),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(style: TextStyle(color: Colors.black), "Login"),
              ),
            ],
          ),
        ),
        const Divider(),
        // ✅ Public features still visible even without login
        ListTile(
          leading: const Icon(Icons.article),
          title: const Text("Our Blog"),
          onTap: () => context.go(AppRouteConstants.blogList),
        ),
      ],
    );
  }
}

/// 🔹 When user is logged in
class _AccountContent extends StatelessWidget {
  final User user;

  const _AccountContent({required this.user});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // 🔹 User Info Section
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
                    Text(
                      user.name ?? '',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(user.mobileno ?? ''),
                    if (user.address != null)
                      Text(
                        user.address!,
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Divider(),
        // 🔹 User-specific actions
        ListTile(
          leading: const Icon(Icons.shopping_bag),
          title: const Text("Your Orders"),
          onTap: () => context.push('/orders'),
        ),
        const Divider(),

        // 🔹 Public / common actions
        ListTile(
          leading: const Icon(Icons.article),
          title: const Text("Our Blog"),
          onTap: () => context.go(AppRouteConstants.blogList),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text("Log Out"),
          onTap: () {
            StorageUtil.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Logged out successfully")),
            );
          },
        ),
      ],
    );
  }
}
