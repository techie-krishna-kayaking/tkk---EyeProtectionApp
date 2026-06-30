import 'package:equatable/equatable.dart';

/// Aggregated, read-only statistics derived from reminder history. Computed in
/// the domain layer so the UI is purely presentational.
class DashboardStats extends Equatable {
  const DashboardStats({
    required this.todayTotal,
    required this.todayCompleted,
    required this.todaySkipped,
    required this.todaySnoozed,
    required this.currentStreakDays,
    required this.weeklyCompleted,
    required this.monthlyCompleted,
    required this.averageCompletionRate,
    required this.lastReminder,
  });

  final int todayTotal;
  final int todayCompleted;
  final int todaySkipped;
  final int todaySnoozed;
  final int currentStreakDays;
  final int weeklyCompleted;
  final int monthlyCompleted;

  /// 0.0 – 1.0 completion ratio across all recorded history.
  final double averageCompletionRate;
  final DateTime? lastReminder;

  /// Today's completion ratio (0.0 – 1.0), guarding against divide-by-zero.
  double get todayCompletionRate =>
      todayTotal == 0 ? 0 : todayCompleted / todayTotal;

  static const DashboardStats empty = DashboardStats(
    todayTotal: 0,
    todayCompleted: 0,
    todaySkipped: 0,
    todaySnoozed: 0,
    currentStreakDays: 0,
    weeklyCompleted: 0,
    monthlyCompleted: 0,
    averageCompletionRate: 0,
    lastReminder: null,
  );

  @override
  List<Object?> get props => <Object?>[
        todayTotal,
        todayCompleted,
        todaySkipped,
        todaySnoozed,
        currentStreakDays,
        weeklyCompleted,
        monthlyCompleted,
        averageCompletionRate,
        lastReminder,
      ];
}
