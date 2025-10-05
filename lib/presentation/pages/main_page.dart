import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/bloc/quran/filtered_quran_event.dart';
import '../../core/bloc/quran/filtered_quran_state.dart';
import '../../core/bloc/quran/filtered_quran_bloc.dart';
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
  void _saveScrollOffset() {
    QuranPreferences.setScrollPosition(_scrollController.offset);
  }

  final ScrollController _scrollController = ScrollController();

  bool _showFontDrawer = false;

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
      _showFontDrawer = !_showFontDrawer;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredQuranBloc = getIt<FilteredQuranBloc>();
    return BlocProvider<FilteredQuranBloc>.value(
      value: filteredQuranBloc,
      child: BlocBuilder<FilteredQuranBloc, FilteredQuranState>(
        builder: (context, state) {
          if (state is FilteredQuranInitial || state is FilteredQuranLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is FilteredQuranError) {
            return Scaffold(
              body: Center(
                child: Text('حدث خطأ أثناء تحميل القرآن: ${state.message}'),
              ),
            );
          } else if (state is FilteredQuranLoaded) {
            final selectedSurah = state.selectedSurah;
            final surahName = selectedSurah?.name ?? "بحث";
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
            return Scaffold(
              appBar: AppBar(
                title: Text(surahName, textAlign: TextAlign.center),
                centerTitle: true,
                leadingWidth: 100,
                leading: Row(
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
                actions: [],
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
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
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
                            verseText: verse.verseText,
                            verseNumber: verse.verseNumber,
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
          }
          return const Scaffold(
            body: Center(child: Text('لم يتم العثور على بيانات.')),
          );
        },
      ),
    );
  }
}
