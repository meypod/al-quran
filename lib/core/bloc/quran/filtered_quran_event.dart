part of 'filtered_quran_bloc.dart';

abstract class FilteredQuranEvent {}

class FilteredQuranInit extends FilteredQuranEvent {
  final QuranLoaded quranState;
  FilteredQuranInit(this.quranState);
}

class FilteredQuranChangeSurah extends FilteredQuranEvent {
  final int surahId;
  FilteredQuranChangeSurah(this.surahId);
}

class FilteredQuranUpdateSearchTerm extends FilteredQuranEvent {
  final String searchTerm;
  FilteredQuranUpdateSearchTerm(this.searchTerm);
}

class FilteredQuranUpdateScrollOffset extends FilteredQuranEvent {
  final double scrollOffset;
  FilteredQuranUpdateScrollOffset(this.scrollOffset);
}
