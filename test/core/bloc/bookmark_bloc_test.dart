import 'package:al_quran/core/bloc/bookmark/bookmark_bloc.dart';
import 'package:al_quran/core/utils/quran_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('starts empty', () {
    final bloc = BookmarkBloc();
    expect(bloc.state.bookmarks, isEmpty);
  });

  test('LoadBookmarks reads persisted keys', () async {
    SharedPreferences.setMockInitialValues({
      'bookmarks': ['2:255', '1:1'],
    });
    final bloc = BookmarkBloc()..add(LoadBookmarks());
    await bloc.stream.first;
    expect(bloc.state.bookmarks, {'2:255', '1:1'});
  });

  test('ToggleBookmark adds then removes and persists', () async {
    final bloc = BookmarkBloc();

    bloc.add(ToggleBookmark('2:255'));
    await bloc.stream.first;
    expect(bloc.state.isBookmarked('2:255'), isTrue);
    expect(await QuranPreferences.getBookmarks(), ['2:255']);

    bloc.add(ToggleBookmark('2:255'));
    await bloc.stream.first;
    expect(bloc.state.isBookmarked('2:255'), isFalse);
    expect(await QuranPreferences.getBookmarks(), isEmpty);
  });

  test('ClearBookmarks empties state and storage', () async {
    SharedPreferences.setMockInitialValues({
      'bookmarks': ['1:1', '2:255'],
    });
    final bloc = BookmarkBloc()..add(LoadBookmarks());
    await bloc.stream.first;

    bloc.add(ClearBookmarks());
    await bloc.stream.first;
    expect(bloc.state.bookmarks, isEmpty);
    expect(await QuranPreferences.getBookmarks(), isEmpty);
  });

  test('preserves insertion order across toggles', () async {
    final bloc = BookmarkBloc();
    for (final key in ['1:1', '2:255', '3:7']) {
      bloc.add(ToggleBookmark(key));
      await bloc.stream.first;
    }
    expect(bloc.state.bookmarks.toList(), ['1:1', '2:255', '3:7']);
  });
}
