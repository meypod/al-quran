// Widget to render a Quran verse with number at the end
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:al_quran/core/data/model/quran_verse.dart';
import 'package:al_quran/locator.dart';
import 'package:al_quran/core/bloc/quran/quran_bloc.dart';

import '../../core/utils/arabic_number_util.dart';

class VerseWidget extends StatelessWidget {
  final QuranVerse verse;
  final bool isSearchResult;
  final List<(int, int)> highlights;
  final bool selectionMode;
  final bool selected;
  final VoidCallback? onSelectToggle;
  final bool isBookmarked;
  final VoidCallback? onBookmarkToggle;

  const VerseWidget({
    super.key,
    required this.verse,
    required this.isSearchResult,
    required this.highlights,
    this.selectionMode = false,
    this.selected = false,
    this.onSelectToggle,
    this.isBookmarked = false,
    this.onBookmarkToggle,
  });

  /// Resolves the display name "SurahName (arabicId)" for a verse, or '' if unknown.
  static String surahNameFor(QuranVerse verse) {
    final quranBloc = getIt<QuranBloc>();
    if (quranBloc.state is QuranLoaded) {
      final surah = (quranBloc.state as QuranLoaded).surahs.elementAtOrNull(
        verse.surahId - 1,
      );
      if (surah != null) {
        return "${surah.name} (${toArabicNumber(verse.surahId)})";
      }
    }
    return '';
  }

  /// Clipboard format: verse text + number, then surah name, each ending with \n.
  static String copyText(QuranVerse verse, String surahName) {
    final verseLine =
        verse.verseText +
        (verse.verseNumber == 0
            ? ''
            : ' ﴿${toArabicNumber(verse.verseNumber)}﴾');
    return '$verseLine\n$surahName\n';
  }

  @override
  Widget build(BuildContext context) {
    final surahName = isSearchResult ? surahNameFor(verse) : '';
    final hasSurahName = surahName.isNotEmpty;
    final canBookmark =
        !selectionMode && onBookmarkToggle != null && verse.verseNumber != 0;
    return ListTile(
      selected: selectionMode && selected,
      onTap: selectionMode ? onSelectToggle : null,
      leading: selectionMode
          ? Checkbox(value: selected, onChanged: (_) => onSelectToggle?.call())
          : canBookmark
          ? IconButton(
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                size: 30,
                color: isBookmarked
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              tooltip: isBookmarked ? 'إزالة العلامة' : 'إضافة علامة',
              visualDensity: VisualDensity.compact,
              onPressed: onBookmarkToggle,
            )
          : null,
      title: buildHighlightedText(context),
      subtitle: hasSurahName
          ? Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: Text(
                    surahName,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                if (!selectionMode)
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: 'نسخ',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _copyVerse(context, surahName),
                  ),
              ],
            )
          : null,
    );
  }

  void _copyVerse(BuildContext context, String surahName) {
    Clipboard.setData(ClipboardData(text: copyText(verse, surahName)));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم النسخ', textDirection: TextDirection.rtl),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // If isSearchResult and highlights is not empty, highlight the text
  Widget buildHighlightedText(BuildContext context) {
    if (!isSearchResult || highlights.isEmpty) {
      return Text(
        verse.verseText +
            (verse.verseNumber == 0
                ? ''
                : ' ﴿${toArabicNumber(verse.verseNumber)}﴾'),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
      );
    }

    final text = verse.verseText;
    final defaultStyle = DefaultTextStyle.of(context).style;
    final List<InlineSpan> spans = [];
    int current = 0;
    for (final (start, end) in highlights) {
      if (start > current) {
        spans.add(
          TextSpan(text: text.substring(current, start), style: defaultStyle),
        );
      }
      spans.add(
        TextSpan(
          text: text.substring(start, end),
          style: defaultStyle.copyWith(
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? const Color.fromARGB(
                    255,
                    255,
                    241,
                    117,
                  ) // intense in light mode
                : const Color.fromARGB(
                    104,
                    255,
                    246,
                    161,
                  ), // less intense in dark mode
          ),
        ),
      );
      current = end;
    }
    if (current < text.length) {
      spans.add(TextSpan(text: text.substring(current), style: defaultStyle));
    }
    // Add verse number at the end
    if (verse.verseNumber != 0) {
      spans.add(
        TextSpan(
          text: ' ﴿${toArabicNumber(verse.verseNumber)}﴾',
          style: defaultStyle,
        ),
      );
    }
    return Text.rich(
      TextSpan(style: defaultStyle, children: spans),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
    );
  }
}
