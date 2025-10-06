import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/bloc/font_size_bloc.dart';
import '../../core/bloc/quran/filtered_quran_event.dart';
import '../../core/bloc/quran/filtered_quran_state.dart';
import '../../core/bloc/quran/filtered_quran_bloc.dart';
import '../../core/utils/text.dart';
import '../../locator.dart';
import '../../core/data/model/surah.dart';
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

  void _saveScrollOffset() {
    QuranPreferences.setScrollPosition(_scrollController.offset);
  }

  final ScrollController _scrollController = ScrollController();

  bool _showFontDrawer = false;
  bool _showSearchDrawer = false;
  final TextEditingController _searchController = TextEditingController();
  bool _searchAllQuran = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_saveScrollOffset);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_saveScrollOffset);
    _scrollController.dispose();
    super.dispose();
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

  void _submitSearch(BuildContext context) {
    final bloc = context.read<FilteredQuranBloc>();
    bloc.add(
      FilteredQuranUpdateSearchTerm(
        _searchController.text.trim(),
        _searchAllQuran,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredQuranBloc = getIt<FilteredQuranBloc>();
    return BlocProvider<FilteredQuranBloc>.value(
      value: filteredQuranBloc,
      child: BlocConsumer<FilteredQuranBloc, FilteredQuranState>(
        listenWhen: (previous, current) =>
            current is FilteredQuranLoaded && previous != current,
        listener: (context, state) {
          if (state is FilteredQuranLoaded) {
            // Set search term and search all Quran state after loading
            if (_searchController.text != state.searchTerm) {
              _searchController.text = state.searchTerm;
            }
            if (_searchAllQuran != state.searchAllQuran) {
              setState(() {
                _searchAllQuran = state.searchAllQuran;
              });
            }
            // If searchTerm is not empty, open the search drawer
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
            final String surahName;
            if (state.searchTerm.isEmpty) {
              surahName = selectedSurah?.name ?? "";
            } else {
              surahName = "بحث";
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients &&
                  _scrollController.offset != state.scrollOffset) {
                final maxScroll = _scrollController.position.maxScrollExtent;
                final minScroll = _scrollController.position.minScrollExtent;
                final target = state.scrollOffset.clamp(minScroll, maxScroll);
                if (target != _scrollController.offset) {
                  _scrollController.jumpTo(target);
                }
              }
            });
            final double fontSize = context.select<FontSizeBloc, double>(
              (bloc) => bloc.state.fontSize,
            );
            final double toolbarHeight = 56.0 + (fontSize - 22.0) * 1.2;

            scaffoldContent = Scaffold(
              appBar: AppBar(
                toolbarHeight: toolbarHeight.clamp(56.0, 120.0),
                title: Text(surahName, textAlign: TextAlign.center),
                centerTitle: true,
                leadingWidth: 100,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu_book),
                        tooltip: 'سور القرآن',
                        onPressed: () async {
                          final selected = await context.push<Surah>('/surahs');
                          if (selected is Surah && context.mounted) {
                            context.read<FilteredQuranBloc>().add(
                              FilteredQuranChangeSurah(selected.id),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.format_size),
                        tooltip: 'تغيير حجم الخط',
                        onPressed: _toggleFontDrawer,
                      ),
                    ],
                  ),
                ),
                actions: [
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
              ),
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
                        : NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification is ScrollEndNotification) {
                                context.read<FilteredQuranBloc>().add(
                                  FilteredQuranUpdateScrollOffset(
                                    _scrollController.offset,
                                  ),
                                );
                              }
                              return false;
                            },
                            child: ListView.separated(
                              key: PageStorageKey(
                                "surah-scroll-${state.selectedSurah?.id ?? 0}", // 0 is for search
                              ),
                              controller: _scrollController,
                              itemCount: state.filteredVerses.length,
                              cacheExtent: 100,
                              itemBuilder: (context, index) {
                                final verse = state.filteredVerses[index];
                                return VerseWidget(
                                  verse: verse,
                                  isSearchResult: state.searchTerm.isNotEmpty,
                                  highlights:
                                      state.highlightMap[verse.key] ?? [],
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
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
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) async {
              if (didPop == false && context.mounted) {
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
        },
      ),
    );
  }
}
