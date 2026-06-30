import 'package:hive/hive.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/reminder_event.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../models/reminder_event_model.dart';

/// Hive-backed [ReminderRepository].
class ReminderRepositoryImpl implements ReminderRepository {
  ReminderRepositoryImpl(this._box);

  final Box<ReminderEventModel> _box;

  @override
  Future<void> record(ReminderEvent event) async {
    try {
      await _box.put(event.id, ReminderEventModel.fromEntity(event));
    } catch (e) {
      throw StorageException('Failed to record reminder event: $e');
    }
  }

  @override
  List<ReminderEvent> all() {
    final List<ReminderEvent> events =
        _box.values.map((ReminderEventModel m) => m.toEntity()).toList();
    events.sort((ReminderEvent a, ReminderEvent b) =>
        b.timestamp.compareTo(a.timestamp));
    return events;
  }

  @override
  List<ReminderEvent> forDay(DateTime day) {
    return all().where((ReminderEvent e) {
      return e.timestamp.year == day.year &&
          e.timestamp.month == day.month &&
          e.timestamp.day == day.day;
    }).toList();
  }

  @override
  Future<void> clear() => _box.clear();
}
