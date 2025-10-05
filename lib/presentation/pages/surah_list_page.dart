import 'package:flutter/material.dart';
import '../../core/data/model/surah.dart';
import '../../core/bloc/quran/quran_bloc.dart';
import '../../locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/arabic_number_util.dart';
import 'package:go_router/go_router.dart';

class SurahListPage extends StatelessWidget {
  const SurahListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final quranBloc = getIt<QuranBloc>();
    return Scaffold(
      appBar: AppBar(title: const Text('سور القرآن'), centerTitle: true),
      body: BlocBuilder<QuranBloc, QuranState>(
        bloc: quranBloc,
        builder: (context, state) {
          if (state is QuranLoading || state is QuranInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is QuranLoaded) {
            final surahs = state.surahs;
            // Group by startsAtJuz
            final juzMap = <int, List<Surah>>{};
            for (final surah in surahs) {
              juzMap.putIfAbsent(surah.startsAtJuz, () => []).add(surah);
            }
            return ListView.builder(
              itemCount: 30 + juzMap.values.fold(0, (a, b) => a + b.length),
              itemBuilder: (context, index) {
                int currentIndex = 0;
                for (int juz = 1; juz <= 30; juz++) {
                  // Header
                  if (index == currentIndex) {
                    return ListTile(
                      title: Text(
                        'جز ${toArabicNumber(juz)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textDirection: TextDirection.rtl,
                      ),
                      tileColor: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(25),
                    );
                  }
                  currentIndex++;
                  final surahList = juzMap[juz] ?? [];
                  for (final surah in surahList) {
                    if (index == currentIndex) {
                      return ListTile(
                        title: Text(
                          surah.name,
                          textDirection: TextDirection.rtl,
                        ),
                        subtitle: Text(
                          surah.type == 'k' ? 'مكي' : 'مدني',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          textScaler: TextScaler.linear(0.60),
                        ),
                        trailing: Text(
                          toArabicNumber(surah.id),
                          textDirection: TextDirection.rtl,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        leading: Text(
                          toArabicNumber(surah.totalVerses),
                          textDirection: TextDirection.rtl,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        onTap: () {
                          context.pop(surah);
                        },
                      );
                    }
                    currentIndex++;
                  }
                }
                return const SizedBox.shrink();
              },
            );
          } else if (state is QuranError) {
            return Center(
              child: Text('حدث خطأ أثناء تحميل السور: ${state.message}'),
            );
          }
          return const Center(child: Text('لم يتم العثور على سور.'));
        },
      ),
    );
  }
}
