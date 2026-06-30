import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/constants/reminder_messages.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../controllers/dashboard_controller.dart';
import '../../../../shared/widgets/stat_card.dart';

/// Overview of the user's eye-care activity: today's outcomes, streaks and
/// completion rates.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Timer? _previewTimer;
  int _previewLeft = AppConfig.exerciseDuration.inSeconds;

  bool get _isPreviewRunning => _previewTimer != null;

  void _togglePreviewTimer() {
    if (_isPreviewRunning) {
      _previewTimer?.cancel();
      setState(() => _previewTimer = null);
      return;
    }
    if (_previewLeft <= 0) {
      _previewLeft = AppConfig.exerciseDuration.inSeconds;
    }
    _previewTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_previewLeft > 0) {
          _previewLeft--;
        } else {
          _previewTimer?.cancel();
          _previewTimer = null;
        }
      });
    });
    setState(() {});
  }

  void _resetPreviewTimer() {
    _previewTimer?.cancel();
    setState(() {
      _previewTimer = null;
      _previewLeft = AppConfig.exerciseDuration.inSeconds;
    });
  }

  @override
  void dispose() {
    _previewTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
          children: <Widget>[
            _HeroCard(stats: stats),
            const SizedBox(height: 16),
            _CountdownCard(
              secondsLeft: _previewLeft,
              isRunning: _isPreviewRunning,
              onToggle: _togglePreviewTimer,
              onReset: _resetPreviewTimer,
              onStartExercise: () => context.push('/exercise'),
            ),
            const SizedBox(height: 20),
            Text('Exercise checklist', style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            const _ExerciseChecklist(),
            const SizedBox(height: 22),
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
                  'Welcome back, ${AppConfig.userName}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$last\n${AppConfig.tagline}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => GoRouter.of(context).push('/exercise'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start 30s eye reset'),
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

class _CountdownCard extends StatelessWidget {
  const _CountdownCard({
    required this.secondsLeft,
    required this.isRunning,
    required this.onToggle,
    required this.onReset,
    required this.onStartExercise,
  });

  final int secondsLeft;
  final bool isRunning;
  final VoidCallback onToggle;
  final VoidCallback onReset;
  final VoidCallback onStartExercise;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double progress =
        (AppConfig.exerciseDuration.inSeconds - secondsLeft) /
        AppConfig.exerciseDuration.inSeconds;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.timer_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Text('30-second preview timer', style: theme.textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Quickly preview the break flow, then start the full guided routine.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 12),
          Text(
            '$secondsLeft s left',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              FilledButton.icon(
                onPressed: onToggle,
                icon: Icon(isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                label: Text(isRunning ? 'Pause' : 'Start'),
              ),
              OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Reset'),
              ),
              OutlinedButton.icon(
                onPressed: onStartExercise,
                icon: const Icon(Icons.self_improvement_rounded),
                label: const Text('Open full exercise'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExerciseChecklist extends StatelessWidget {
  const _ExerciseChecklist();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      children: ReminderMessages.steps.asMap().entries.map((entry) {
        final int i = entry.key;
        final ExerciseStep step = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 14,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.14),
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(step.title, style: theme.textTheme.labelLarge),
                    const SizedBox(height: 3),
                    Text(
                      '${step.instruction} (${step.seconds}s)',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
