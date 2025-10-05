part of 'quran_bloc.dart';

abstract class QuranState {}

class QuranInitial extends QuranState {}

class QuranLoading extends QuranState {}

class QuranLoaded extends QuranState {
  final List<Surah> surahs;
  final List<String> quranLines;
  QuranLoaded({required this.surahs, required this.quranLines});
}

class QuranError extends QuranState {
  final String message;
  QuranError({required this.message});
}
