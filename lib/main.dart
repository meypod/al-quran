import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // On web the browser's native context menu fires on right-click and competes
  // with the verse row menu (verse_widget.dart onSecondaryTapDown). Suppress it
  // so the app owns right-click; copy stays available via the app menu.
  if (kIsWeb) BrowserContextMenu.disableContextMenu();
  // Enable edge-to-edge at startup so the transparent system bars set by
  // the AnnotatedRegion apply on the first frame, not only after a theme
  // change forces them to re-apply.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  setupLocator();
  runApp(const MyApp());
}
