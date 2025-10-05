import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

class QuranTextProvider {
  static Future<List<String>> loadQuranText() async {
    final raw = await rootBundle.loadString('assets/quran/quran-uthmani.txt');
    var lines = raw.split('\n');
    // remove copyright block
    lines.removeRange(lines.length - 30, lines.length);
    lines = lines.where((line) => line.trim().isNotEmpty).toList();
    return lines;
  }
}
