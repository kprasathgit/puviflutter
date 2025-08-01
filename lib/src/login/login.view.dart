import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:puvi/project/routes/app_route_constants.dart';
import 'package:puvi/src/common/commonmethods.dart';
import 'package:puvi/src/common/storageutil.dart';
import 'package:puvi/src/common/urls.dart';

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

  Future<void> login() async {
    setState(() => loading = true);
    try {
      final res = await http.post(
        Uri.parse(Urls.authLogin),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': phone.text.trim(),
          'password': password.text,
        }),
      );

      if (res.statusCode == 200) {
        final user = jsonDecode(res.body)['returnObject']['user'];
        await StorageUtil.saveUserLocally(user);

        final redirectTo = widget.next ??
            (widget.flow == 'checkout' && widget.slug != null
                ? CommonMethods.buildRedirectUrl(AppRouteConstants.orderSummary,
                    slug: widget.slug)
                : AppRouteConstants.homeScreen);

        context.go(redirectTo);
      } else {
        setState(() => error = 'Login failed');
      }
    } catch (e) {
      setState(() => error = 'Error: $e');
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
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.lock, size: 72, color: Colors.blue),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child:
                        Text(error!, style: const TextStyle(color: Colors.red)),
                  ),
                TextFormField(
                  controller: phone,
                  decoration: const InputDecoration(
                      labelText: 'Mobile Number',
                      prefixIcon: Icon(Icons.phone)),
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      v != null && v.length == 10 ? null : 'Enter valid number',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: password,
                  decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline)),
                  obscureText: true,
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
                            if (_formKey.currentState!.validate()) login();
                          },
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: loading
                        ? const CircularProgressIndicator()
                        : const Text('Login'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                    onPressed: toRegister, child: const Text('Create Account')),
                TextButton(
                  onPressed: () => context.go(AppRouteConstants.forgotPassword),
                  child: const Text('Forgot Password?'),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
