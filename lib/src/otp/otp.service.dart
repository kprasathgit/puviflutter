import 'dart:js' as js;
import 'dart:html' as html;

class OTPService {
  /// Check if running on localhost (dev mode)
  static bool get isLocalhost {
    final host = html.window.location.hostname;
    return host == 'localhost' || host == '127.0.0.1';
  }

  /// Send OTP directly (no hCaptcha)
  static void sendOtp(String mobile,
      {Function(dynamic)? onSuccess, Function(dynamic)? onError}) {
    if (isLocalhost) {
      Future.delayed(const Duration(milliseconds: 500),
          () => onSuccess?.call({'requestId': 'dev-test-otp'}));
      return;
    }

    try {
      js.context.callMethod('sendOtpFromFlutter', [
        mobile,
        onSuccess != null ? js.allowInterop(onSuccess) : null,
        onError != null
            ? js.allowInterop((err) {
                final msg = err?.toString() ?? 'Unknown JS error';
                onError({'error': msg});
              })
            : null,
      ]);
    } catch (e) {
      onError?.call({'error': e.toString()});
    }
  }

  /// Verify OTP
  static void verifyOtp(String otp, String reqId,
      {Function(dynamic)? onSuccess, Function(dynamic)? onError}) {
    if (isLocalhost) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (otp == '123456') {
          onSuccess?.call({'status': 'success'});
        } else {
          onError?.call({'error': 'Invalid OTP'});
        }
      });
      return;
    }

    try {
      js.context.callMethod('verifyOtpFromFlutter', [
        otp,
        reqId,
        onSuccess != null ? js.allowInterop(onSuccess) : null,
        onError != null
            ? js.allowInterop((err) {
                final msg = err?.toString() ?? 'Unknown JS error';
                onError({'error': msg});
              })
            : null,
      ]);
    } catch (e) {
      onError?.call({'error': e.toString()});
    }
  }

  /// Retry OTP
  static void retryOtp(String reqId,
      {Function(dynamic)? onSuccess, Function(dynamic)? onError}) {
    if (isLocalhost) {
      Future.delayed(const Duration(milliseconds: 300),
          () => onSuccess?.call({'requestId': reqId}));
      return;
    }

    try {
      js.context.callMethod('retryOtpFromFlutter', [
        reqId,
        onSuccess != null ? js.allowInterop(onSuccess) : null,
        onError != null
            ? js.allowInterop((err) {
                final msg = err?.toString() ?? 'Unknown JS error';
                onError({'error': msg});
              })
            : null,
      ]);
    } catch (e) {
      onError?.call({'error': e.toString()});
    }
  }
}
