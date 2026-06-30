import 'dart:ui';

import 'package:flutter/material.dart';

/// A frosted-glass surface used across the app for the modern, Apple-inspired
/// aesthetic. Falls back gracefully to a solid card when blur is unsupported.
class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.blur = 18,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color tint = (isDark ? Colors.white : Colors.white)
        .withValues(alpha: isDark ? 0.06 : 0.55);

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.6),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
