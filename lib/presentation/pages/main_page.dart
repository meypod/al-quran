import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../core/bloc/bookmark/bookmark_bloc.dart';
import '../../core/bloc/font_size/font_size_bloc.dart';
import '../../core/bloc/quran/filtered_quran_event.dart';
import '../../core/bloc/quran/filtered_quran_state.dart';
import '../../core/bloc/quran/filtered_quran_bloc.dart';
import '../../core/utils/text.dart';
import '../../core/utils/arabic_number_util.dart';
import '../../locator.dart';
import '../../core/data/model/surah.dart';
import '../../core/data/model/quran_verse.dart';
import '../../core/utils/quran_preferences.dart';
import '../widgets/verse_widget.dart';
import '../widgets/font_adjuster.dart';
import '../widgets/expandable_section.dart';

import 'package:go_router/go_router.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  DateTime? _lastBackPressed;
  void _clearSearch(BuildContext context) {
    setState(() {
      _searchController.clear();
    });
    _submitSearch(context);
  }

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  Timer? _saveScrollDebounce;

  @override
  void initState() {
    super.initState();
    // ScrollablePositionedList doesn't reliably bubble ScrollEndNotification,
    // so persist the resting position by watching item positions instead.
    _itemPositionsListener.itemPositions.addListener(_onPositionsChanged);
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_onPositionsChanged);
    _saveScrollDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _selectionAreaFocusNode.dispose();
    super.dispose();
  }

  void _onPositionsChanged() {
    // Debounce: only persist once scrolling has settled.
    _saveScrollDebounce?.cancel();
    _saveScrollDebounce = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      final (index, alignment) = _topPosition();
      getIt<FilteredQuranBloc>().add(
        FilteredQuranUpdateScrollIndex(index, alignment),
      );
    });
  }

  /// A scroll anchor as (index, alignment): the first visible verse whose
  /// leading edge sits within the viewport. Its alignment is the leading edge
  /// as a fraction of the viewport in [0, 1] — exactly what [jumpTo] expects —
  /// and it encodes the partial scroll of the verse above it, so restoring it
  /// reproduces the exact mid-verse offset. Defaults to (0, 0).
  (int, double) _topPosition() {
    final positions = _itemPositionsListener.itemPositions.value;
    final visible = positions.where(
      (p) => p.itemTrailingEdge > 0 && p.itemLeadingEdge < 1,
    );
    if (visible.isEmpty) return (0, 0.0);
    // Prefer the top-most item that starts at/below the viewport top; its
    // leading edge is in [0, 1), a valid alignment.
    final anchored = visible.where((p) => p.itemLeadingEdge >= 0);
    if (anchored.isNotEmpty) {
      final a = anchored.reduce(
        (x, y) => x.itemLeadingEdge <= y.itemLeadingEdge ? x : y,
      );
      return (a.index, a.itemLeadingEdge);
    }
    // Fallback: a single verse taller than the viewport covers the top. Its
    // leading edge is negative (not a valid alignment), so pin it to the top;
    // the within-verse offset can't be expressed without a pixel API.
    final top = visible.reduce(
      (x, y) => x.itemLeadingEdge <= y.itemLeadingEdge ? x : y,
    );
    return (top.index, 0.0);
  }

  bool _showFontDrawer = false;
  bool _showSearchDrawer = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _searchAllQuran = false;

  bool _selectionMode = false;
  final Set<String> _selectedKeys = {};

  // Drives the verse-list [SelectionArea]. Dropping its focus clears any
  // active native text selection.
  final FocusNode _selectionAreaFocusNode = FocusNode();

  /// Clears any active native text selection in the verse list.
  void _clearTextSelection() => _selectionAreaFocusNode.unfocus();

  void _enterSelectionMode() {
    _clearTextSelection();
    setState(() => _selectionMode = true);
  }

  void _exitSelectionMode() {
    _clearTextSelection();
    setState(() {
      _selectionMode = false;
      _selectedKeys.clear();
    });
  }

  void _toggleVerseSelection(String key) {
    _clearTextSelection();
    setState(() {
      if (!_selectedKeys.remove(key)) _selectedKeys.add(key);
    });
  }

  void _copySelectedVerses(List<QuranVerse> verses) {
    final selected = verses
        .where((v) => _selectedKeys.contains(v.key))
        .toList();
    final text = selected
        .map((v) => VerseWidget.copyText(v, VerseWidget.surahNameFor(v)))
        .join();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم نسخ ${versesCountPhrase(selected.length)}',
          textDirection: TextDirection.rtl,
        ),
        duration: const Duration(seconds: 1),
      ),
    );
    _exitSelectionMode();
  }

  void _toggleFontDrawer() {
    setState(() {
      if (!_showFontDrawer) {
        _showSearchDrawer = false;
      }
      _showFontDrawer = !_showFontDrawer;
    });
  }

  void _toggleSearchDrawer() {
    setState(() {
      if (!_showSearchDrawer) {
        _showFontDrawer = false;
      }
      _showSearchDrawer = !_showSearchDrawer;
      if (!_showSearchDrawer) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  void _submitSearch([BuildContext? _]) {
    getIt<FilteredQuranBloc>().add(
      FilteredQuranUpdateSearchTerm(
        _searchController.text.trim(),
        _searchAllQuran,
      ),
    );
  }

  /// Opens the search drawer and moves keyboard focus into the field so the
  /// user can type immediately (bound to `/` and Ctrl+F).
  void _focusSearch() {
    setState(() {
      _showSearchDrawer = true;
      _showFontDrawer = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  /// Escape unwinds the most specific active mode first, mirroring the back
  /// button: selection mode, then an open/non-empty search, then any focus.
  void _handleEscape() {
    if (_selectionMode) {
      _exitSelectionMode();
      return;
    }
    if (_showSearchDrawer || _searchController.text.isNotEmpty) {
      setState(() {
        _showSearchDrawer = false;
        _searchController.clear();
      });
      _submitSearch();
      return;
    }
    _clearTextSelection();
    if (mounted) FocusScope.of(context).unfocus();
  }

  /// Number of verses fully visible in the viewport; used for page scrolling.
  int _visibleVerseCount() {
    final positions = _itemPositionsListener.itemPositions.value;
    final fully = positions.where(
      (p) => p.itemLeadingEdge >= 0 && p.itemTrailingEdge <= 1,
    );
    return fully.isNotEmpty ? fully.length : 1;
  }

  void _scrollToIndex(int index, {double alignment = 0.0}) {
    if (!_itemScrollController.isAttached) return;
    _itemScrollController.scrollTo(
      index: index,
      alignment: alignment,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _scrollByVerses(int delta) {
    final state = getIt<FilteredQuranBloc>().state;
    if (state is! FilteredQuranLoaded) return;
    final count = state.filteredVerses.length;
    if (count == 0) return;
    final (index, _) = _topPosition();
    _scrollToIndex((index + delta).clamp(0, count - 1));
  }

  void _scrollToEdge({required bool end}) {
    final state = getIt<FilteredQuranBloc>().state;
    if (state is! FilteredQuranLoaded) return;
    final count = state.filteredVerses.length;
    if (count == 0) return;
    _scrollToIndex(end ? count - 1 : 0);
  }

  /// Clears the search term, collapses the search drawer and drops focus.
  /// Called before navigating to the surah list or bookmarks screen.
  void _closeSearch(BuildContext context) {
    FocusScope.of(context).unfocus();
    _searchController.clear();
    setState(() => _showSearchDrawer = false);
    context.read<FilteredQuranBloc>().add(
      FilteredQuranUpdateSearchTerm('', _searchAllQuran),
    );
  }

  Future<void> _openSurahList(BuildContext context) async {
    _closeSearch(context);
    final selected = await context.push<Surah>('/surahs');
    if (selected is Surah && context.mounted) {
      context.read<FilteredQuranBloc>().add(
        FilteredQuranChangeSurah(selected.id),
      );
    }
  }

  Future<void> _openBookmarks(BuildContext context) async {
    _closeSearch(context);
    final selected = await context.push<QuranVerse>('/bookmarks');
    if (selected is QuranVerse && context.mounted) {
      context.read<FilteredQuranBloc>().add(
        FilteredQuranJumpToVerse(selected.surahId, selected.verseNumber),
      );
    }
  }

  /// Builds the top bar. The title is centered between the leading icons and
  /// the action icons; with a long surah name and several actions present it
  /// gets squeezed and ellipsized. When the measured title can't fit the
  /// available centered width, drop it from the first row and render it full
  /// width in a second row ([AppBar.bottom]) instead.
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    FilteredQuranLoaded state,
    String surahName,
    double toolbarHeight,
  ) {
    const double kBtn = 48.0; // kMinInteractiveDimension
    const double kPad = 16.0; // horizontal padding around a padded action
    const double kLeading = 100.0; // leadingWidth

    final titleText = _selectionMode
        ? 'تم تحديد ${toArabicNumber(_selectedKeys.length)}'
        : surahName;

    // Estimate the trailing actions width to know how much centered space the
    // title actually has (a centered title stays centered only within
    // width - 2 * max(left, right)).
    double right;
    if (_selectionMode) {
      right = kBtn /* copy */ + kBtn + kPad /* close, padded */;
    } else {
      right = kBtn /* bookmarks */;
      if (state.searchTerm.isNotEmpty && state.filteredVerses.isNotEmpty) {
        right += kBtn; // checklist
      }
      if (_searchController.text.isNotEmpty) right += kBtn; // clear
      right += kBtn + kPad; // search, padded
    }

    final titleStyle =
        Theme.of(context).appBarTheme.titleTextStyle ??
        Theme.of(context).textTheme.titleLarge;
    final tp = TextPainter(
      text: TextSpan(text: titleText, style: titleStyle),
      textDirection: TextDirection.rtl,
      maxLines: 1,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();

    final double width = MediaQuery.sizeOf(context).width;
    final double available =
        width - 2 * (kLeading > right ? kLeading : right) - kPad;
    final bool overflow = tp.width > available;

    return AppBar(
      toolbarHeight: toolbarHeight.clamp(56.0, 120.0),
      title: overflow ? null : Text(titleText, textAlign: TextAlign.center),
      centerTitle: true,
      leadingWidth: kLeading,
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.menu_book),
              tooltip: 'سور القرآن',
              onPressed: () => _openSurahList(context),
            ),
            IconButton(
              icon: const Icon(Icons.format_size),
              tooltip: 'تغيير حجم الخط',
              onPressed: _toggleFontDrawer,
            ),
          ],
        ),
      ),
      actions: _selectionMode
          ? [
              IconButton(
                icon: const Icon(Icons.copy),
                tooltip: 'نسخ المحدد',
                onPressed: _selectedKeys.isEmpty
                    ? null
                    : () => _copySelectedVerses(state.filteredVerses),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'إلغاء',
                  onPressed: _exitSelectionMode,
                ),
              ),
            ]
          : [
              IconButton(
                icon: const Icon(Icons.bookmarks_outlined),
                tooltip: 'العلامات',
                onPressed: () => _openBookmarks(context),
              ),
              if (state.searchTerm.isNotEmpty &&
                  state.filteredVerses.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.checklist),
                  tooltip: 'تحديد الآيات',
                  onPressed: _enterSelectionMode,
                ),
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'مسح البحث',
                  onPressed: () => _clearSearch(context),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'بحث',
                  onPressed: _toggleSearchDrawer,
                ),
              ),
            ],
      bottom: overflow
          ? PreferredSize(
              preferredSize: Size.fromHeight(tp.height + 16.0),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 8.0,
                ),
                child: Text(
                  titleText,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle,
                ),
              ),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredQuranBloc = getIt<FilteredQuranBloc>();
    return MultiBlocProvider(
      providers: [
        BlocProvider<FilteredQuranBloc>.value(value: filteredQuranBloc),
        BlocProvider<BookmarkBloc>.value(value: getIt<BookmarkBloc>()),
      ],
      child: BlocConsumer<FilteredQuranBloc, FilteredQuranState>(
        listenWhen: (previous, current) =>
            current is FilteredQuranLoaded && previous != current,
        listener: (context, state) {
          if (state is FilteredQuranLoaded) {
            if (_searchController.text != state.searchTerm) {
              _searchController.text = state.searchTerm;
            }
            if (_searchAllQuran != state.searchAllQuran) {
              setState(() {
                _searchAllQuran = state.searchAllQuran;
              });
            }
            if (state.searchTerm.isNotEmpty && !_showSearchDrawer) {
              setState(() {
                _showSearchDrawer = true;
                _showFontDrawer = false;
              });
            }
          }
        },
        builder: (context, state) {
          Widget scaffoldContent;
          if (state is FilteredQuranInitial || state is FilteredQuranLoading) {
            scaffoldContent = const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is FilteredQuranError) {
            scaffoldContent = Scaffold(
              body: Center(
                child: Text('حدث خطأ أثناء تحميل القرآن: ${state.message}'),
              ),
            );
          } else if (state is FilteredQuranLoaded) {
            final selectedSurah = state.selectedSurah;
            final String surahName = state.searchTerm.isEmpty
                ? selectedSurah?.name ?? ""
                : "بحث";
            final double fontSize = context.select<FontSizeBloc, double>(
              (bloc) => bloc.state.fontSize,
            );
            final double toolbarHeight = 56.0 + (fontSize - 22.0) * 1.2;

            scaffoldContent = Scaffold(
              appBar: _buildAppBar(context, state, surahName, toolbarHeight),
              body: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  ExpandableSection(
                    expanded: _showFontDrawer,
                    animationDuration: const Duration(milliseconds: 250),
                    child: Container(
                      color: Theme.of(context).canvasColor,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const FontAdjuster(),
                    ),
                  ),
                  ExpandableSection(
                    expanded: _showSearchDrawer,
                    animationDuration: const Duration(milliseconds: 250),
                    child: Container(
                      color: Theme.of(context).canvasColor,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    focusNode: _searchFocusNode,
                                    decoration: InputDecoration(
                                      labelText: 'بحث',
                                      border: const OutlineInputBorder(),
                                      helperText: state.searchTerm.isNotEmpty
                                          ? arabicResultLabel(
                                              state.filteredVerses.length,
                                            )
                                          : null,
                                      suffixIcon:
                                          _searchController.text.isNotEmpty
                                          ? Padding(
                                              padding:
                                                  const EdgeInsetsDirectional.only(
                                                    end: 12.0,
                                                  ),
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.clear,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.error,
                                                ),
                                                tooltip: 'مسح البحث',
                                                onPressed: () =>
                                                    _clearSearch(context),
                                              ),
                                            )
                                          : null,
                                    ),
                                    onSubmitted: (_) => _submitSearch(context),
                                    style: const TextStyle(
                                      fontFamily: 'nonexisting',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _searchAllQuran = !_searchAllQuran;
                                  });
                                  QuranPreferences.setSearchAllQuran(
                                    _searchAllQuran,
                                  );
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: _searchAllQuran,
                                      onChanged: (val) {
                                        setState(() {
                                          _searchAllQuran = val ?? false;
                                        });
                                        QuranPreferences.setSearchAllQuran(
                                          val ?? false,
                                        );
                                      },
                                    ),
                                    const Text(
                                      'بحث في كل القرآن',
                                      textDirection: TextDirection.rtl,
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => _submitSearch(context),
                                child: const Text('بحث'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child:
                        state.filteredVerses.isEmpty &&
                            state.searchTerm.isNotEmpty
                        ? const Center(child: Text('لا توجد نتائج'))
                        : SelectionArea(
                            focusNode: _selectionAreaFocusNode,
                            child: BlocBuilder<BookmarkBloc, BookmarkState>(
                              builder: (context, bookmarkState) {
                                return ScrollablePositionedList.separated(
                                  // Keyed by position so a same-surah jump
                                  // recreates the list at the target verse;
                                  // stable during scrolling (no state emit).
                                  key: PageStorageKey(
                                    "surah-scroll-${state.selectedSurah?.id ?? 0}-${state.scrollIndex}",
                                  ),
                                  itemScrollController: _itemScrollController,
                                  itemPositionsListener: _itemPositionsListener,
                                  initialScrollIndex: state.scrollIndex.clamp(
                                    0,
                                    state.filteredVerses.isEmpty
                                        ? 0
                                        : state.filteredVerses.length - 1,
                                  ),
                                  initialAlignment: state.scrollAlignment,
                                  itemCount: state.filteredVerses.length,
                                  itemBuilder: (context, index) {
                                    final verse = state.filteredVerses[index];
                                    return VerseWidget(
                                      verse: verse,
                                      isSearchResult:
                                          state.searchTerm.isNotEmpty,
                                      highlights:
                                          state.highlightMap[verse.key] ?? [],
                                      selectionMode: _selectionMode,
                                      selected: _selectedKeys.contains(
                                        verse.key,
                                      ),
                                      onSelectToggle: () =>
                                          _toggleVerseSelection(verse.key),
                                      isBookmarked: bookmarkState.isBookmarked(
                                        verse.key,
                                      ),
                                      onBookmarkToggle: () => context
                                          .read<BookmarkBloc>()
                                          .add(ToggleBookmark(verse.key)),
                                    );
                                  },
                                  separatorBuilder: (context, index) =>
                                      const Divider(height: 1),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            );
          } else {
            scaffoldContent = const Scaffold(
              body: Center(child: Text('لم يتم العثور على بيانات.')),
            );
          }
          // Wrap with PopScope to handle back button (Android/iOS predictive back)
          final popScope = PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) async {
              if (didPop == false && context.mounted) {
                // If in selection mode, exit it first
                if (_selectionMode) {
                  _exitSelectionMode();
                  return;
                }
                // If search is open or searchTerm is not empty, clear and collapse
                if (_showSearchDrawer || _searchController.text.isNotEmpty) {
                  setState(() {
                    _showSearchDrawer = false;
                    _searchController.clear();
                  });
                  // Also update the bloc to clear the search term
                  _submitSearch(context);
                  return;
                }
                // If search drawer is closed, require double back to exit
                final now = DateTime.now();
                if (_lastBackPressed == null ||
                    now.difference(_lastBackPressed!) >
                        const Duration(seconds: 2)) {
                  _lastBackPressed = now;
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text('اضغط رجوع مرة أخرى للخروج'),
                      ),
                    ),
                  );
                  // Block pop
                  return;
                }
                // Allow pop (exit app)
                _lastBackPressed = null;
                SystemNavigator.pop();
              }
            },
            child: scaffoldContent,
          );

          // Desktop/physical-keyboard navigation. A focused text field consumes
          // character and caret keys before they reach here, so editing the
          // search box never triggers these.
          return CallbackShortcuts(
            bindings: <ShortcutActivator, VoidCallback>{
              const SingleActivator(LogicalKeyboardKey.slash): _focusSearch,
              const SingleActivator(LogicalKeyboardKey.keyF, control: true):
                  _focusSearch,
              const SingleActivator(LogicalKeyboardKey.escape): _handleEscape,
              const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                  _scrollByVerses(1),
              const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                  _scrollByVerses(-1),
              const SingleActivator(LogicalKeyboardKey.pageDown): () =>
                  _scrollByVerses(_visibleVerseCount()),
              const SingleActivator(LogicalKeyboardKey.pageUp): () =>
                  _scrollByVerses(-_visibleVerseCount()),
              const SingleActivator(LogicalKeyboardKey.home): () =>
                  _scrollToEdge(end: false),
              const SingleActivator(LogicalKeyboardKey.end): () =>
                  _scrollToEdge(end: true),
              const SingleActivator(
                LogicalKeyboardKey.equal,
                control: true,
              ): () =>
                  getIt<FontSizeBloc>().add(IncreaseFontSize()),
              const SingleActivator(
                LogicalKeyboardKey.add,
                control: true,
              ): () =>
                  getIt<FontSizeBloc>().add(IncreaseFontSize()),
              const SingleActivator(LogicalKeyboardKey.numpadAdd): () =>
                  getIt<FontSizeBloc>().add(IncreaseFontSize()),
              const SingleActivator(
                LogicalKeyboardKey.minus,
                control: true,
              ): () =>
                  getIt<FontSizeBloc>().add(DecreaseFontSize()),
              const SingleActivator(LogicalKeyboardKey.numpadSubtract): () =>
                  getIt<FontSizeBloc>().add(DecreaseFontSize()),
              const SingleActivator(
                LogicalKeyboardKey.keyB,
                control: true,
              ): () =>
                  _openBookmarks(context),
              const SingleActivator(
                LogicalKeyboardKey.keyL,
                control: true,
              ): () =>
                  _openSurahList(context),
            },
            child: Focus(autofocus: true, child: popScope),
          );
        },
      ),
    );
  }
}
