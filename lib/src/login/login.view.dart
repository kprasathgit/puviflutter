import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:puvi/project/routes/app_route_constants.dart';
import 'package:puvi/src/common/commonappbar.dart';
import 'package:puvi/src/common/commonmethods.dart';
import 'package:puvi/src/common/smartnavigator.dart';
import 'package:puvi/src/common/storageutil.dart';
import 'package:puvi/src/common/urls.dart';
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
  @override
  void initState() {
    super.initState();
    loginController = Provider.of<LoginController>(context, listen: false);
  }

  Future<void> login() async {
    setState(() => loading = true);
    try {
      final data = {
        'username': phone.text.trim(),
        'password': password.text,
      };

      User? user = await loginController.checkLogin(data);
      print(user);
      if (user == null) {
        setState(() => error = 'Login failed.');
        return;
      }

      await StorageUtil.saveUserLocally(user);
      final redirectTo = widget.next ??
          (widget.flow == 'checkout' && widget.slug != null
              ? CommonMethods.buildRedirectUrl(AppRouteConstants.orderSummary,
                  slug: widget.slug)
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
    final isWide = MediaQuery.of(context).size.width > 600;
    final themeColor = const Color(0xFF2A3B47); // Puvi dark bluish

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CommonAppBar(title: "Login"),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline,
                          size: 72, color: themeColor.withOpacity(0.9)),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome Back!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: themeColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Login to continue.',
                        style: TextStyle(color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.redAccent),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  error!,
                                  style:
                                      const TextStyle(color: Colors.redAccent),
                                ),
                              )
                            ],
                          ),
                        ),
                      if (error != null) const SizedBox(height: 16),
                      TextFormField(
                        controller: phone,
                        decoration: const InputDecoration(
                          labelText: 'Mobile Number',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
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
                            backgroundColor: themeColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
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
                          const Text("Don't have an account? "),
                          TextButton(
                            onPressed: toRegister,
                            child: const Text("Create one"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
