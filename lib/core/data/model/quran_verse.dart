class QuranVerse {
  final int surahId;
  final int verseNumber;
  final String verseText;

  /// Returns a unique key for this verse in the form 'surahId:verseNumber'.
  String get key => '$surahId:$verseNumber';

  QuranVerse({
    required this.surahId,
    required this.verseNumber,
    required this.verseText,
  });

  QuranVerse copyWith({
    int? surahId,
    int? verseNumber,
    String? verseText,
    String? cleanVerseText,
  }) {
    return QuranVerse(
      surahId: surahId ?? this.surahId,
      verseNumber: verseNumber ?? this.verseNumber,
      verseText: verseText ?? this.verseText,
    );
  }

  factory QuranVerse.fromLine(String line) {
    final parts = line.split('|');
    return QuranVerse(
      surahId: int.parse(parts[0]),
      verseNumber: int.parse(parts[1]),
      verseText: parts[2],
    );
  }
}
