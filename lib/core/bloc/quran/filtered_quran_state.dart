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
  final int scrollIndex;
  final double scrollAlignment;
  final String searchTerm;
  final bool searchAllQuran;
  final Map<String, List<(int, int)>> highlightMap;

  /// Bumped on every explicit jump (bookmark/verse navigation). Carried into
  /// the list's key so a jump always recreates the list — even when the target
  /// index equals the last emitted [scrollIndex] (ordinary scrolls don't emit,
  /// so [scrollIndex] alone can't distinguish a re-jump to the same verse).
  final int navEpoch;

  FilteredQuranLoaded({
    required this.selectedSurah,
    required this.filteredVerses,
    required this.scrollIndex,
    required this.scrollAlignment,
    required this.searchTerm,
    required this.searchAllQuran,
    this.highlightMap = const {},
    this.navEpoch = 0,
  });
}
