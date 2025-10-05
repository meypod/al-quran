import 'package:flutter/material.dart';

import '../../core/bloc/quran/quran_bloc.dart';
import '../../locator.dart';
import '../../core/data/model/surah.dart';
import '../../core/utils/quran_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/VerseRenderer.dart';

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

  @override
  Widget build(BuildContext context) {
    final quranBloc = getIt<QuranBloc>();
    return BlocBuilder<QuranBloc, QuranState>(
      bloc: quranBloc,
      builder: (context, state) {
        if (state is QuranLoading || state is QuranInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is QuranError) {
          return Scaffold(
            body: Center(
              child: Text('حدث خطأ أثناء تحميل القرآن: ${state.message}'),
            ),
          );
        } else if (state is QuranLoaded) {
          final selectedSurah = state.selectedSurah;
          final surahName = selectedSurah.name;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients &&
                _scrollController.offset != state.scrollOffset) {
              _scrollController.jumpTo(state.scrollOffset);
            }
          });
          return Scaffold(
            appBar: AppBar(
              title: Text(surahName, textAlign: TextAlign.center),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.menu_book),
                tooltip: 'سور القرآن',
                onPressed: () async {
                  final selected = await context.push<Surah>('/surahs');
                  if (selected is Surah) {
                    quranBloc.add(ChangeSurah(surahId: selected.id));
                  }
                },
              ),
            ),
            body: ListView.separated(
              controller: _scrollController,
              itemCount: state.filteredVerses.length,
              cacheExtent: 100,
              itemBuilder: (context, index) {
                final verse = state.filteredVerses[index];
                return VerseRenderer(
                  verseText: verse.verseText,
                  verseNumber: verse.verseNumber,
                );
              },
              separatorBuilder: (context, index) => const Divider(height: 1),
            ),
          );
        }
        return const Scaffold(
          body: Center(child: Text('لم يتم العثور على بيانات.')),
        );
      },
    );
  }
}
