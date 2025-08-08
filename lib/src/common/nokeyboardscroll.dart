import 'package:flutter/widgets.dart';

class NoKeyboardScroll extends InheritedWidget {
  const NoKeyboardScroll({super.key, required super.child});

  static bool of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NoKeyboardScroll>() != null;
  }

  @override
  bool updateShouldNotify(NoKeyboardScroll oldWidget) => false;
}
