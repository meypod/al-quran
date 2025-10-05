import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/bloc/font_size_bloc.dart';
import 'presentation/pages/main_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FontSizeBloc()..add(LoadFontSize()),
      child: BlocBuilder<FontSizeBloc, FontSizeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.light,
              ),
              textTheme: TextTheme(
                displayLarge: TextStyle(fontSize: 32),
                displayMedium: TextStyle(fontSize: 28),
                displaySmall: TextStyle(fontSize: 24),
                headlineLarge: TextStyle(fontSize: 22),
                headlineMedium: TextStyle(fontSize: 20),
                headlineSmall: TextStyle(fontSize: 18),
                titleLarge: TextStyle(fontSize: 18),
                titleMedium: TextStyle(fontSize: 16),
                titleSmall: TextStyle(fontSize: 14),
                bodyLarge: TextStyle(fontSize: 16),
                bodyMedium: TextStyle(fontSize: 14),
                bodySmall: TextStyle(fontSize: 12),
                labelLarge: TextStyle(fontSize: 14),
                labelMedium: TextStyle(fontSize: 12),
                labelSmall: TextStyle(fontSize: 10),
              ).apply(fontSizeFactor: state.fontSize / 16.0),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.dark,
              ),
              textTheme: TextTheme(
                displayLarge: TextStyle(fontSize: 32),
                displayMedium: TextStyle(fontSize: 28),
                displaySmall: TextStyle(fontSize: 24),
                headlineLarge: TextStyle(fontSize: 22),
                headlineMedium: TextStyle(fontSize: 20),
                headlineSmall: TextStyle(fontSize: 18),
                titleLarge: TextStyle(fontSize: 18),
                titleMedium: TextStyle(fontSize: 16),
                titleSmall: TextStyle(fontSize: 14),
                bodyLarge: TextStyle(fontSize: 16),
                bodyMedium: TextStyle(fontSize: 14),
                bodySmall: TextStyle(fontSize: 12),
                labelLarge: TextStyle(fontSize: 14),
                labelMedium: TextStyle(fontSize: 12),
                labelSmall: TextStyle(fontSize: 10),
              ).apply(fontSizeFactor: state.fontSize / 16.0),
            ),
            themeMode: ThemeMode.system,
            home: const MainPage(),
          );
        },
      ),
    );
  }
}
