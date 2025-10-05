import 'package:flutter/material.dart';
import '../../core/data/provider/quran_text_provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Future<List<String>> _quranLinesFuture;

  @override
  void initState() {
    super.initState();
    _quranLinesFuture = QuranTextProvider.loadQuranText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Quran')),
      body: FutureBuilder<List<String>>(
        future: _quranLinesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found.'));
          }
          final lines = snapshot.data!;
          return ListView.separated(
            itemCount: lines.length,
            cacheExtent: 100,
            itemBuilder: (context, index) => ListTile(
              title: Text(
                lines[index],
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontFamily: 'Hafs'),
              ),
            ),
            separatorBuilder: (context, index) => const Divider(height: 1),
          );
        },
      ),
    );
  }
}
