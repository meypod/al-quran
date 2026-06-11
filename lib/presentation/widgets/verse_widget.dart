// Widget to render a Quran verse with number at the end
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:al_quran/core/data/model/quran_verse.dart';
import 'package:al_quran/locator.dart';
import 'package:al_quran/core/bloc/quran/quran_bloc.dart';

import '../../core/utils/arabic_number_util.dart';

class VerseWidget extends StatefulWidget {
  final QuranVerse verse;
  final bool isSearchResult;
  final List<(int, int)> highlights;
  final bool selectionMode;
  final bool selected;
  final VoidCallback? onSelectToggle;
  final bool isBookmarked;
  final VoidCallback? onBookmarkToggle;

  const VerseWidget({
    super.key,
    required this.verse,
    required this.isSearchResult,
    required this.highlights,
    this.selectionMode = false,
    this.selected = false,
    this.onSelectToggle,
    this.isBookmarked = false,
    this.onBookmarkToggle,
  });

  /// Resolves the display name "SurahName (arabicId)" for a verse, or '' if unknown.
  static String surahNameFor(QuranVerse verse) {
    final quranBloc = getIt<QuranBloc>();
    if (quranBloc.state is QuranLoaded) {
      final surah = (quranBloc.state as QuranLoaded).surahs.elementAtOrNull(
        verse.surahId - 1,
      );
      if (surah != null) {
        return "${surah.name} (${toArabicNumber(verse.surahId)})";
      }
    }
    return '';
  }

  /// Clipboard format: verse text + number, then surah name, each ending with \n.
  static String copyText(QuranVerse verse, String surahName) {
    final verseLine =
        verse.verseText +
        (verse.verseNumber == 0
            ? ''
            : ' ﴿${toArabicNumber(verse.verseNumber)}﴾');
    return '$verseLine\n$surahName\n';
  }

  @override
  State<VerseWidget> createState() => _VerseWidgetState();
}

class _VerseWidgetState extends State<VerseWidget> {
  /// True while the row's context menu is open; highlights the row one shade.
  bool _menuOpen = false;

  /// Last pointer-down position, used to anchor the long-press menu.
  Offset? _pressPosition;

  /// True while a mouse hovers the row. Touch input produces no hover events,
  /// so this distinguishes desktop (mouse) from mobile (touch): on desktop we
  /// drop the ripple/long-press layer so primary clicks reach text selection.
  bool _mouseOver = false;

  QuranVerse get _verse => widget.verse;

