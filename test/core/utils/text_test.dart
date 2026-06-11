import 'package:flutter_test/flutter_test.dart';
import 'package:al_quran/core/utils/text.dart';

void main() {
  // In the Uthmani text the ya-seat hamza is encoded as tatweel + combining
  // hamza above (U+0640 U+0654), e.g. in يَسْـَٔلُونَ ("yas'alūna").
  const yasaluuna = 'يَسْـَٔلُونَ';

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

    test('alifs are expected', () {
      const input = "ٱللَّهِ";
      const expected = "الله";
      expect(simplifyText(input), expected);
    });

    test('contain works as expected on normalized alif', () {
      final input = simplifyText("ٱللَّهِ");
      const searchTerm = "الله";
      expect(input.contains(searchTerm), true);
    });

    test('ya-seat hamza is kept as a ya, not stripped', () {
      // tatweel + combining hamza collapses to ي, like the precomposed ئ.
      expect(simplifyText(yasaluuna), 'يسيلون');
    });
  });

  group('regexifySearchTerm hamza handling', () {
    test('matches verse when searching with hamza form', () {
      expect(regexifySearchTerm('يسئلون').hasMatch(yasaluuna), true);
    });

    test('matches regardless of ya/hamza variant used', () {
      // Persian ya + precomposed ئ.
      expect(regexifySearchTerm('یسئلون').hasMatch(yasaluuna), true);
    });

    test('does not match when the hamza letter is omitted', () {
      expect(regexifySearchTerm('يسلون').hasMatch(yasaluuna), false);
    });

    test('alef-seat hamza أ matches ya-seat hamza in text', () {
      // يسألون (alef-seat) should find the Uthmani يسـٔلون (ya-seat).
      expect(regexifySearchTerm('يسألون').hasMatch(yasaluuna), true);
    });

    test('plain alef does not match a hamza', () {
      // ا is not a hamza, so it must not match the ya-seat hamza.
      expect(regexifySearchTerm('يسالون').hasMatch(yasaluuna), false);
    });

    test('carrier ؤ matches bare ء in text', () {
      const rauuf = 'رَءُوفٌ'; // Uthmani رَءُوف, imla'i رؤوف
      expect(regexifySearchTerm('رؤوف').hasMatch(rauuf), true);
    });

    test('bare ء query matches a carrier seat in text', () {
      const muumin = 'مُؤْمِنٌ'; // carrier ؤ in text
      expect(regexifySearchTerm('مءمن').hasMatch(muumin), true);
    });

    test('different carriers do not match each other', () {
      // أ and ؤ never spell the same word; searching أ must not match ؤ.
      const muumin = 'مُؤْمِنٌ';
      expect(regexifySearchTerm('مأمن').hasMatch(muumin), false);
    });
  });
}
