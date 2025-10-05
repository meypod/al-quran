part of 'quran_bloc.dart';

abstract class QuranState {}

class QuranInitial extends QuranState {}

class QuranLoading extends QuranState {}

class QuranLoaded extends QuranState {
  final List<Surah> surahs;
  final Surah selectedSurah;
  final List<QuranVerse> filteredVerses;
  final double scrollOffset;
  final String searchTerm;
  QuranLoaded({
    required this.surahs,
    required this.selectedSurah,
    required this.filteredVerses,
    required this.scrollOffset,
    required this.searchTerm,
  });
}

class QuranError extends QuranState {
  final String message;
  QuranError({required this.message});
}
