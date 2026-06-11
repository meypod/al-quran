part of 'bookmark_bloc.dart';

abstract class BookmarkEvent {}

class LoadBookmarks extends BookmarkEvent {}

class ToggleBookmark extends BookmarkEvent {
  final String verseKey;
  ToggleBookmark(this.verseKey);
}

class ClearBookmarks extends BookmarkEvent {}
