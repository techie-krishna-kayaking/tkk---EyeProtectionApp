import 'package:equatable/equatable.dart';

/// The outcome the user chose for a given reminder.
enum ReminderOutcome { completed, skipped, snoozed, deferredByMeeting }

/// A single historical reminder event. Persisted for statistics & streaks.
class ReminderEvent extends Equatable {
  const ReminderEvent({
    required this.id,
    required this.timestamp,
    required this.outcome,
  });

  final String id;
  final DateTime timestamp;
  final ReminderOutcome outcome;

  @override
  List<Object?> get props => <Object?>[id, timestamp, outcome];
}
