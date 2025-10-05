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
                displayLarge: TextStyle(fontSize: 32, fontFamily: 'Hafs'),
                displayMedium: TextStyle(fontSize: 28, fontFamily: 'Hafs'),
                displaySmall: TextStyle(fontSize: 24, fontFamily: 'Hafs'),
                headlineLarge: TextStyle(fontSize: 22, fontFamily: 'Hafs'),
                headlineMedium: TextStyle(fontSize: 20, fontFamily: 'Hafs'),
                headlineSmall: TextStyle(fontSize: 18, fontFamily: 'Hafs'),
                titleLarge: TextStyle(fontSize: 18, fontFamily: 'Hafs'),
                titleMedium: TextStyle(fontSize: 16, fontFamily: 'Hafs'),
                titleSmall: TextStyle(fontSize: 14, fontFamily: 'Hafs'),
                bodyLarge: TextStyle(fontSize: 16, fontFamily: 'Hafs'),
                bodyMedium: TextStyle(fontSize: 14, fontFamily: 'Hafs'),
                bodySmall: TextStyle(fontSize: 12, fontFamily: 'Hafs'),
                labelLarge: TextStyle(fontSize: 14, fontFamily: 'Hafs'),
                labelMedium: TextStyle(fontSize: 12, fontFamily: 'Hafs'),
                labelSmall: TextStyle(fontSize: 10, fontFamily: 'Hafs'),
              ).apply(fontSizeFactor: state.fontSize / 16.0),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.dark,
              ),
              textTheme: TextTheme(
                displayLarge: TextStyle(fontSize: 32, fontFamily: 'Hafs'),
                displayMedium: TextStyle(fontSize: 28, fontFamily: 'Hafs'),
                displaySmall: TextStyle(fontSize: 24, fontFamily: 'Hafs'),
                headlineLarge: TextStyle(fontSize: 22, fontFamily: 'Hafs'),
                headlineMedium: TextStyle(fontSize: 20, fontFamily: 'Hafs'),
                headlineSmall: TextStyle(fontSize: 18, fontFamily: 'Hafs'),
                titleLarge: TextStyle(fontSize: 18, fontFamily: 'Hafs'),
                titleMedium: TextStyle(fontSize: 16, fontFamily: 'Hafs'),
                titleSmall: TextStyle(fontSize: 14, fontFamily: 'Hafs'),
                bodyLarge: TextStyle(fontSize: 16, fontFamily: 'Hafs'),
                bodyMedium: TextStyle(fontSize: 14, fontFamily: 'Hafs'),
                bodySmall: TextStyle(fontSize: 12, fontFamily: 'Hafs'),
                labelLarge: TextStyle(fontSize: 14, fontFamily: 'Hafs'),
                labelMedium: TextStyle(fontSize: 12, fontFamily: 'Hafs'),
                labelSmall: TextStyle(fontSize: 10, fontFamily: 'Hafs'),
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
