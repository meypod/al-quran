import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/bloc/font_size/font_size_bloc.dart';
import '../../locator.dart';
import 'dart:async';

class FontAdjuster extends StatefulWidget {
  const FontAdjuster({super.key});

  @override
  State<FontAdjuster> createState() => _FontAdjusterState();
}

class _FontAdjusterState extends State<FontAdjuster> {
  Timer? _incTimer;
  double _expStep = 1.0;

  void _startIncRepeat() {
    _expStep = 1.0;
    _incTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      getIt<FontSizeBloc>().add(IncreaseFontSize(step: _expStep));
      setState(() {
        _expStep = (_expStep * 1.25).clamp(
          1.0,
          20.0,
        ); // exponential growth, max 20
      });
    });
  }

  void _stopIncRepeat() {
    _incTimer?.cancel();
    _incTimer = null;
  }

  Timer? _decTimer;
  double _decExpStep = 1.0;
  void _startDecRepeat() {
    _decExpStep = 1.0;
    _decTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      getIt<FontSizeBloc>().add(DecreaseFontSize(step: _decExpStep));
      setState(() {
        _decExpStep = (_decExpStep * 1.25).clamp(1.0, 20.0);
      });
    });
  }

  void _stopDecRepeat() {
    _decTimer?.cancel();
    _decTimer = null;
  }

  @override
  void dispose() {
    _incTimer?.cancel();
    _decTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FontSizeBloc, FontSizeState>(
      bloc: getIt<FontSizeBloc>(),
      builder: (context, fontSizeState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => getIt<FontSizeBloc>().add(DecreaseFontSize()),
              onLongPressStart: (_) => _startDecRepeat(),
              onLongPressEnd: (_) => _stopDecRepeat(),
              child: IconButton(
                icon: const Icon(Icons.remove),
                onPressed: null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                fontSizeState.fontSize.toStringAsFixed(0),
                style: const TextStyle(fontSize: 20),
              ),
            ),
            GestureDetector(
              onTap: () => getIt<FontSizeBloc>().add(IncreaseFontSize()),
              onLongPressStart: (_) => _startIncRepeat(),
              onLongPressEnd: (_) => _stopIncRepeat(),
              child: IconButton(icon: const Icon(Icons.add), onPressed: null),
            ),
          ],
        );
      },
    );
  }
}
