part of 'quran_bloc.dart';

abstract class QuranState {}

class QuranInitial extends QuranState {}

class QuranLoading extends QuranState {}

class QuranLoaded extends QuranState {
  final QuranVerse bismillah;
  final List<Surah> surahs;
  final List<QuranVerse> quranVerses;
  final List<QuranVerse> quranCleanVerses;
  QuranLoaded({
    required this.bismillah,
    required this.surahs,
    required this.quranVerses,
    required this.quranCleanVerses,
  });
}

class QuranError extends QuranState {
  final Object error;
  QuranError({required this.error});
}
