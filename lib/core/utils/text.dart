import 'arabic_number_util.dart';

final RegExp alifRegExp = RegExp(r'[اإأآ\u0671\u0670]', unicode: true);
// ٔ is the combining hamza above. In the Uthmani text the ya-seat hamza is
// encoded as tatweel + ٔ (e.g. يَسْـَٔلُونَ) instead of the precomposed ئ.
// Treat it as a ya variant so it stays searchable, and exclude it from
// abnormalChars below so it is not stripped as a diacritic.
final RegExp yaRegExp = RegExp(r'[يیئٔ]', unicode: true);
// Any hamza form: the carriers (أ ؤ إ ئ) plus the seat-neutral Uthmani rasm
// forms — bare ء and the combining hamza above ٔ.
final RegExp hamzaRegExp = RegExp(r'[ءأؤإئٔ]', unicode: true);
// The seat-neutral hamza forms used by the Uthmani rasm. A hamza on these
// seats varies against whatever carrier the reader would type from memory:
//   يسـٔلون (ٔ) ↔ يسألون (أ),  رَءُوف (ء) ↔ رؤوف (ؤ).
// So in search a carrier matches its own seat plus these neutrals, and a
// neutral matches every seat. Carriers are NOT merged with each other: the
// seat follows the word's vowel, so أ and ؤ never spell the same word.
final RegExp neutralHamzaRegExp = RegExp(r'[ءٔ]', unicode: true);
final RegExp differentKafs = RegExp(r'[كک]', unicode: true);
final RegExp abnormalChars = RegExp(
  r'[\ufdf0-\ufdfd\u060c-\u060f\u061b\u061e\u061f\u066d\u06d4\u06dd\u06de\u06e9\u06fd\ufd3e\ufd3f'
  r'\u064b-\u0653\u0655-\u065f\u0670\u0615-\u061A\u06D6-\u06EDـ]', // expanded diacritics range
  unicode: true,
);

String simplifyText(String input) {
  // Normalize p_alef variants to ا
  return input
      .replaceAll(alifRegExp, 'ا')
      .replaceAll(yaRegExp, 'ي')
      .replaceAll(differentKafs, 'ک')
      .replaceAll(abnormalChars, '');
}

String arabicResultLabel(int count) {
  if (count == 0) return 'لا نتائج';
  if (count == 1) return 'نتيجة واحدة';
  if (count == 2) return 'نتيجتان';
  return '${toArabicNumber(count)} نتائج';
}

/// Converts a simplified search term into a regex pattern that matches the term in the original text,
/// allowing for optional abnormal/diacritic chars between each character, and matching all alif, ya, and kaf variants.
/// Example: "سلام" => r'[اإأآ\u0671\u0670][\ufdf0-\ufdfd\u060c-\u060f\u061b\u061e\u061f\u066d\u06d4\u06dd\u06de\u06e9\u06fd\ufd3e\ufd3f\u064b-\u0653\u0655-\u065f\u0670\u0615-\u061A\u06D6-\u06EDـ]*ل[...]*ا[...]*م'
/// Contents of a single-class regex `[...]` without the brackets, so several
/// classes can be merged into one. Precomputed once instead of per character.
String _classBody(RegExp r) => r.pattern.substring(1, r.pattern.length - 1);

final String _alifBody = _classBody(alifRegExp);
final String _yaBody = _classBody(yaRegExp);
final String _hamzaBody = _classBody(hamzaRegExp);
final String _neutralHamzaBody = _classBody(neutralHamzaRegExp);
// In the Uthmani rasm a waqf mark sits between two words flanked by spaces
// (e.g. "...بَ ۗ كَ..."). The mark itself is an abnormal char, but the extra
// space around it is not, so a single query space could not bridge the gap.
// Treat a query space as a run of whitespace and interleaved abnormal chars.
final String _abnormalBody = _classBody(abnormalChars);

RegExp regexifySearchTerm(String searchTerm) {
  // Use the abnormalChars pattern as the diacritics/abnormal chars between letters
  // Remove the outer slashes and 'r' from abnormalChars.pattern
  final abnormalPattern = abnormalChars.pattern;
  final buffer = StringBuffer();
  for (int i = 0; i < searchTerm.length; i++) {
    String char = searchTerm[i];
    String regexChar;
    if (hamzaRegExp.hasMatch(char)) {
      // A neutral hamza matches every seat; a carrier matches its own seat
      // plus the neutrals. Keep the carrier's alef/ya leniency too (e.g. أ
      // should still match a plain ا).
      var body = neutralHamzaRegExp.hasMatch(char)
          ? _hamzaBody
          : char + _neutralHamzaBody;
      if (alifRegExp.hasMatch(char)) body += _alifBody;
      if (yaRegExp.hasMatch(char)) body += _yaBody;
      regexChar = '[$body]';
    } else if (alifRegExp.hasMatch(char)) {
      regexChar = alifRegExp.pattern;
    } else if (yaRegExp.hasMatch(char)) {
      regexChar = yaRegExp.pattern;
    } else if (differentKafs.hasMatch(char)) {
      regexChar = differentKafs.pattern;
    } else if (char == ' ') {
      regexChar = '[\\s$_abnormalBody]+';
    } else {
      regexChar = RegExp.escape(char);
    }
    buffer.write(regexChar);
    buffer.write('$abnormalPattern*');
  }
  return RegExp(buffer.toString(), unicode: true);
}
