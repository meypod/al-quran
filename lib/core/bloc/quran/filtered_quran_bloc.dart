import 'package:diacritic/diacritic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/quran_verse.dart';
import '../../data/model/surah.dart';
import '../../utils/quran_preferences.dart';
import 'quran_bloc.dart';

part 'filtered_quran_event.dart';
part 'filtered_quran_state.dart';

class FilteredQuranBloc extends Bloc<FilteredQuranEvent, FilteredQuranState> {
  final QuranBloc quranBloc;
  late final Stream<QuranState> _quranStream;

  int _selectedSurahId = 1;
  double _scrollOffset = 0.0;
  String _searchTerm = '';

  FilteredQuranBloc({required this.quranBloc}) : super(FilteredQuranInitial()) {
    _quranStream = quranBloc.stream;

    // Listen to QuranBloc for loaded data
    _quranStream.listen((quranState) {
      if (quranState is QuranLoaded) {
        add(FilteredQuranInit(quranState));
      }
    });

    on<FilteredQuranInit>((event, emit) async {
      _selectedSurahId =
          await QuranPreferences.getSelectedSurah() ?? _selectedSurahId;
      _scrollOffset =
          await QuranPreferences.getScrollPosition() ?? _scrollOffset;
      emit(_buildLoaded(event.quranState));
    });

    on<FilteredQuranChangeSurah>((event, emit) async {
      _selectedSurahId = event.surahId;
      await QuranPreferences.setSelectedSurah(_selectedSurahId);
      _scrollOffset = 0.0;
      await QuranPreferences.setScrollPosition(_scrollOffset);
      final quranState = _getQuranLoaded();
      if (quranState != null) {
        emit(_buildLoaded(quranState));
      }
    });

    on<FilteredQuranUpdateSearchTerm>((event, emit) async {
      _searchTerm = event.searchTerm;
      final quranState = _getQuranLoaded();
      if (quranState != null) {
        emit(_buildLoaded(quranState));
      }
    });

    on<FilteredQuranUpdateScrollOffset>((event, emit) async {
      _scrollOffset = event.scrollOffset;
      await QuranPreferences.setScrollPosition(_scrollOffset);
      final quranState = _getQuranLoaded();
      if (quranState != null) {
        emit(_buildLoaded(quranState));
      }
    });
  }

  QuranLoaded? _getQuranLoaded() {
    final state = quranBloc.state;
    return state is QuranLoaded ? state : null;
  }

  FilteredQuranLoaded _buildLoaded(QuranLoaded quranState) {
    final selectedSurah = quranState.surahs.firstWhere(
      (s) => s.id == _selectedSurahId,
      orElse: () => quranState.surahs.first,
    );
    final filtered = _filterVerses(quranState, selectedSurah.id, _searchTerm);
    return FilteredQuranLoaded(
      selectedSurah: selectedSurah,
      filteredVerses: filtered,
      scrollOffset: _scrollOffset,
      searchTerm: _searchTerm,
    );
  }

  List<QuranVerse> _filterVerses(
    QuranLoaded quranState,
    int surahId,
    String searchTerm,
  ) {
    var filtered = quranState.quranVerses.where((v) => v.surahId == surahId);
    if (searchTerm.isNotEmpty) {
      final cleanedTerm = removeDiacritics(searchTerm);
      final cleanFiltered = quranState.quranCleanVerses.where(
        (v) => v.surahId == surahId,
      );
      final matchingVerseNumbers = cleanFiltered
          .where((v) => v.verseText.contains(cleanedTerm))
          .map((v) => v.verseNumber)
          .toSet();
      filtered = filtered.where(
        (v) => matchingVerseNumbers.contains(v.verseNumber),
      );
    }
    return filtered.toList();
  }
}
