import '../entities/reminder_event.dart';

/// Contract for recording and querying reminder history.
abstract interface class ReminderRepository {
  /// Appends a new [ReminderEvent].
  Future<void> record(ReminderEvent event);

  /// All recorded events, newest first.
  List<ReminderEvent> all();

  /// Events that occurred on the given local calendar [day].
  List<ReminderEvent> forDay(DateTime day);

  /// Removes every recorded event (used by "Reset data").
  Future<void> clear();
}
