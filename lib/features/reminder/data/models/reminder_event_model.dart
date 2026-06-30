import 'package:hive/hive.dart';

import '../../domain/entities/reminder_event.dart';

/// Hive-friendly model for [ReminderEvent] with a hand-written [TypeAdapter]
/// (no build_runner required — keeps the build deterministic and dependency
/// free at generation time).
class ReminderEventModel {
  const ReminderEventModel({
    required this.id,
    required this.timestampMs,
    required this.outcomeIndex,
  });

  final String id;
  final int timestampMs;
  final int outcomeIndex;

  factory ReminderEventModel.fromEntity(ReminderEvent event) {
    return ReminderEventModel(
      id: event.id,
      timestampMs: event.timestamp.millisecondsSinceEpoch,
      outcomeIndex: event.outcome.index,
    );
  }

  ReminderEvent toEntity() {
    return ReminderEvent(
      id: id,
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestampMs),
      outcome: ReminderOutcome.values[outcomeIndex],
    );
  }
}

/// Manual Hive adapter for [ReminderEventModel].
class ReminderEventAdapter extends TypeAdapter<ReminderEventModel> {
  @override
  final int typeId = 1;

  @override
  ReminderEventModel read(BinaryReader reader) {
    final int fields = reader.readByte();
    final Map<int, dynamic> values = <int, dynamic>{
      for (int i = 0; i < fields; i++) reader.readByte(): reader.read(),
    };
    return ReminderEventModel(
      id: values[0] as String,
      timestampMs: values[1] as int,
      outcomeIndex: values[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ReminderEventModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestampMs)
      ..writeByte(2)
      ..write(obj.outcomeIndex);
  }
}
