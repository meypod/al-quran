import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/surah.dart';

import '../../data/provider/quran_text_provider.dart';

import '../../data/provider/surah_list_provider.dart';

part 'quran_event.dart';
part 'quran_state.dart';

class QuranBloc extends Bloc<QuranEvent, QuranState> {
  List<String> _quranLines = [];
  List<Surah> _surahs = [];

  QuranBloc() : super(QuranInitial()) {
    on<InitQuran>((event, emit) async {
      emit(QuranLoading());
      try {
        _quranLines = await QuranTextProvider.loadQuranText();
        _surahs = await SurahListProvider.loadSurahs();
        // Provide all verses as lines, let FilteredQuranBloc handle filtering/selection efficiently
        emit(QuranLoaded(surahs: _surahs, quranLines: _quranLines));
      } catch (e) {
        emit(QuranError(message: e.toString()));
      }
    });
  }
}
