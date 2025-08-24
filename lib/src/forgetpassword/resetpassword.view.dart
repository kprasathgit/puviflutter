import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puvi/project/routes/app_route_constants.dart';
import 'package:puvi/src/common/smartnavigator.dart';
import 'package:puvi/src/forgetpassword/forgetpassword.controller.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String mobile;
  const ResetPasswordScreen({super.key, required this.mobile});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final passController = TextEditingController();
  final confirmController = TextEditingController();
  bool loading = false;
  String? error;
  bool passVisible = false;
  bool confirmVisible = false;

  late ForgetpasswordController forgetpasswordController;

  @override
  void initState() {
    super.initState();
    forgetpasswordController =
        Provider.of<ForgetpasswordController>(context, listen: false);
  }

  @override
  void dispose() {
    passController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  bool get isValid =>
      passController.text.trim().length >= 6 &&
      passController.text.trim() == confirmController.text.trim();

  Future<void> _resetPassword() async {
    if (!isValid) {
      setState(
          () => error = "Passwords must match and be at least 6 characters");
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final user = await forgetpasswordController.resetUserPassword(
          widget.mobile, passController.text.trim());

      if (user != null) {
        SmartNavigator.go(context, AppRouteConstants.login);
      } else {
        setState(() => error = "Failed to reset password");
      }
    } catch (e) {
      setState(() => error = "Something went wrong");
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight -
              kToolbarHeight -
              MediaQuery.of(context).padding.top,
          width: screenWidth,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Set your new password for your account",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: passController,
                    obscureText: !passVisible,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: "New Password",
                      border: const OutlineInputBorder(),
                      helperText: "Minimum 6 characters",
                      suffixIcon: IconButton(
                        icon: Icon(passVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () =>
                            setState(() => passVisible = !passVisible),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmController,
                    obscureText: !confirmVisible,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      border: const OutlineInputBorder(),
                      helperText: "Re-enter password to confirm",
                      errorText: confirmController.text.isEmpty
                          ? null
                          : (passController.text != confirmController.text
                              ? "Passwords do not match"
                              : null),
                      suffixIcon: IconButton(
                        icon: Icon(confirmVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () =>
                            setState(() => confirmVisible = !confirmVisible),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: loading || !isValid ? null : _resetPassword,
                      style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 16)),
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Reset Password"),
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
