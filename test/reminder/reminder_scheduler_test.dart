import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tkk_eyeguard/core/services/microphone_activity_service.dart';
import 'package:tkk_eyeguard/features/reminder/presentation/scheduler/reminder_scheduler.dart';

/// Test double for [MicrophoneActivityService] that lets us drive mic state.
class FakeMicService implements MicrophoneActivityService {
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  bool _inUse = false;

  @override
  bool get isInUse => _inUse;

  @override
  Stream<bool> get stream => _controller.stream;

  void set(bool value) {
    _inUse = value;
    _controller.add(value);
  }

  @override
  Future<void> start() async {}

  @override
  Future<void> dispose() async => _controller.close();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeMicService mic;
  late ReminderScheduler scheduler;

  setUp(() {
    mic = FakeMicService();
    scheduler = ReminderScheduler(micService: mic);
  });

  tearDown(() async {
    await scheduler.dispose();
    await mic.dispose();
  });

  test('fires a reminder after the configured interval', () {
    fakeAsync((async) {
      final List<DateTime> due = <DateTime>[];
      scheduler.onDue.listen(due.add);

      scheduler.start(
        interval: const Duration(minutes: 1),
        respectMeetings: true,
      );

      async.elapse(const Duration(minutes: 1));
      expect(due, hasLength(1));
    });
  });

  test('defers the reminder while the microphone is in use', () {
    fakeAsync((async) {
      final List<DateTime> due = <DateTime>[];
      scheduler.onDue.listen(due.add);

      mic.set(true); // in a call
      scheduler.start(
        interval: const Duration(minutes: 1),
        respectMeetings: true,
      );

      async.elapse(const Duration(minutes: 1));
      expect(due, isEmpty, reason: 'should not interrupt a meeting');

      mic.set(false); // call ends
      async.flushMicrotasks();
      // Cool-down window is 2–5 minutes; nothing yet at +1 min.
      async.elapse(const Duration(minutes: 1));
      expect(due, isEmpty);

      // After the maximum cool-down the deferred reminder appears.
      async.elapse(const Duration(minutes: 5));
      expect(due, hasLength(1));
    });
  });

  test('snooze re-arms for the snooze duration', () {
    fakeAsync((async) {
      final List<DateTime> due = <DateTime>[];
      scheduler.onDue.listen(due.add);

      scheduler.start(
        interval: const Duration(minutes: 60),
        respectMeetings: false,
      );
      scheduler.snooze(const Duration(minutes: 5));

      async.elapse(const Duration(minutes: 5));
      expect(due, hasLength(1));
    });
  });
}
