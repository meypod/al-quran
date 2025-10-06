import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

class QuranTextProvider {
  /// returns two versions of quran:
  /// 1. Quran **with** diacritics
  /// 2. Quran without diacritics
  static Future<List<String>> loadQuranText() async {
    final raw = await rootBundle.loadString('assets/quran/quran-uthmani.txt');
    var rawLines = raw.split('\n');
    // remove copyright block
    rawLines.removeRange(rawLines.length - 30, rawLines.length);
    rawLines = rawLines.where((line) => line.trim().isNotEmpty).toList();
    return rawLines;
  }
}
