import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_config.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../controllers/dashboard_controller.dart';
import '../../../../shared/widgets/stat_card.dart';

/// Overview of the user's eye-care activity: today's outcomes, streaks and
/// completion rates.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DashboardStats stats = ref.watch(dashboardControllerProvider);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConfig.appName),
        actions: <Widget>[
          IconButton(
            tooltip: 'Refresh',
            onPressed: () =>
                ref.read(dashboardControllerProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: <Widget>[
            _HeroCard(stats: stats),
            const SizedBox(height: 20),
            Text("Today", style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            _TodayGrid(stats: stats),
            const SizedBox(height: 24),
            Text('Streaks & Trends', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            _TrendsGrid(stats: stats),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int pct = (stats.todayCompletionRate * 100).round();
    final String last = stats.lastReminder == null
        ? 'No reminders yet'
        : 'Last reminder ${DateFormat.jm().format(stats.lastReminder!)}';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Keep your eyes happy',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  last,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          _RingPercent(percent: pct),
        ],
      ),
    );
  }
}

class _RingPercent extends StatelessWidget {
  const _RingPercent({required this.percent});
  final int percent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      height: 78,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox(
            width: 78,
            height: 78,
            child: CircularProgressIndicator(
              value: percent / 100,
              strokeWidth: 7,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          Text(
            '$percent%',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayGrid extends StatelessWidget {
  const _TodayGrid({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return _ResponsiveGrid(
      children: <Widget>[
        StatCard(
          label: 'Reminders',
          value: '${stats.todayTotal}',
          icon: Icons.notifications_active_rounded,
        ),
        StatCard(
          label: 'Completed',
          value: '${stats.todayCompleted}',
          icon: Icons.check_circle_rounded,
          accent: AppColors.success,
        ),
        StatCard(
          label: 'Snoozed',
          value: '${stats.todaySnoozed}',
          icon: Icons.snooze_rounded,
          accent: AppColors.warning,
        ),
        StatCard(
          label: 'Skipped',
          value: '${stats.todaySkipped}',
          icon: Icons.cancel_rounded,
          accent: AppColors.danger,
        ),
      ],
    );
  }
}

class _TrendsGrid extends StatelessWidget {
  const _TrendsGrid({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final int avg = (stats.averageCompletionRate * 100).round();
    return _ResponsiveGrid(
      children: <Widget>[
        StatCard(
          label: 'Current streak',
          value: '${stats.currentStreakDays}d',
          icon: Icons.local_fire_department_rounded,
          accent: AppColors.warning,
        ),
        StatCard(
          label: 'This week',
          value: '${stats.weeklyCompleted}',
          icon: Icons.calendar_view_week_rounded,
        ),
        StatCard(
          label: 'This month',
          value: '${stats.monthlyCompleted}',
          icon: Icons.calendar_month_rounded,
        ),
        StatCard(
          label: 'Avg completion',
          value: '$avg%',
          icon: Icons.trending_up_rounded,
          accent: AppColors.success,
        ),
      ],
    );
  }
}

/// Lays children out as cards that wrap responsively (2 per row on mobile,
/// 4 on desktop).
class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth >= 640 ? 4 : 2;
        const double spacing = 14;
        final double width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map((Widget c) => SizedBox(width: width, child: c))
              .toList(),
        );
      },
    );
  }
}
