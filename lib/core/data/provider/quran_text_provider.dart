import 'dart:async';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/services.dart' show rootBundle;

class QuranTextProvider {
  /// returns two versions of quran:
  /// 1. Quran **with** diacritics
  /// 2. Quran without diacritics
  static Future<(List<String>, List<String>)> loadQuranText() async {
    final raw = await rootBundle.loadString('assets/quran/quran-uthmani.txt');
    final clean = removeDiacritics(raw);
    var rawLines = raw.split('\n');
    // remove copyright block
    rawLines.removeRange(rawLines.length - 30, rawLines.length);
    rawLines = rawLines.where((line) => line.trim().isNotEmpty).toList();

    var cleanLines = clean.split('\n');
    // remove copyright block
    cleanLines.removeRange(cleanLines.length - 30, cleanLines.length);
    cleanLines = cleanLines.where((line) => line.trim().isNotEmpty).toList();
    return (rawLines, cleanLines);
  }
}
