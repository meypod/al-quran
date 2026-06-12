import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/bloc/bookmark/bookmark_bloc.dart';
import '../../core/bloc/font_size/font_size_bloc.dart';
import '../../core/bloc/quran/quran_bloc.dart';
import '../../core/data/model/quran_verse.dart';
import '../../core/data/model/surah.dart';
import '../../core/utils/arabic_number_util.dart';
import '../../core/utils/quran_preferences.dart';
import '../../core/utils/text.dart';
import '../../locator.dart';

/// A bookmarked verse paired with its resolved surah name, plus a
/// normalized haystack used for searching.
class _BookmarkEntry {
  final QuranVerse verse;
  final String surahName;
  final String haystack;
  _BookmarkEntry({
    required this.verse,
    required this.surahName,
    required this.haystack,
  });
}

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  final BookmarkBloc _bloc = getIt<BookmarkBloc>();
  final TextEditingController _searchController = TextEditingController();
  bool _skipDeleteConfirm = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    QuranPreferences.getSkipBookmarkDeleteConfirm().then((value) {
      if (mounted) setState(() => _skipDeleteConfirm = value);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
  }

  Future<void> _removeBookmark(QuranVerse verse) async {
    if (_skipDeleteConfirm) {
      _bloc.add(ToggleBookmark(verse.key));
      return;
    }
    bool dontAskAgain = false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إزالة العلامة؟', textDirection: TextDirection.rtl),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                value: dontAskAgain,
                onChanged: (v) =>
                    setDialogState(() => dontAskAgain = v ?? false),
                title: const Text(
                  'عدم السؤال مرة أخرى',
                  textDirection: TextDirection.rtl,
                ),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('إزالة'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    if (dontAskAgain) {
      await QuranPreferences.setSkipBookmarkDeleteConfirm(true);
      if (mounted) setState(() => _skipDeleteConfirm = true);
    }
    _bloc.add(ToggleBookmark(verse.key));
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف كل العلامات؟', textDirection: TextDirection.rtl),
        content: const Text(
          'سيتم حذف جميع العلامات المحفوظة.',
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('حذف الكل'),
          ),
        ],
      ),
    );
    if (confirmed == true) _bloc.add(ClearBookmarks());
  }

  /// Resolves bookmark keys to entries in stored order, skipping unknowns.
  List<_BookmarkEntry> _resolve(Iterable<String> keys) {
    final quranState = getIt<QuranBloc>().state;
    if (quranState is! QuranLoaded) return const [];
    final byKey = {for (final v in quranState.quranVerses) v.key: v};
    final surahNames = <int, String>{
      for (final Surah s in quranState.surahs) s.id: s.name,
    };
    final entries = <_BookmarkEntry>[];
    for (final key in keys) {
      final verse = byKey[key];
      if (verse == null) continue;
      final surahName = surahNames[verse.surahId] ?? '';
      final haystack = toEnglishDigits(
        simplifyText(
          '${verse.verseText} $surahName ${verse.surahId} ${verse.verseNumber}',
        ),
      );
      entries.add(
        _BookmarkEntry(verse: verse, surahName: surahName, haystack: haystack),
      );
    }
    return entries;
  }

  List<_BookmarkEntry> _filter(List<_BookmarkEntry> entries, String term) {
    if (term.isEmpty) return entries;
    final cleaned = toEnglishDigits(simplifyText(term));
    if (cleaned.isEmpty) return entries;
    return entries.where((e) => e.haystack.contains(cleaned)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final double fontSize = context.select<FontSizeBloc, double>(
      (bloc) => bloc.state.fontSize,
    );
    final double toolbarHeight = 56.0 + (fontSize - 22.0) * 1.2;
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (context.canPop()) context.pop();
        },
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('العلامات'),
          centerTitle: true,
          toolbarHeight: toolbarHeight.clamp(56.0, 120.0),
          actions: [
            BlocBuilder<BookmarkBloc, BookmarkState>(
              bloc: _bloc,
              builder: (context, state) => IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                tooltip: 'حذف الكل',
                onPressed: state.bookmarks.isEmpty ? null : _clearAll,
              ),
            ),
          ],
        ),
        body: BlocBuilder<BookmarkBloc, BookmarkState>(
          bloc: _bloc,
          builder: (context, state) {
            final term = _searchController.text.trimLeft();
            final all = _resolve(state.bookmarks);
            final entries = _filter(all, term);
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: 'بحث في العلامات',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Theme.of(context).canvasColor,
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: _clearSearch,
                                )
                              : null,
                        ),
                        style: const TextStyle(fontFamily: 'nonexisting'),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: entries.isEmpty
                      ? Center(
                          child: Text(
                            all.isEmpty ? 'لا توجد علامات' : 'لا توجد نتائج',
                            textDirection: TextDirection.rtl,
                          ),
                        )
                      : ListView.separated(
                          itemCount: entries.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) =>
                              _buildTile(context, entries[index]),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, _BookmarkEntry entry) {
    final verse = entry.verse;
    return ListTile(
      onTap: () => context.pop(verse),
      leading: IconButton(
        icon: const Icon(Icons.bookmark_remove_outlined),
        tooltip: 'إزالة العلامة',
        onPressed: () => _removeBookmark(verse),
      ),
      title: Text(
        verse.verseText,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${entry.surahName} (${toArabicNumber(verse.surahId)}) - ${toArabicNumber(verse.verseNumber)}',
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
