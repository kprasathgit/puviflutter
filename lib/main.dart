import 'package:flutter/material.dart';

import 'src/app.dart';
import 'package:url_strategy/url_strategy.dart';

void main() async {
  setPathUrlStrategy();
  runApp(MyApp());
}
