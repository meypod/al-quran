import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'font_size_event.dart';
part 'font_size_state.dart';

class FontSizeBloc extends Bloc<FontSizeEvent, FontSizeState> {
  static const String _fontSizeKey = 'font_size';
  static const double _defaultFontSize = 16.0;

  FontSizeBloc() : super(const FontSizeState(fontSize: _defaultFontSize)) {
    on<LoadFontSize>(_onLoadFontSize);
    on<IncreaseFontSize>(_onIncreaseFontSize);
    on<DecreaseFontSize>(_onDecreaseFontSize);
  }

  Future<void> _onLoadFontSize(
    LoadFontSize event,
    Emitter<FontSizeState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final fontSize = prefs.getDouble(_fontSizeKey) ?? _defaultFontSize;
    emit(FontSizeState(fontSize: fontSize));
  }

  Future<void> _onIncreaseFontSize(
    IncreaseFontSize event,
    Emitter<FontSizeState> emit,
  ) async {
    final newSize = state.fontSize + 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, newSize.toDouble());
    emit(FontSizeState(fontSize: newSize.toDouble()));
  }

  Future<void> _onDecreaseFontSize(
    DecreaseFontSize event,
    Emitter<FontSizeState> emit,
  ) async {
    final newSize = state.fontSize > 1 ? state.fontSize - 1 : 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, newSize.toDouble());
    emit(FontSizeState(fontSize: newSize.toDouble()));
  }
}
