import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    // Load saved theme from localStorage
    final savedTheme = html.window.localStorage['themeMode'];
    if (savedTheme != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == savedTheme,
        orElse: () => ThemeMode.system,
      );
    }
  }

  ThemeMode get themeMode => _themeMode;

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    html.window.localStorage['themeMode'] = mode.toString();
    notifyListeners();
  }
}
