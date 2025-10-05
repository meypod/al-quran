// '٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'
/// Utility for converting numbers to Arabic-Indic numerals.
String toIndicArabicNumber(int number) {
  // Efficiently converts an integer to a string with Arabic-Indic numerals
  final input = number.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < input.length; i++) {
    final codeUnit = input.codeUnitAt(i);
    if (codeUnit >= 48 && codeUnit <= 57) {
      buffer.writeCharCode(0x0660 + (codeUnit - 48));
    } else {
      buffer.writeCharCode(codeUnit);
    }
  }
  return buffer.toString();
}

// '۰','۱','۲','۳','۴','۵','۶','۷','۸','۹'
/// Utility for converting numbers to Eastern Arabic numerals (Persian/Urdu style).
String toEasternArabicNumber(int number) {
  // Efficiently converts an integer to a string with Eastern Arabic numerals (Persian/Urdu style)
  final input = number.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < input.length; i++) {
    final codeUnit = input.codeUnitAt(i);
    if (codeUnit >= 48 && codeUnit <= 57) {
      buffer.writeCharCode(0x06F0 + (codeUnit - 48));
    } else {
      buffer.writeCharCode(codeUnit);
    }
  }
  return buffer.toString();
}

var toArabicNumber = toIndicArabicNumber;

final RegExp otherNumbersRegexp = RegExp(r'[\u0660-\u0669\u06F0-\u06F9]');

/// Converts a string containing Arabic-Indic or Eastern Arabic numerals to English digits.
String toEnglishDigits(String s) {
  return s.replaceAllMapped(otherNumbersRegexp, (match) {
    final codeUnit = match.group(0)!.codeUnitAt(0);
    return String.fromCharCode(0x30 + (codeUnit & 0xF));
  });
}
