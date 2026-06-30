import 'dart:async';
import 'dart:math';

import '../../../../core/constants/app_config.dart';
import '../../../../core/services/microphone_activity_service.dart';
import '../../../../core/utils/logger.dart';

/// Drives *when* a reminder should fire.
///
/// Design goals (from the product brief):
///  * Event-driven, **not** polling — a single [Timer] is armed for the exact
///    next due instant, so the CPU stays asleep until then.
///  * Never interrupt a meeting — if the microphone is busy when a reminder is
///    due, the reminder is deferred and re-armed for a randomised cool-down
///    window (2–5 min) after the mic is released.
class ReminderScheduler {
  ReminderScheduler({
    required MicrophoneActivityService micService,
    Random? random,
  })  : _micService = micService,
        _random = random ?? Random();

  final MicrophoneActivityService _micService;
  final Random _random;

  final StreamController<DateTime> _due = StreamController<DateTime>.broadcast();

  /// Emits each time a reminder should be presented to the user.
  Stream<DateTime> get onDue => _due.stream;

  Timer? _timer;
  StreamSubscription<bool>? _micSub;
  Duration _interval = AppConfig.defaultInterval;
  bool _useExactHours = true;
  List<int> _exactHours = AppConfig.exactReminderHours;
  bool _respectMeetings = true;
  bool _pendingDeferred = false;
  DateTime? _nextDueAt;

  /// The wall-clock time the next reminder is scheduled for (for the UI).
  DateTime? get nextDueAt => _nextDueAt;

  /// Start (or restart) scheduling with the given [interval].
  void start({
    required Duration interval,
    required bool useExactHours,
    required List<int> exactHours,
    required bool respectMeetings,
  }) {
    _interval = interval;
    _useExactHours = useExactHours;
    _exactHours = _normalizeHours(exactHours);
    _respectMeetings = respectMeetings;

    _micSub ??= _micService.stream.listen(_onMicChanged);
    _armNextByPolicy();
    AppLogger.info(_useExactHours
        ? 'Scheduler started: exact hours ${_exactHours.join(', ')}.'
        : 'Scheduler started: every ${interval.inMinutes} min.');
  }

  /// Apply new settings without losing elapsed progress unnecessarily.
  void reconfigure({
    required Duration interval,
    required bool useExactHours,
    required List<int> exactHours,
    required bool respectMeetings,
  }) {
    final bool intervalChanged = interval != _interval;
    final bool policyChanged = useExactHours != _useExactHours ||
        _normalizeHours(exactHours).join(',') != _exactHours.join(',');
    _interval = interval;
    _useExactHours = useExactHours;
    _exactHours = _normalizeHours(exactHours);
    _respectMeetings = respectMeetings;
    if (intervalChanged || policyChanged) _armNextByPolicy();
  }

  /// Re-arm the timer for a fresh full interval (after Done / Skip).
  void scheduleNext() => _armNextByPolicy();

  /// Snooze: fire again after [duration].
  void snooze([Duration duration = AppConfig.snoozeDuration]) {
    _pendingDeferred = false;
    _armTimer(duration);
    AppLogger.info('Snoozed for ${duration.inMinutes} min.');
  }

  /// Force a reminder immediately (tray "Remind me now"), respecting meetings.
  void triggerNow() => _fireOrDefer();

  void _armTimer(Duration delay) {
    _timer?.cancel();
    _nextDueAt = DateTime.now().add(delay);
    _timer = Timer(delay, _fireOrDefer);
  }

  void _armNextByPolicy() {
    if (_useExactHours && _exactHours.isNotEmpty) {
      _armForNextExactHour();
    } else {
      _armTimer(_interval);
    }
  }

  void _armForNextExactHour() {
    final DateTime now = DateTime.now();
    DateTime? next;

    for (final int hour in _exactHours) {
      final DateTime candidate = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
      );
      if (candidate.isAfter(now)) {
        next = candidate;
        break;
      }
    }

    next ??= DateTime(
      now.year,
      now.month,
      now.day + 1,
      _exactHours.first,
    );

    _timer?.cancel();
    _nextDueAt = next;
    _timer = Timer(next.difference(now), _fireOrDefer);
  }

  List<int> _normalizeHours(List<int> hours) {
    final List<int> cleaned = hours
        .where((int h) => h >= 0 && h <= 23)
        .toSet()
        .toList()
      ..sort();
    return cleaned.isEmpty ? AppConfig.exactReminderHours : cleaned;
  }

  void _fireOrDefer() {
    if (_respectMeetings && _micService.isInUse) {
      _pendingDeferred = true;
      AppLogger.info('Reminder deferred — microphone in use.');
      return;
    }
    _emitDue();
  }

  void _onMicChanged(bool inUse) {
    if (inUse || !_pendingDeferred) return;
    // Mic just freed and we owe the user a reminder: wait a randomised
    // cool-down so we don't pounce the instant a call ends.
    _pendingDeferred = false;
    final Duration cooldown = _randomCooldown();
    AppLogger.info('Mic free — surfacing deferred reminder in '
        '${cooldown.inMinutes}m ${cooldown.inSeconds % 60}s.');
    _armTimer(cooldown);
  }

  Duration _randomCooldown() {
    final int minS = AppConfig.micCooldownMin.inSeconds;
    final int maxS = AppConfig.micCooldownMax.inSeconds;
    return Duration(seconds: minS + _random.nextInt(maxS - minS + 1));
  }

  void _emitDue() {
    final DateTime now = DateTime.now();
    if (!_due.isClosed) _due.add(now);
  }

  Future<void> dispose() async {
    _timer?.cancel();
    await _micSub?.cancel();
    await _due.close();
  }
}
