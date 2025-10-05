import 'package:flutter/widgets.dart';

// adapted from https://stackoverflow.com/a/54173729/67655

class ExpandableSection extends StatefulWidget {
  const ExpandableSection({
    super.key,
    this.expanded = false,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.fastOutSlowIn,
  });

  final bool expanded;
  final Widget child;
  final Duration animationDuration;
  final Curve animationCurve;

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      value: widget.expanded ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(covariant ExpandableSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded != oldWidget.expanded) {
      if (widget.expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
    if (widget.animationDuration != oldWidget.animationDuration) {
      _controller.duration = widget.animationDuration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axisAlignment: 1.0,
      sizeFactor: CurvedAnimation(
        parent: _controller,
        curve: widget.animationCurve,
      ),
      child: widget.child,
    );
  }
}
