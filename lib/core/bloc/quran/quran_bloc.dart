import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_quran/core/data/model/quran_verse.dart';
import '../../data/model/surah.dart';

import '../../data/provider/quran_text_provider.dart';

import '../../data/provider/surah_list_provider.dart';

part 'quran_event.dart';
part 'quran_state.dart';

class QuranBloc extends Bloc<QuranEvent, QuranState> {
  List<QuranVerse> _quranVerses = [];
  List<Surah> _surahs = [];

  QuranBloc() : super(QuranInitial()) {
    on<InitQuran>((event, emit) async {
      emit(QuranLoading());
      try {
        final quranText = await QuranTextProvider.loadQuranText();
        _quranVerses = quranText.map(QuranVerse.fromLine).toList();
        _surahs = await SurahListProvider.loadSurahs();
        // Provide all verses as lines, let FilteredQuranBloc handle filtering/selection efficiently
        emit(
          QuranLoaded(
            // first aya of quran is bismillah from Al-Fatiha
            // we set verseNumber to 0 since it will be used in rendering
            bismillah: _quranVerses[0].copyWith(verseNumber: 0),
            surahs: _surahs,
            quranVerses: _quranVerses,
          ),
        );
      } catch (e) {
        emit(QuranError(error: e));
      }
    });
  }
}
