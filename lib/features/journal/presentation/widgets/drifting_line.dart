import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// An indeterminate progress line: a short segment drifting across a hairline
/// track. No percentage, no spinner — it says "working" without pretending to
/// know how long it will take.
class DriftingLine extends StatefulWidget {
  const DriftingLine({super.key, this.width = 280});

  final double width;

  @override
  State<DriftingLine> createState() => _DriftingLineState();
}

class _DriftingLineState extends State<DriftingLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final segment = widget.width * 0.32;
    return SizedBox(
      width: widget.width,
      height: 3,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(999),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = Curves.easeInOut.transform(_controller.value);
              return Align(
                alignment: Alignment(t * 2 - 1, 0),
                child: child,
              );
            },
            child: Container(
              width: segment,
              decoration: BoxDecoration(
                color: AppColors.coral,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
