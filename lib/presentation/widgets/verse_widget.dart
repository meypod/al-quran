// Widget to render a Quran verse with number at the end
import 'package:flutter/material.dart';

import 'package:simple_quran/core/data/model/quran_verse.dart';
import 'package:simple_quran/core/data/model/surah.dart';
import 'package:simple_quran/locator.dart';
import 'package:simple_quran/core/bloc/quran/quran_bloc.dart';

import '../../core/utils/arabic_number_util.dart';

class VerseWidget extends StatelessWidget {
  final QuranVerse verse;
  final bool isSearchResult;

  const VerseWidget({
    super.key,
    required this.verse,
    required this.isSearchResult,
  });

  @override
  Widget build(BuildContext context) {
    if (!isSearchResult) {
      return ListTile(
        title: SelectableText(
          verse.verseText +
              (verse.verseNumber == 0
                  ? ''
                  : ' ﴿${toArabicNumber(verse.verseNumber)}﴾'),
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
        ),
      );
    }
    // If isGlobalResult, get surah name from QuranBloc (via locator)
    final quranBloc = getIt<QuranBloc>();
    String? surahName;
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
    return ListTile(
      title: SelectableText(
        verse.verseText +
            (verse.verseNumber == 0
                ? ''
                : ' ﴿${toArabicNumber(verse.verseNumber)}﴾'),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
      ),
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
}
