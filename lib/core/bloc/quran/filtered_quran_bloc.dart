import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/quran_verse.dart';
import '../../data/model/surah.dart';
import '../../utils/quran_preferences.dart';
import '../../utils/text.dart';
import 'dart:collection';
import 'filtered_quran_event.dart';
import 'filtered_quran_state.dart';
import 'quran_bloc.dart';

class FilteredQuranBloc extends Bloc<FilteredQuranEvent, FilteredQuranState> {
  final QuranBloc quranBloc;
  late final Stream<QuranState> _quranStream;

  int _selectedSurahId = 1;
  double _scrollOffset = 0.0;
  String _searchTerm = '';
  bool _searchAllQuran = false;

  FilteredQuranBloc({required this.quranBloc}) : super(FilteredQuranInitial()) {
    _quranStream = quranBloc.stream;

    // Listen to QuranBloc for all state changes
    _quranStream.listen((quranState) {
      switch (quranState) {
        case QuranLoaded():
          add(FilteredQuranInit(quranState));
        case QuranLoading():
          add(FilteredQuranLoadingEvent());
        case QuranError(error: var error):
          add(FilteredQuranErrorEvent(error.toString()));
        case QuranInitial():
          add(FilteredQuranInitialEvent());
      }
    });
    on<FilteredQuranLoadingEvent>((event, emit) async {
      emit(FilteredQuranLoading());
    });

    on<FilteredQuranErrorEvent>((event, emit) async {
      emit(FilteredQuranError(message: event.message));
    });

    on<FilteredQuranInitialEvent>((event, emit) async {
      emit(FilteredQuranInitial());
    });

    on<FilteredQuranInit>((event, emit) async {
      final prefs = await Future.wait([
        QuranPreferences.getSelectedSurah(),
        QuranPreferences.getScrollPosition(),
        QuranPreferences.getSearchTerm(),
        QuranPreferences.getSearchAllQuran(),
      ]);
      var savedSurahId = prefs[0] as int? ?? _selectedSurahId;
      if (savedSurahId == 0) savedSurahId = 1;
      _selectedSurahId = savedSurahId;
      _scrollOffset = (prefs[1] as double?) ?? _scrollOffset;
      _searchTerm = (prefs[2] as String?) ?? _searchTerm;
      _searchAllQuran = (prefs[3] as bool?) ?? _searchAllQuran;
      emit(_buildLoaded(event.quranState));
    });

    on<FilteredQuranChangeSurah>((event, emit) async {
      _selectedSurahId = event.surahId;
      _scrollOffset = 0.0;
      await Future.wait([
        QuranPreferences.setSelectedSurah(_selectedSurahId),
        QuranPreferences.setScrollPosition(_scrollOffset),
      ]);
      final quranState = _getQuranLoaded();
      if (quranState != null) {
        emit(_buildLoaded(quranState));
      }
    });

    on<FilteredQuranUpdateSearchTerm>((event, emit) async {
      _searchTerm = event.searchTerm;
      _searchAllQuran = event.searchAllQuran;
      await Future.wait([
        QuranPreferences.setSearchTerm(_searchTerm),
        QuranPreferences.setSearchAllQuran(_searchAllQuran),
      ]);
      final quranState = _getQuranLoaded();
      if (quranState != null) {
        emit(_buildLoaded(quranState));
      }
    });

    on<FilteredQuranUpdateScrollOffset>((event, emit) async {
      _scrollOffset = event.scrollOffset;
      await QuranPreferences.setScrollPosition(_scrollOffset);
    });
  }

  QuranLoaded? _getQuranLoaded() {
    final state = quranBloc.state;
    return state is QuranLoaded ? state : null;
  }

  FilteredQuranLoaded _buildLoaded(QuranLoaded quranState) {
    final selectedSurah =
        quranState.surahs.elementAtOrNull(_selectedSurahId - 1) ??
        quranState.surahs[0];
    final isFullSearch = _searchTerm.isNotEmpty && _searchAllQuran;
    final (filtered, highlightMap) = _filterVerses(
      quranState,
      isFullSearch ? null : selectedSurah,
      _searchTerm,
    );
    if (!_searchTerm.isNotEmpty && selectedSurah.hasBismillah == true) {
      filtered.insert(0, quranState.bismillah);
    }

    return FilteredQuranLoaded(
      selectedSurah: selectedSurah,
      filteredVerses: filtered,
      scrollOffset: _scrollOffset,
      searchTerm: _searchTerm,
      searchAllQuran: _searchAllQuran,
      highlightMap: highlightMap,
    );
  }

  (List<QuranVerse>, Map<String, List<(int, int)>>) _filterVerses(
    QuranLoaded quranState,
    Surah? selectedSurah,
    String searchTerm,
  ) {
    var filtered = quranState.quranVerses.where(
      (v) => selectedSurah == null || v.surahId == selectedSurah.id,
    );

    if (searchTerm.isNotEmpty) {
      final regexTerm = regexifySearchTerm(searchTerm);
      final List<QuranVerse> result = [];
      // Build highlight map: key = 'surahId:verseNumber', value = List<(int, int)>
      final Map<String, List<(int, int)>> highlightMap = {};
      for (final verse in filtered) {
        final ranges = <(int, int)>[];
        final text = verse.verseText; // Use the original text for highlighting
        final matches = regexTerm.allMatches(text);
        for (final match in matches) {
          ranges.add((match.start, match.end));
        }
        if (ranges.isNotEmpty) {
          highlightMap[verse.key] = ranges;
          result.add(verse);
        }
      }
      return (result, highlightMap);
    }
    return (filtered.toList(), {});
  }
}
