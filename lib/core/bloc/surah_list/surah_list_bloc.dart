import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_quran/core/utils/arabic_number_util.dart';
import '../../data/model/surah.dart';
import '../../utils/text.dart';

part 'surah_list_event.dart';
part 'surah_list_state.dart';

class SurahListBloc extends Bloc<SurahListEvent, SurahListState> {
  final List<Surah> allSurahs;
  final List<String> _simplifiedNames;
  String _searchTerm = '';

  SurahListBloc({required this.allSurahs})
    : _simplifiedNames = allSurahs
          .map(
            (s) =>
                "${toEnglishDigits(s.id.toString())} ${simplifyText(s.name)}",
          )
          .toList(),
      super(SurahListInitial()) {
    on<SurahListInit>((event, emit) {
      emit(SurahListLoaded(filteredSurahs: allSurahs, searchTerm: _searchTerm));
    });

    on<SurahListUpdateSearchTerm>((event, emit) {
      _searchTerm = event.searchTerm;
      final filtered = _filterSurahs(_searchTerm);
      emit(SurahListLoaded(filteredSurahs: filtered, searchTerm: _searchTerm));
    });
  }

  List<Surah> _filterSurahs(String searchTerm) {
    if (searchTerm.isEmpty) return allSurahs;
    final cleanedTerm = toEnglishDigits(simplifyText(searchTerm));
    final List<Surah> result = [];
    for (int i = 0; i < allSurahs.length; i++) {
      if (_simplifiedNames[i].contains(cleanedTerm)) {
        result.add(allSurahs[i]);
      }
    }
    return result;
  }
}
