import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:puvi/project/routes/app_route_constants.dart';
import 'package:puvi/src/common/smartnavigator.dart';
import 'package:puvi/src/forgetpassword/forgetpassword.controller.dart';
import 'package:puvi/src/otp/otp.service.dart';
import 'package:puvi/src/otp/otpscreen.view.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final phoneController = TextEditingController();
  String? reqId;
  bool loading = false;
  String? error;
  bool isValid = false;

  late ForgetpasswordController forgetpasswordController;

  @override
  void initState() {
    super.initState();
    forgetpasswordController =
        Provider.of<ForgetpasswordController>(context, listen: false);
    phoneController.addListener(_validateInput);
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void _validateInput() {
    final input = phoneController.text.trim();
    setState(() {
      isValid = input.length == 10;
    });
  }

  void _startOtpFlow() async {
    final phoneInput = phoneController.text.trim();

    if (phoneInput.isEmpty) {
      setState(() => error = "Please enter your mobile number");
      return;
    }

    if (phoneInput.length != 10) {
      setState(() => error = "Mobile number must be 10 digits");
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    final mobileForOtp = "91$phoneInput"; // attach 91 only for OTP service

    try {
      final exists = await forgetpasswordController.checkUserExists(mobileForOtp);
      if (!exists) {
        setState(() {
          error = "User not found";
          loading = false;
        });
        return;
      }

      OTPService.sendOtp(mobileForOtp, onSuccess: (data) {
        setState(() {
          reqId = data['requestId'];
          loading = false;
        });
        _showOtpDialog(phoneInput, reqId!); // forward raw 10-digit number
      }, onError: (err) {
        setState(() {
          error = "Failed to send OTP";
          loading = false;
        });
      });
    } catch (e) {
      setState(() {
        error = "Something went wrong";
        loading = false;
      });
    }
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
          SmartNavigator.go(
            context,
            AppRouteConstants.resetPassword,
            params: {"mobile": mobile}, // raw 10-digit number only
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight - kToolbarHeight - MediaQuery.of(context).padding.top,
          width: screenWidth,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Enter your registered mobile number to reset password",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: InputDecoration(
                      labelText: "Mobile Number",
                      border: const OutlineInputBorder(),
                      //hintText: "10-digit number",
                      prefixText: "+91 ",
                      // suffixIcon: isValid
                      //     ? const Icon(Icons.check_circle, color: Colors.green)
                      //     : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isValid && !loading ? _startOtpFlow : null,
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Send OTP"),
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
