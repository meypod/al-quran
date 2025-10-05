part of 'quran_bloc.dart';

abstract class QuranState {}

class QuranInitial extends QuranState {}

class QuranLoading extends QuranState {}

class QuranLoaded extends QuranState {
  final List<Surah> surahs;
  final List<QuranVerse> quranVerses;
  final List<QuranVerse> quranCleanVerses;
  QuranLoaded({
    required this.surahs,
    required this.quranVerses,
    required this.quranCleanVerses,
  });
}

class QuranError extends QuranState {
  final String message;
  QuranError({required this.message});
}
