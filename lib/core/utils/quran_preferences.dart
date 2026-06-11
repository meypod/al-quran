import 'package:shared_preferences/shared_preferences.dart';

class QuranPreferences {
  static const String selectedSurahKey = 'selected_surah_id';
  static const String scrollIndexKey = 'scroll_index';
  static const String scrollAlignmentKey = 'scroll_alignment';
  static const String searchTermKey = 'search_term';
  static const String searchAllQuranKey = 'search_all_quran';
  static const String fontSizeKey = 'font_size';
  static const String bookmarksKey = 'bookmarks';
  static const String skipBookmarkDeleteConfirmKey =
      'skip_bookmark_delete_confirm';

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

  static Future<void> setScrollIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(scrollIndexKey, index);
  }

  static Future<int?> getScrollIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(scrollIndexKey);
  }

  static Future<void> setScrollAlignment(double alignment) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(scrollAlignmentKey, alignment);
  }

  static Future<double?> getScrollAlignment() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(scrollAlignmentKey);
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

  /// Bookmarks stored as a list of verse keys ('surahId:verseNumber').
  static Future<void> setBookmarks(List<String> keys) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(bookmarksKey, keys);
  }

  static Future<List<String>?> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(bookmarksKey);
  }

  static Future<void> setSkipBookmarkDeleteConfirm(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(skipBookmarkDeleteConfirmKey, value);
  }

  static Future<bool> getSkipBookmarkDeleteConfirm() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(skipBookmarkDeleteConfirmKey) ?? false;
  }
}
