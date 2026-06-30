import 'package:flutter_test/flutter_test.dart';
import 'package:tkk_eyeguard/features/reminder/data/models/reminder_event_model.dart';
import 'package:tkk_eyeguard/features/reminder/domain/entities/reminder_event.dart';

void main() {
  test('ReminderEventModel round-trips through its entity', () {
    final ReminderEvent original = ReminderEvent(
      id: 'abc-123',
      timestamp: DateTime(2026, 6, 30, 9, 15),
      outcome: ReminderOutcome.completed,
    );

    final ReminderEventModel model = ReminderEventModel.fromEntity(original);
    final ReminderEvent restored = model.toEntity();

    expect(restored.id, original.id);
    expect(restored.timestamp, original.timestamp);
    expect(restored.outcome, original.outcome);
  });
}
