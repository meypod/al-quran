import 'package:flutter/material.dart';
import '../../core/data/model/surah.dart';
import '../../core/data/provider/surah_list_provider.dart';
import '../../core/utils/arabic_number_util.dart';

class SurahListPage extends StatelessWidget {
  const SurahListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سور القرآن')),
      body: FutureBuilder<List<Surah>>(
        future: SurahListProvider.loadSurahs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No surahs found.'));
          }
          final surahs = snapshot.data!;
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
                      title: Text(surah.name, textDirection: TextDirection.rtl),
                      subtitle: Text(
                        surah.type == 'k' ? 'مكي' : 'مدني',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        textScaler: TextScaler.linear(0.60),
                      ),
                      leading: Text(
                        toArabicNumber(surah.totalVerses),
                        textDirection: TextDirection.rtl,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  }
                  currentIndex++;
                }
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
