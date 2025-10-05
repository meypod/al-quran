part of 'quran_bloc.dart';

abstract class QuranEvent {}

class InitQuran extends QuranEvent {}

class ChangeSurah extends QuranEvent {
  final int surahId;
  ChangeSurah({required this.surahId});
}

class UpdateSearchTerm extends QuranEvent {
  final String searchTerm;
  UpdateSearchTerm({required this.searchTerm});
}
