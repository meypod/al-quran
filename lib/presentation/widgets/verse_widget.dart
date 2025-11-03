// Widget to render a Quran verse with number at the end
import 'package:flutter/material.dart';

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
          ? Text(
              surahName,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.grey),
            )
          : null,
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
    return RichText(
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      text: TextSpan(style: defaultStyle, children: spans),
    );
  }
}
