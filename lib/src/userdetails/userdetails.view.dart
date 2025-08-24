import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:puvi/project/routes/app_route_constants.dart';
import 'package:puvi/src/common/commonmethods.dart';
import 'package:puvi/src/common/storageutil.dart';
import 'package:puvi/src/firebase/firebase.service.dart';
import 'package:puvi/src/firestore/firestore.controller.dart';
import 'package:puvi/src/models/user.dart';
import 'package:puvi/src/userdetails/userdetails.controller.dart';
import 'package:puvi/src/otp/otp.service.dart';
import 'package:puvi/src/otp/otpscreen.view.dart';

class UserDetailsScreen extends StatefulWidget {
  final String? flow;
  final String? slug;
  final String? next;

  const UserDetailsScreen({super.key, this.flow, this.slug, this.next});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  final password = TextEditingController();

  late UserDetailsController userDetailsController;
  late FirestoreController firestoreController;

  final phoneRegex = RegExp(r'^[6-9]\d{9}$');

  bool loading = false;
  String? error;
  String? verifiedPhone;

  @override
  void initState() {
    super.initState();
    userDetailsController =
        Provider.of<UserDetailsController>(context, listen: false);
    firestoreController =
        Provider.of<FirestoreController>(context, listen: false);
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    address.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Icon(Icons.person_add_alt_1,
                      size: 72, color: Colors.green),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(error!,
                          style: const TextStyle(color: Colors.red)),
                    ),
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        v != null && v.isNotEmpty ? null : 'Required',
                    maxLength: 70,
                    inputFormatters: [LengthLimitingTextInputFormatter(70)],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phone,
                    decoration:
                        const InputDecoration(labelText: 'Mobile Number'),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    maxLength: 12,
                    inputFormatters: [LengthLimitingTextInputFormatter(12)],
                    validator: (v) => v != null && phoneRegex.hasMatch(v)
                        ? null
                        : 'Enter valid 10-digit mobile no.',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: address,
                    decoration:
                        const InputDecoration(labelText: 'Shipping Address'),
                    maxLength: 200,
                    inputFormatters: [LengthLimitingTextInputFormatter(200)],
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        v != null && v.isNotEmpty ? null : 'Required',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: password,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    maxLength: 40,
                    inputFormatters: [LengthLimitingTextInputFormatter(40)],
                    validator: (v) =>
                        v != null && v.length >= 6 ? null : 'Min 6 chars',
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: loading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              _startOtpFlow();
                            }
                          },
                    child: loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create & Continue'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _startOtpFlow() {
    setState(() {
      loading = true;
      error = null;
    });

    final mobile = "91${phone.text.trim()}";

    // Directly send OTP without hCaptcha
    OTPService.sendOtp(mobile, onSuccess: (data) {
      setState(() => loading = false);
      final reqId = data['requestId'];
      _showOtpDialog(mobile, reqId);
    }, onError: (_) {
      setState(() {
        loading = false;
        error = "Failed to send OTP. Try again.";
      });
    });
  }

  void _showOtpDialog(String mobile, String reqId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => OtpPopup(
        mobile: mobile,
        reqId: reqId,
        onClose: () => Navigator.pop(ctx),
        onVerified: () {
          Navigator.pop(ctx);
          verifiedPhone = mobile;
          _registerUser();
        },
      ),
    );
  }

  Future<void> _registerUser() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final userDetails = {
        'name': name.text.trim(),
        'username': verifiedPhone ?? phone.text.trim(),
        'mobileno': verifiedPhone ?? phone.text.trim(),
        'password': password.text,
        'address': address.text.trim(),
        'fcmtoken': FirebaseService.token ?? "",
      };

      User? user = await userDetailsController.registerUser(userDetails);
      if (user == null) {
        setState(() => error = 'Registration failed');
        return;
      }

      await StorageUtil.saveUserLocally(user);
      await firestoreController.signInFirebaseWithCustomToken(user.uid!);

      final redirectTo = widget.next ??
          (widget.flow == 'checkout' && widget.slug != null
              ? CommonMethods.buildRedirectUrl(AppRouteConstants.orderSummary,
                  slug: widget.slug)
              : AppRouteConstants.homeScreen);

      if (mounted) context.go(redirectTo);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }
}
