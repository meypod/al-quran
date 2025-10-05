import 'package:flutter/material.dart';
import '../../core/data/model/surah.dart';

import '../../core/bloc/surah_list/surah_list_bloc.dart';
import '../../core/utils/arabic_number_util.dart';

import '../../locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SurahListPage extends StatefulWidget {
  const SurahListPage({super.key});

  @override
  State<SurahListPage> createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage> {
  late final SurahListBloc _bloc = getIt<SurahListBloc>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc.add(SurahListInit());
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _bloc.add(SurahListUpdateSearchTerm(_searchController.text.trimLeft()));
  }

  void _clearSearch() {
    _searchController.clear();
    _bloc.add(SurahListUpdateSearchTerm(''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سور القرآن'), centerTitle: true),
      body: BlocBuilder<SurahListBloc, SurahListState>(
        bloc: _bloc,
        builder: (context, state) {
          if (state is SurahListInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SurahListLoaded) {
            final surahs = state.filteredSurahs;
            final showHeaders = state.searchTerm.isEmpty;
            final Map<int, List<Surah>> juzMap = {};
            for (final surah in surahs) {
              juzMap.putIfAbsent(surah.startsAtJuz, () => []).add(surah);
            }
            final List<Widget> children = [];
            if (showHeaders) {
              for (int juz = 1; juz <= 30; juz++) {
                children.add(
                  ListTile(
                    title: Text(
                      'الجزء ${toArabicNumber(juz)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textDirection: TextDirection.rtl,
                    ),
                    tileColor: Theme.of(
                      context,
                    ).colorScheme.primary.withAlpha(25),
                  ),
                );
                final surahList = juzMap[juz] ?? [];
                for (final surah in surahList) {
                  children.add(_buildSurahTile(context, surah));
                }
              }
            } else {
              for (final surah in surahs) {
                children.add(_buildSurahTile(context, surah));
              }
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'بحث عن سورة',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Theme.of(context).canvasColor,
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: _clearSearch,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: surahs.isEmpty && state.searchTerm.isNotEmpty
                      ? const Center(child: Text('لا توجد نتائج'))
                      : ListView.separated(
                          itemCount: children.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) => children[index],
                        ),
                ),
              ],
            );
          }
          return const Center(child: Text('لم يتم العثور على سور.'));
        },
      ),
    );
  }

  Widget _buildSurahTile(BuildContext context, Surah surah) {
    return ListTile(
      title: Text(surah.name, textDirection: TextDirection.rtl),
      subtitle: Text(
        surah.type == 'k' ? 'مكي' : 'مدني',
        textDirection: TextDirection.rtl,
        style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
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
}