  @override
  Widget build(BuildContext context) {
    final surahName = widget.isSearchResult
        ? VerseWidget.surahNameFor(_verse)
        : '';
    final hasSurahName = surahName.isNotEmpty;
    final bookmarkable =
        widget.onBookmarkToggle != null && _verse.verseNumber != 0;
    final tile = ListTile(
      selected: widget.selectionMode && widget.selected,
      tileColor: _menuOpen
          ? Theme.of(context).colorScheme.surfaceContainerHigh
          : null,
      onTap: widget.selectionMode ? widget.onSelectToggle : null,
      leading: widget.selectionMode
          ? Checkbox(
              value: widget.selected,
              onChanged: (_) => widget.onSelectToggle?.call(),
            )
          : null,
      title: buildHighlightedText(context),
      subtitle: hasSurahName
          ? Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: Text(
                    surahName,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                if (!widget.selectionMode)
                  IconButton(
                    icon: const Icon(Icons.copy, size: 26),
                    tooltip: 'نسخ',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _copyVerse(context, surahName),
                  ),
                if (!widget.selectionMode && bookmarkable)
                  IconButton(
                    icon: Icon(
                      widget.isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      size: 26,
                      color: widget.isBookmarked
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    tooltip: widget.isBookmarked
                        ? 'إزالة العلامة'
                        : 'إضافة علامة',
                    visualDensity: VisualDensity.compact,
                    onPressed: widget.onBookmarkToggle,
                  ),
              ],
            )
          : null,
    );

    // Normal reading view has no inline buttons; expose copy/bookmark through a
    // context menu on long-press (touch) or right-click (desktop).
    if (widget.selectionMode || widget.isSearchResult || !bookmarkable) {
      return tile;
    }
    return MouseRegion(
      onEnter: (_) {
        if (!_mouseOver) setState(() => _mouseOver = true);
      },
      onExit: (_) {
        if (_mouseOver) setState(() => _mouseOver = false);
      },
      // Right-click opens the menu on desktop without touching text selection.
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onSecondaryTapDown: (d) => _showRowMenu(context, d.globalPosition),
        child: Stack(
          children: [
            tile,
            // Touch only: a ripple + long-press layer over the row. Removed
            // while a mouse hovers, so desktop clicks/drags select text.
            if (!_mouseOver)
              Positioned.fill(
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTapDown: (d) => _pressPosition = d.globalPosition,
                    onLongPress: () {
                      final position = _pressPosition;
                      if (position != null) _showRowMenu(context, position);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRowMenu(BuildContext context, Offset globalPosition) async {
    const double menuWidth = 220;
    final Size screen = MediaQuery.of(context).size;
    final double left = globalPosition.dx
        .clamp(8.0, screen.width - menuWidth - 8)
        .toDouble();
    final double top = globalPosition.dy
        .clamp(8.0, screen.height - 120)
        .toDouble();
    // One tonal step off the app background so the menu stands out in both
    // light and dark modes.
    final Color menuColor = Theme.of(context).colorScheme.surfaceContainerLow;

    setState(() => _menuOpen = true);
    await showGeneralDialog<void>(
      context: context,
      barrierLabel: 'menu',
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 100),
      transitionBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
      pageBuilder: (dialogContext, _, _) {
        return Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              width: menuWidth,
              child: Material(
                color: menuColor,
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _menuItem(
                      dialogContext,
                      widget.isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      widget.isBookmarked ? 'إزالة العلامة' : 'إضافة علامة',
                      widget.onBookmarkToggle,
                    ),
                    _menuItem(
                      dialogContext,
                      Icons.copy,
                      'نسخ',
                      () =>
                          _copyVerse(context, VerseWidget.surahNameFor(_verse)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
    if (mounted) setState(() => _menuOpen = false);
  }

  Widget _menuItem(
    BuildContext dialogContext,
    IconData icon,
    String label,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap == null
          ? null
          : () {
              Navigator.of(dialogContext).pop();
              onTap();
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Text(label, textDirection: TextDirection.rtl),
          ],
        ),
      ),
    );
  }

  void _copyVerse(BuildContext context, String surahName) {
    Clipboard.setData(
      ClipboardData(text: VerseWidget.copyText(_verse, surahName)),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم النسخ', textDirection: TextDirection.rtl),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // If isSearchResult and highlights is not empty, highlight the text
  Widget buildHighlightedText(BuildContext context) {
    if (!widget.isSearchResult || widget.highlights.isEmpty) {
      return Text(
        _verse.verseText +
            (_verse.verseNumber == 0
                ? ''
                : ' ﴿${toArabicNumber(_verse.verseNumber)}﴾'),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
      );
    }

    final text = _verse.verseText;
    final defaultStyle = DefaultTextStyle.of(context).style;
    final List<InlineSpan> spans = [];
    int current = 0;
    for (final (start, end) in widget.highlights) {
      if (start > current) {
        spans.add(
          TextSpan(text: text.substring(current, start), style: defaultStyle),
        );
      }
      spans.add(
        TextSpan(
          text: text.substring(start, end),
          style: defaultStyle.copyWith(
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? const Color.fromARGB(255, 255, 241, 117) // intense in light
                : const Color.fromARGB(104, 255, 246, 161), // softer in dark
          ),
        ),
      );
      current = end;
    }
    if (current < text.length) {
      spans.add(TextSpan(text: text.substring(current), style: defaultStyle));
    }
    // Add verse number at the end
    if (_verse.verseNumber != 0) {
      spans.add(
        TextSpan(
          text: ' ﴿${toArabicNumber(_verse.verseNumber)}﴾',
          style: defaultStyle,
        ),
      );
    }
    return Text.rich(
      TextSpan(style: defaultStyle, children: spans),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
    );
  }
}
