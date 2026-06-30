import 'package:flutter/material.dart';

import 'glass_card.dart';

/// Compact metric tile used on the dashboard grid.
class StatCard extends StatelessWidget {
  const StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.accent,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = accent ?? theme.colorScheme.primary;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 16),
          Text(value, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
