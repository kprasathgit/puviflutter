import 'dart:js' as js;
import 'dart:html' as html;

class OTPService {
  static bool get isLocalhost {
    final host = html.window.location.hostname;
    return host == 'localhost' || host == '127.0.0.1';
  }

  /// Run hCaptcha before sending OTP
  static void runCaptcha(Function(String token) onSuccess, {Function? onError}) {
    if (isLocalhost) {
      Future.delayed(const Duration(milliseconds: 200), () => onSuccess('dev-mock-token'));
      return;
    }

    js.context.callMethod('runHCaptcha', [js.allowInterop((token) {
      if (token != null && token is String && token.isNotEmpty) {
        onSuccess(token);
      } else {
        if (onError != null) onError();
      }
    })]);
  }

  /// Send OTP after hCaptcha success
  static void sendOtp(String mobile,
      {Function(dynamic)? onSuccess, Function(dynamic)? onError}) {
    runCaptcha((token) {
      print('hCaptcha token: $token');
      if (isLocalhost) {
        Future.delayed(const Duration(milliseconds: 500),
            () => onSuccess?.call({'requestId': 'dev-test-otp'}));
        return;
      }
      js.context.callMethod('sendOtpFromFlutter', [
        mobile,
        onSuccess != null ? js.allowInterop(onSuccess) : null,
        onError != null ? js.allowInterop(onError) : null,
      ]);
    }, onError: onError);
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

    js.context.callMethod('verifyOtpFromFlutter', [
      otp,
      reqId,
      onSuccess != null ? js.allowInterop(onSuccess) : null,
      onError != null ? js.allowInterop(onError) : null,
    ]);
  }

  /// Retry OTP
  static void retryOtp(String reqId,
      {Function(dynamic)? onSuccess, Function(dynamic)? onError}) {
    if (isLocalhost) {
      Future.delayed(const Duration(milliseconds: 300),
          () => onSuccess?.call({'requestId': reqId}));
      return;
    }

    js.context.callMethod('retryOtpFromFlutter', [
      reqId,
      onSuccess != null ? js.allowInterop(onSuccess) : null,
      onError != null ? js.allowInterop(onError) : null,
    ]);
  }
}
