part of 'surah_list_bloc.dart';

abstract class SurahListEvent {}

class SurahListInit extends SurahListEvent {}

class SurahListUpdateSearchTerm extends SurahListEvent {
  final String searchTerm;
  SurahListUpdateSearchTerm(this.searchTerm);
}
