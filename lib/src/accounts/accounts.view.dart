import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:puvi/project/routes/app_route_constants.dart';
import 'package:puvi/src/common/storageutil.dart';
import 'package:puvi/src/edituserprofile/edituserprofile.view.dart';
import 'package:puvi/src/models/user.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Account"),
        backgroundColor: theme.appBarTheme.backgroundColor ??
            theme.colorScheme.primary, // ✅ uses theme
      ),

      /// ✅ Combined uid + user notifier logic
      body: ValueListenableBuilder<String?>(
        valueListenable: StorageUtil.uidNotifier,
        builder: (context, uid, _) {
          if (uid == null) {
            return const _LoginPrompt();
          }

          // ✅ Logged in — now listen for user updates
          return ValueListenableBuilder<User?>(
            valueListenable: StorageUtil.userNotifier,
            builder: (context, user, _) {
              if (user == null) {
                // fallback: try local read once
                return FutureBuilder<User?>(
                  future: StorageUtil.getUserLocally(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final localUser = snapshot.data;
                    if (localUser == null) {
                      return const Center(child: Text("User Not Found"));
                    }
                    // update notifier so future changes reflect immediately
                    StorageUtil.userNotifier.value = localUser;
                    return _AccountContent(user: localUser);
                  },
                );
              }

              // ✅ User loaded and listening to notifier
              return _AccountContent(user: user);
            },
          );
        },
      ),
    );
  }
}

/// 🔹 When user is not logged in
class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      children: [
        const SizedBox(height: 50),
        Center(
          child: Column(
            children: [
              Icon(Icons.lock_outline,
                  size: 60, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                "Login to continue",
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.push(AppRouteConstants.login);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Login"),
              ),
            ],
          ),
        ),
        const Divider(),
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
    final theme = Theme.of(context);

    return ListView(
      children: [
        // 🔹 User Info Section
        Container(
          padding: const EdgeInsets.all(20),
          color: theme.colorScheme.surfaceVariant, // ✅ auto adapts to dark mode
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: theme.colorScheme.primary,
                child: Icon(Icons.person,
                    size: 30, color: theme.colorScheme.onPrimary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name ?? '',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                    Text(user.mobileno ?? '',
                        style: theme.textTheme.bodyMedium),
                    if (user.address != null)
                      Text(user.address!, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () =>
                    context.push(AppRouteConstants.editUserProfile),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Divider(),

        ListTile(
          leading: const Icon(Icons.shopping_bag),
          title: const Text("Your Orders"),
          onTap: () => context.push('/orders'),
        ),
        const Divider(),

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
