// Widget to render a Quran verse with number at the end
import 'package:flutter/material.dart';

import '../../core/utils/arabic_number_util.dart';

class VerseRenderer extends StatelessWidget {
  final String verseText;
  final int verseNumber;

  const VerseRenderer({
    super.key,
    required this.verseText,
    required this.verseNumber,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        '$verseText ﴿${toArabicNumber(verseNumber)}﴾',
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
      ),
      // No subtitle
    );
  }
}
