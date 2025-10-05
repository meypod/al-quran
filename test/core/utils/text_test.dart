import 'package:flutter_test/flutter_test.dart';
import 'package:simple_quran/core/utils/text.dart';

void main() {
  group('keepCleanQuranText', () {
    test('removes disallowed characters', () {
      const input = 'Hello! مرحبا@123#';
      // Only allowed: letters, numbers, Arabic, spaces, and newlines
      const expected = 'Hello مرحبا123';
      expect(simplifyText(input), expected);
    });

    test('keeps allowed Arabic and English characters', () {
      const input = 'بسم الله الرحمن الرحيم\nAlhamdulillah123';
      expect(simplifyText(input), input);
    });

    test('removes symbols and punctuation', () {
      const input = 'Quran: سورة! 2, آية (3)';
      const expected = 'Quran سورة 2 آية 3';
      expect(simplifyText(input), expected);
    });

    test('keeps newlines', () {
      const input = 'Line1\nLine2\nسطر3';
      expect(simplifyText(input), input);
    });

    test('removes arabic diacritics', () {
      const input = "بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ";
      const expected = 'بسم الله الرحمان الرحيم';
      expect(simplifyText(input), expected);
    });
  });
}
