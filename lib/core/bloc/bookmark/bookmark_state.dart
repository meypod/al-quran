part of 'bookmark_bloc.dart';

class BookmarkState {
  final Set<String> bookmarks;
  const BookmarkState({required this.bookmarks});

  bool isBookmarked(String verseKey) => bookmarks.contains(verseKey);
}
