import 'package:get_it/get_it.dart';
import 'core/bloc/quran/quran_bloc.dart';
import 'presentation/pages/main_page.dart';
import 'presentation/pages/surah_list_page.dart';
import 'package:go_router/go_router.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<QuranBloc>(() => QuranBloc()..add(InitQuran()));
  getIt.registerLazySingleton<GoRouter>(
    () => GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const MainPage(),
          routes: [
            GoRoute(
              path: 'surahs',
              builder: (context, state) => const SurahListPage(),
            ),
          ],
        ),
      ],
    ),
  );
}
