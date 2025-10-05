part of 'surah_list_bloc.dart';

abstract class SurahListState {}

class SurahListInitial extends SurahListState {}

class SurahListLoaded extends SurahListState {
  final List<Surah> filteredSurahs;
  final String searchTerm;
  SurahListLoaded({required this.filteredSurahs, required this.searchTerm});
}
