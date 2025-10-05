import 'package:shared_preferences/shared_preferences.dart';

class QuranPreferences {
  static const String selectedSurahKey = 'selected_surah_id';
  static const String scrollPositionKey = 'scroll_position';

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
}
