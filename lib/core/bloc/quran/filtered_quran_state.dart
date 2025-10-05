part of 'filtered_quran_bloc.dart';

abstract class FilteredQuranState {}

class FilteredQuranInitial extends FilteredQuranState {}

class FilteredQuranLoaded extends FilteredQuranState {
  final Surah selectedSurah;
  final List<QuranVerse> filteredVerses;
  final double scrollOffset;
  final String searchTerm;
  FilteredQuranLoaded({
    required this.selectedSurah,
    required this.filteredVerses,
    required this.scrollOffset,
    required this.searchTerm,
  });
}

class FilteredQuranError extends FilteredQuranState {
  final String message;
  FilteredQuranError({required this.message});
}
