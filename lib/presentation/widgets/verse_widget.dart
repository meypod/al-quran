// Widget to render a Quran verse with number at the end
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:al_quran/core/data/model/quran_verse.dart';
import 'package:al_quran/core/data/model/surah.dart';
import 'package:al_quran/locator.dart';
import 'package:al_quran/core/bloc/quran/quran_bloc.dart';

import '../../core/utils/arabic_number_util.dart';

class VerseWidget extends StatelessWidget {
  final QuranVerse verse;
  final bool isSearchResult;
  final List<(int, int)> highlights;

  const VerseWidget({
    super.key,
    required this.verse,
    required this.isSearchResult,
    required this.highlights,
  });

  @override
  Widget build(BuildContext context) {
    String? surahName;
    if (isSearchResult) {
      final quranBloc = getIt<QuranBloc>();
      if (quranBloc.state is QuranLoaded) {
        final surah =
            (quranBloc.state as QuranLoaded).surahs.elementAtOrNull(
              verse.surahId - 1,
            ) ??
            Surah(
              // unlikely to happen, but added just to be safe
              id: verse.surahId,
              name: '',
              type: '',
              totalVerses: 0,
              startsAtJuz: 0,
              endsAtJuz: 0,
              hasBismillah: false,
            );
        surahName = "${surah.name} (${toArabicNumber(verse.surahId)})";
      }
    }
    return ListTile(
      title: buildHighlightedText(context),
      subtitle: surahName != null && surahName.isNotEmpty
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
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  tooltip: 'نسخ',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _copyVerse(context, surahName!),
                ),
              ],
            )
          : null,
    );
  }

  void _copyVerse(BuildContext context, String surahName) {
    final verseLine =
        verse.verseText +
        (verse.verseNumber == 0
            ? ''
            : ' ﴿${toArabicNumber(verse.verseNumber)}﴾');
    final text = '$verseLine\n$surahName\n';
    Clipboard.setData(ClipboardData(text: text));
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
