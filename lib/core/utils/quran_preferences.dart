import 'package:shared_preferences/shared_preferences.dart';

class QuranPreferences {
  static const String selectedSurahKey = 'selected_surah_id';
  static const String scrollPositionKey = 'scroll_position';
  static const String searchTermKey = 'search_term';
  static const String searchAllQuranKey = 'search_all_quran';
  static const String fontSizeKey = 'font_size';

  static Future<void> setFontSize(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(fontSizeKey, value);
  }

  static Future<double?> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(fontSizeKey);
  }

  static Future<void> setSelectedSurah(int surahId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(selectedSurahKey, surahId);
  }

  static Future<int?> getSelectedSurah() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(selectedSurahKey);
  }

  static Future<void> setScrollPosition(double position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(scrollPositionKey, position);
  }

  static Future<double?> getScrollPosition() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(scrollPositionKey);
  }

  static Future<void> setSearchTerm(String term) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(searchTermKey, term);
  }

  static Future<String?> getSearchTerm() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(searchTermKey);
  }

  static Future<void> setSearchAllQuran(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(searchAllQuranKey, value);
  }

  static Future<bool?> getSearchAllQuran() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(searchAllQuranKey);
  }
}
