class QuranVerse {
  final int surahId;
  final int verseNumber;
  final String verseText;

  QuranVerse({
    required this.surahId,
    required this.verseNumber,
    required this.verseText,
  });

  factory QuranVerse.fromLine(String line) {
    final parts = line.split('|');
    return QuranVerse(
      surahId: int.parse(parts[0]),
      verseNumber: int.parse(parts[1]),
      verseText: parts.sublist(2).join('|').trim(),
    );
  }
}
