import '../../../reminder/domain/entities/reminder_event.dart';
import '../entities/dashboard_stats.dart';

/// Pure function that turns raw [ReminderEvent]s into [DashboardStats].
///
/// Kept free of I/O so it is trivially unit-testable.
class CalculateStats {
  const CalculateStats();

  DashboardStats call(List<ReminderEvent> events, {DateTime? now}) {
    final DateTime today = now ?? DateTime.now();

    if (events.isEmpty) return DashboardStats.empty;

    final List<ReminderEvent> todays = events
        .where((ReminderEvent e) => _sameDay(e.timestamp, today))
        .toList();

    final int todayCompleted = _count(todays, ReminderOutcome.completed);
    final int todaySkipped = _count(todays, ReminderOutcome.skipped);
    final int todaySnoozed = _count(todays, ReminderOutcome.snoozed);

    final DateTime weekStart = today.subtract(const Duration(days: 7));
    final int weeklyCompleted = events
        .where((ReminderEvent e) =>
            e.outcome == ReminderOutcome.completed &&
            e.timestamp.isAfter(weekStart))
        .length;

    final DateTime monthStart = today.subtract(const Duration(days: 30));
    final int monthlyCompleted = events
        .where((ReminderEvent e) =>
            e.outcome == ReminderOutcome.completed &&
            e.timestamp.isAfter(monthStart))
        .length;

    final int totalCompleted =
        events.where((ReminderEvent e) => e.outcome == ReminderOutcome.completed).length;
    final int decisive = events
        .where((ReminderEvent e) =>
            e.outcome == ReminderOutcome.completed ||
            e.outcome == ReminderOutcome.skipped)
        .length;
    final double avgRate = decisive == 0 ? 0 : totalCompleted / decisive;

    return DashboardStats(
      todayTotal: todays.length,
      todayCompleted: todayCompleted,
      todaySkipped: todaySkipped,
      todaySnoozed: todaySnoozed,
      currentStreakDays: _currentStreak(events, today),
      weeklyCompleted: weeklyCompleted,
      monthlyCompleted: monthlyCompleted,
      averageCompletionRate: avgRate,
      lastReminder: events.first.timestamp,
    );
  }

  int _count(List<ReminderEvent> events, ReminderOutcome outcome) =>
      events.where((ReminderEvent e) => e.outcome == outcome).length;

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Consecutive days (ending today or yesterday) with at least one completion.
  int _currentStreak(List<ReminderEvent> events, DateTime today) {
    final Set<int> completedDays = events
        .where((ReminderEvent e) => e.outcome == ReminderOutcome.completed)
        .map((ReminderEvent e) =>
            DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day)
                .millisecondsSinceEpoch)
        .toSet();

    int streak = 0;
    DateTime cursor = DateTime(today.year, today.month, today.day);

    // Allow the streak to count even if today has no completion yet.
    if (!completedDays.contains(cursor.millisecondsSinceEpoch)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    while (completedDays.contains(cursor.millisecondsSinceEpoch)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
