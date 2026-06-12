import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Enable edge-to-edge at startup so the transparent system bars set by
  // the AnnotatedRegion apply on the first frame, not only after a theme
  // change forces them to re-apply.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  setupLocator();
  runApp(const MyApp());
}
