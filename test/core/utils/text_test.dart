import 'package:flutter_test/flutter_test.dart';
import 'package:simple_quran/core/utils/text.dart';

void main() {
  group('keepCleanQuranText', () {
    test('keeps allowed Arabic and English characters', () {
      const input = 'بسم الله الرحمن الرحيم\nAlhamdulillah123';
      expect(simplifyText(input), input);
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

    test('disjointed letters works', () {
      const input = "كٓهيعٓصٓ";
      const expected = "کهيعص";
      expect(simplifyText(input), expected);
    });
  });
}
