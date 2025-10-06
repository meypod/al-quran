import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/quran_preferences.dart';

part 'font_size_event.dart';
part 'font_size_state.dart';

class FontSizeBloc extends Bloc<FontSizeEvent, FontSizeState> {
  static const double _defaultFontSize = 22.0;

  FontSizeBloc() : super(const FontSizeState(fontSize: _defaultFontSize)) {
    on<LoadFontSize>(_onLoadFontSize);
    on<IncreaseFontSize>(_onIncreaseFontSize);
    on<DecreaseFontSize>(_onDecreaseFontSize);
  }

  Future<void> _onLoadFontSize(
    LoadFontSize event,
    Emitter<FontSizeState> emit,
  ) async {
    final fontSize = await QuranPreferences.getFontSize() ?? _defaultFontSize;
    emit(FontSizeState(fontSize: fontSize));
  }

  Future<void> _onIncreaseFontSize(
    IncreaseFontSize event,
    Emitter<FontSizeState> emit,
  ) async {
    final step = event.step;
    final newSize = state.fontSize + step;
    await QuranPreferences.setFontSize(newSize.toDouble());
    emit(FontSizeState(fontSize: newSize.toDouble()));
  }

  Future<void> _onDecreaseFontSize(
    DecreaseFontSize event,
    Emitter<FontSizeState> emit,
  ) async {
    final minFontSize = 13.0;
    final step = event.step;
    final newSize = state.fontSize > minFontSize
        ? (state.fontSize - step).clamp(minFontSize, double.infinity)
        : minFontSize;
    await QuranPreferences.setFontSize(newSize.toDouble());
    emit(FontSizeState(fontSize: newSize.toDouble()));
  }
}
