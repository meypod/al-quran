class Surah {
  final int id;
  final String name;
  final String type; // 'k' = meccan, 'm' = medinan
  final int totalVerses;
  final int startsAtJuz;
  final int endsAtJuz;
  final bool hasBismillah;

  Surah({
    required this.id,
    required this.name,
    required this.type,
    required this.totalVerses,
    required this.startsAtJuz,
    required this.endsAtJuz,
    required this.hasBismillah,
  });

  factory Surah.fromLine(String line) {
    final parts = line.split('|');
    return Surah(
      id: int.parse(parts[0]),
      name: parts[1],
      type: parts[2],
      totalVerses: int.parse(parts[3]),
      startsAtJuz: int.parse(parts[4]),
      endsAtJuz: int.parse(parts[5]),
      hasBismillah: int.parse(parts[6]) as bool,
    );
  }
}
