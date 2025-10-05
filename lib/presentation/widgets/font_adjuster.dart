import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/bloc/font_size_bloc.dart';
import '../../locator.dart';

class FontAdjuster extends StatelessWidget {
  const FontAdjuster({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FontSizeBloc, FontSizeState>(
      bloc: getIt<FontSizeBloc>(),
      builder: (context, fontSizeState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () => getIt<FontSizeBloc>().add(DecreaseFontSize()),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                fontSizeState.fontSize.toStringAsFixed(0),
                style: const TextStyle(fontSize: 20),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => getIt<FontSizeBloc>().add(IncreaseFontSize()),
            ),
          ],
        );
      },
    );
  }
}
