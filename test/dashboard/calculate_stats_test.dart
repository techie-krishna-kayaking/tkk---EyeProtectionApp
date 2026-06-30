import 'package:flutter_test/flutter_test.dart';
import 'package:tkk_eyeguard/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:tkk_eyeguard/features/dashboard/domain/usecases/calculate_stats.dart';
import 'package:tkk_eyeguard/features/reminder/domain/entities/reminder_event.dart';

void main() {
  const CalculateStats calculate = CalculateStats();
  final DateTime now = DateTime(2026, 6, 30, 12);

  ReminderEvent event(ReminderOutcome outcome, DateTime when) =>
      ReminderEvent(id: when.toIso8601String(), timestamp: when, outcome: outcome);

  group('CalculateStats', () {
    test('returns empty stats for no events', () {
      expect(calculate(<ReminderEvent>[], now: now), DashboardStats.empty);
    });

    test('counts today outcomes correctly', () {
      final List<ReminderEvent> events = <ReminderEvent>[
        event(ReminderOutcome.completed, now.subtract(const Duration(hours: 1))),
        event(ReminderOutcome.completed, now.subtract(const Duration(hours: 2))),
        event(ReminderOutcome.skipped, now.subtract(const Duration(hours: 3))),
        event(ReminderOutcome.snoozed, now.subtract(const Duration(hours: 4))),
      ];

      final DashboardStats stats = calculate(events, now: now);

      expect(stats.todayTotal, 4);
      expect(stats.todayCompleted, 2);
      expect(stats.todaySkipped, 1);
      expect(stats.todaySnoozed, 1);
    });

    test('average completion rate ignores snoozed events', () {
      final List<ReminderEvent> events = <ReminderEvent>[
        event(ReminderOutcome.completed, now),
        event(ReminderOutcome.completed, now),
        event(ReminderOutcome.skipped, now),
        event(ReminderOutcome.snoozed, now),
      ];

      final DashboardStats stats = calculate(events, now: now);
      // 2 completed / (2 completed + 1 skipped) = 0.666...
      expect(stats.averageCompletionRate, closeTo(0.6667, 0.001));
    });

    test('current streak counts consecutive completion days', () {
      final List<ReminderEvent> events = <ReminderEvent>[
        event(ReminderOutcome.completed, now),
        event(ReminderOutcome.completed, now.subtract(const Duration(days: 1))),
        event(ReminderOutcome.completed, now.subtract(const Duration(days: 2))),
        // gap on day 3
        event(ReminderOutcome.completed, now.subtract(const Duration(days: 4))),
      ];

      final DashboardStats stats = calculate(events, now: now);
      expect(stats.currentStreakDays, 3);
    });
  });
}
