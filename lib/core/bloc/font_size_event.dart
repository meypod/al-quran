part of 'font_size_bloc.dart';

abstract class FontSizeEvent {}

class LoadFontSize extends FontSizeEvent {}

class IncreaseFontSize extends FontSizeEvent {}

class DecreaseFontSize extends FontSizeEvent {}
