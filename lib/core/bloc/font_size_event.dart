part of 'font_size_bloc.dart';

abstract class FontSizeEvent {}

class LoadFontSize extends FontSizeEvent {}

class IncreaseFontSize extends FontSizeEvent {
  final double step;
  IncreaseFontSize({this.step = 1.0});
}

class DecreaseFontSize extends FontSizeEvent {
  final double step;
  DecreaseFontSize({this.step = 1.0});
}
