import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:puvi/src/otp/otp.service.dart';

class OtpPopup extends StatefulWidget {
  final String mobile;
  final String reqId;
  final VoidCallback onClose;
  final VoidCallback onVerified;

  const OtpPopup({
    super.key,
    required this.mobile,
    required this.reqId,
    required this.onClose,
    required this.onVerified,
  });

  @override
  State<OtpPopup> createState() => _OtpPopupState();
}

class _OtpPopupState extends State<OtpPopup> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  String errorMessage = "";
  Timer? countdownTimer;
  int secondsRemaining = 30;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    countdownTimer?.cancel();
    setState(() => secondsRemaining = 30);
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() => secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  void _verifyOtp() {
    if (otpController.text.isEmpty) return;
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    OTPService.verifyOtp(otpController.text.trim(), widget.reqId,
        onSuccess: (_) => widget.onVerified(),
        onError: (_) {
          setState(() {
            errorMessage = "Invalid OTP. Try again.";
            isLoading = false;
          });
        });
  }

  void _resendOtp() {
    OTPService.retryOtp(widget.reqId, onSuccess: (_) {
      setState(() {
        secondsRemaining = 30;
        _startTimer();
        errorMessage = ""; // clear previous error
      });
    }, onError: (err) {
      setState(() {
        print(err['error']??"");
        errorMessage = "Failed to resend OTP.";
      });
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxWidth = width < 500 ? width * 0.9 : 400.0; // responsive width

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Verify OTP",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                      onPressed: widget.onClose, icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 12),
              Text("OTP sent to ${widget.mobile}",
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              // Pinput
              Pinput(
                controller: otpController,
                length: 6,
                defaultPinTheme: PinTheme(
                  width: maxWidth / 8,
                  height: maxWidth / 8,
                  textStyle: TextStyle(
                    fontSize: maxWidth / 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 10),
              if (errorMessage.isNotEmpty)
                Text(errorMessage, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 24),
              ElevatedButton(
                  onPressed: isLoading ? null : _verifyOtp,
                  style:
                      ElevatedButton.styleFrom(minimumSize: Size(maxWidth, 48)),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Verify")),

              const SizedBox(height: 12),
              secondsRemaining > 0
                  ? Text("Resend OTP in $secondsRemaining s")
                  : TextButton(
                      onPressed: _resendOtp, child: const Text("Resend OTP")),
            ],
          ),
        ),
      ),
    );
  }
}
