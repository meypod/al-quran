import 'package:flutter/services.dart' show rootBundle;
import '../model/surah.dart';

class SurahListProvider {
  static Future<List<Surah>> loadSurahs() async {
    final data = await rootBundle.loadString('assets/quran/surahs.txt');
    final lines = data.split('\n');
    // Ignore the first line (header)
    return lines
        .skip(1)
        .where((line) => line.trim().isNotEmpty)
        .map((line) => Surah.fromLine(line))
        .toList();
  }
}
