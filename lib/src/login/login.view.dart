import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:puvi/main.dart';
import 'package:puvi/project/routes/app_route_constants.dart';
import 'package:puvi/src/common/commonappbar.dart';
import 'package:puvi/src/common/commonmethods.dart';
import 'package:puvi/src/common/constantvalues.dart';
import 'package:puvi/src/common/smartnavigator.dart';
import 'package:puvi/src/common/storageutil.dart';
import 'package:puvi/src/firebase/firebase.service.dart';
import 'package:puvi/src/firestore/firestore.controller.dart';
import 'package:puvi/src/login/login.controller.dart';
import 'package:puvi/src/models/user.dart';

class LoginScreen extends StatefulWidget {
  final String? flow;
  final String? slug;
  final String? next;

  const LoginScreen({super.key, this.flow, this.slug, this.next});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final phone = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  String? error;
  late LoginController loginController;
  late FirestoreController firestoreController;

  @override
  void initState() {
    super.initState();
    loginController = Provider.of<LoginController>(context, listen: false);
    firestoreController =
        Provider.of<FirestoreController>(context, listen: false);
  }

  Future<void> login() async {
    setState(() => loading = true);
    try {
      final data = {
        'username': phone.text.trim(),
        'password': password.text,
      };

      User? user = await loginController.checkLogin(data);
      if (user == null) {
        setState(() => error = 'Login failed.');
        return;
      }

      await StorageUtil.saveUserLocally(user);
      await firestoreController.signInFirebaseWithCustomToken(user.uid!);

      final currentToken = FirebaseService.token;
      if (currentToken != null) {
        User? updatedUser =
            await loginController.updateFcmToken(user.uid!, currentToken);
        if (updatedUser != null &&
            updatedUser.fcmtoken != null &&
            updatedUser.fcmtoken == currentToken) {
          print("FCM Token updated after Login.");
        } else {
          print("FCM Token updation failed while Login.");
        }
      }

      if (StorageUtil.uid != null) {
        await notificationController
            .fetchFromNotificationServer(StorageUtil.uid!);
      }

      final redirectTo = widget.next ??
          (widget.flow == ConstantValues.orderSummaryCheckout
              ? CommonMethods.buildRedirectUrl(AppRouteConstants.orderSummary,
                  slug: widget.slug)
              : (widget.flow == ConstantValues.productCheckout &&
                      widget.slug != null)
                  ? '${AppRouteConstants.productDetails}/${Uri.encodeComponent(widget.slug!)}'
                  : AppRouteConstants.homeScreen);

      if (mounted) {
        SmartNavigator.go(context, redirectTo);
      }
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  void toRegister() {
    final regUrl = CommonMethods.buildRedirectUrl(AppRouteConstants.userDetails,
        flow: widget.flow, slug: widget.slug, next: widget.next);
    context.go(regUrl);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text("Login"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline,
                      size: 72, color: colors.primary.withOpacity(0.9)),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Login to continue.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: colors.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              error!,
                              style: TextStyle(color: colors.error),
                            ),
                          )
                        ],
                      ),
                    ),
                  if (error != null) const SizedBox(height: 16),
                  TextFormField(
                    controller: phone,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      prefixIcon: const Icon(Icons.phone),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v != null && v.length == 10
                        ? null
                        : 'Enter valid 10-digit number',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v != null && v.isNotEmpty ? null : 'Enter password',
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                login();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: theme.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: toRegister,
                        child: const Text("Create one"),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _goToForgotPassword,
                    child: const Text("Forgot Password?",
                        style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _goToForgotPassword() {
    final url = CommonMethods.buildRedirectUrl(
      AppRouteConstants.forgotPassword,
    );
    context.go(url);
  }
}
