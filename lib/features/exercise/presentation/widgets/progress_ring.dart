import 'package:flutter/material.dart';

/// A circular progress ring with a centred label, used as the exercise
/// countdown and completion indicator.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    required this.progress,
    required this.label,
    this.size = 120,
    this.color,
    super.key,
  });

  /// 0.0 – 1.0.
  final double progress;
  final String label;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color ring = color ?? Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox(
            width: size,
            height: size,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 350),
              builder: (BuildContext context, double value, _) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 9,
                  strokeCap: StrokeCap.round,
                  backgroundColor: ring.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(ring),
                );
              },
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }
}
