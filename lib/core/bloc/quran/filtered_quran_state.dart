import '../../data/model/quran_verse.dart';
import '../../data/model/surah.dart';

class FilteredQuranLoading extends FilteredQuranState {}

class FilteredQuranError extends FilteredQuranState {
  final String message;
  FilteredQuranError({required this.message});
}

abstract class FilteredQuranState {}

class FilteredQuranInitial extends FilteredQuranState {}

class FilteredQuranLoaded extends FilteredQuranState {
  final Surah? selectedSurah;
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
