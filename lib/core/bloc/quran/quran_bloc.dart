import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/quran_verse.dart';
import '../../data/model/surah.dart';

import '../../data/provider/quran_text_provider.dart';

import '../../data/provider/surah_list_provider.dart';
import '../../utils/quran_preferences.dart';

part 'quran_event.dart';
part 'quran_state.dart';

class QuranBloc extends Bloc<QuranEvent, QuranState> {
  List<String> _quranLines = [];
  List<Surah> _surahs = [];
  int _selectedSurahId = 1;
  double _scrollOffset = 0.0;
  String _searchTerm = '';

  QuranBloc() : super(QuranInitial()) {
    on<InitQuran>((event, emit) async {
      emit(QuranLoading());
      try {
        _quranLines = await QuranTextProvider.loadQuranText();
        _surahs = await SurahListProvider.loadSurahs();
        _selectedSurahId = await QuranPreferences.getSelectedSurah() ?? 1;
        _scrollOffset = await QuranPreferences.getScrollPosition() ?? 0.0;
        _searchTerm = '';
        final selectedSurah = _surahs.firstWhere(
          (s) => s.id == _selectedSurahId,
          orElse: () => _surahs.first,
        );
        final filtered = _filterLines(
          selectedSurah.id,
          _searchTerm,
        ).map((line) => QuranVerse.fromLine(line)).toList();
        emit(
          QuranLoaded(
            surahs: _surahs,
            selectedSurah: selectedSurah,
            filteredVerses: filtered,
            scrollOffset: _scrollOffset,
            searchTerm: _searchTerm,
          ),
        );
      } catch (e) {
        emit(QuranError(message: e.toString()));
      }
    });

    on<ChangeSurah>((event, emit) async {
      emit(QuranLoading());
      try {
        _selectedSurahId = event.surahId;
        await QuranPreferences.setSelectedSurah(_selectedSurahId);
        await QuranPreferences.setScrollPosition(0.0);
        _scrollOffset = 0.0;
        final selectedSurah = _surahs.firstWhere(
          (s) => s.id == _selectedSurahId,
          orElse: () => _surahs.first,
        );
        final filtered = _filterLines(
          selectedSurah.id,
          _searchTerm,
        ).map((line) => QuranVerse.fromLine(line)).toList();
        emit(
          QuranLoaded(
            surahs: _surahs,
            selectedSurah: selectedSurah,
            filteredVerses: filtered,
            scrollOffset: _scrollOffset,
            searchTerm: _searchTerm,
          ),
        );
      } catch (e) {
        emit(QuranError(message: e.toString()));
      }
    });

    on<UpdateSearchTerm>((event, emit) async {
      emit(QuranLoading());
      try {
        _searchTerm = event.searchTerm;
        final selectedSurah = _surahs.firstWhere(
          (s) => s.id == _selectedSurahId,
          orElse: () => _surahs.first,
        );
        final filtered = _filterLines(
          selectedSurah.id,
          _searchTerm,
        ).map((line) => QuranVerse.fromLine(line)).toList();
        emit(
          QuranLoaded(
            surahs: _surahs,
            selectedSurah: selectedSurah,
            filteredVerses: filtered,
            scrollOffset: _scrollOffset,
            searchTerm: _searchTerm,
          ),
        );
      } catch (e) {
        emit(QuranError(message: e.toString()));
      }
    });
  }

  List<String> _filterLines(int surahId, String searchTerm) {
    final surahLines = _quranLines.where(
      (line) => line.startsWith('$surahId|'),
    );
    if (searchTerm.isEmpty) {
      return surahLines.toList();
    }
    return surahLines.where((line) => line.contains(searchTerm)).toList();
  }
}
