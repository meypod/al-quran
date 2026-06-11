import 'quran_bloc.dart';

class FilteredQuranLoadingEvent extends FilteredQuranEvent {}

class FilteredQuranErrorEvent extends FilteredQuranEvent {
  final String message;
  FilteredQuranErrorEvent(this.message);
}

class FilteredQuranInitialEvent extends FilteredQuranEvent {}

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
  final bool searchAllQuran;
  FilteredQuranUpdateSearchTerm(this.searchTerm, this.searchAllQuran);
}

class FilteredQuranUpdateScrollIndex extends FilteredQuranEvent {
  final int scrollIndex;
  final double scrollAlignment;
  FilteredQuranUpdateScrollIndex(this.scrollIndex, this.scrollAlignment);
}

/// Switches to [surahId], clears search, and positions the list at the verse.
class FilteredQuranJumpToVerse extends FilteredQuranEvent {
  final int surahId;
  final int verseNumber;
  FilteredQuranJumpToVerse(this.surahId, this.verseNumber);
}
