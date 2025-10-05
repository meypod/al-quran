import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/bloc/font_size_bloc.dart';

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
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
            home: const MyHomePage(title: 'Flutter Demo Home Page'),
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<FontSizeBloc>().state;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
          // Use theme style (font size is now global)
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Font Size:'),
            Text(state.fontSize.toStringAsFixed(0)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      context.read<FontSizeBloc>().add(DecreaseFontSize()),
                  child: const Text('-'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () =>
                      context.read<FontSizeBloc>().add(IncreaseFontSize()),
                  child: const Text('+'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
