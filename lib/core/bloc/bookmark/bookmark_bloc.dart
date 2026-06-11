import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/quran_preferences.dart';

part 'bookmark_event.dart';
part 'bookmark_state.dart';

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  BookmarkBloc() : super(const BookmarkState(bookmarks: {})) {
    on<LoadBookmarks>(_onLoadBookmarks);
    on<ToggleBookmark>(_onToggleBookmark);
    on<ClearBookmarks>(_onClearBookmarks);
  }

  Future<void> _onLoadBookmarks(
    LoadBookmarks event,
    Emitter<BookmarkState> emit,
  ) async {
    final keys = await QuranPreferences.getBookmarks() ?? const [];
    emit(BookmarkState(bookmarks: keys.toSet()));
  }

  Future<void> _onToggleBookmark(
    ToggleBookmark event,
    Emitter<BookmarkState> emit,
  ) async {
    // Preserve insertion order so the bookmarks list stays stable.
    final next = state.bookmarks.toSet();
    if (!next.remove(event.verseKey)) {
      next.add(event.verseKey);
    }
    await QuranPreferences.setBookmarks(next.toList());
    emit(BookmarkState(bookmarks: next));
  }

  Future<void> _onClearBookmarks(
    ClearBookmarks event,
    Emitter<BookmarkState> emit,
  ) async {
    await QuranPreferences.setBookmarks(const []);
    emit(const BookmarkState(bookmarks: {}));
  }
}
