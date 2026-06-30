import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_config.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/tray_service.dart';
import '../../core/utils/logger.dart';
import '../../features/dashboard/presentation/controllers/dashboard_controller.dart';
import '../../features/reminder/domain/entities/reminder_event.dart';
import '../../features/reminder/presentation/scheduler/reminder_scheduler.dart';
import '../../features/settings/presentation/controllers/settings_controller.dart';
import 'providers.dart';

/// Orchestrates the runtime behaviour of the app by wiring the scheduler,
/// notifications, tray commands and history persistence together.
///
/// It owns no UI; the presentation layer listens to [onReminderDue] to show the
/// in-app exercise experience, while OS-level reminders go out via the
/// [NotificationService].
class AppCoordinator {
  AppCoordinator(this._ref);

  final Ref _ref;

  final StreamController<void> _reminderDue = StreamController<void>.broadcast();

  /// Fires when the user should be taken to the exercise screen.
  Stream<void> get onReminderDue => _reminderDue.stream;

  final List<StreamSubscription<dynamic>> _subs = <StreamSubscription<dynamic>>[];

  ReminderScheduler get _scheduler => _ref.read(reminderSchedulerProvider);
  NotificationService get _notifications =>
      _ref.read(notificationServiceProvider);

  /// Begin coordinating. Called once after services are initialised.
  void start() {
    final settings = _ref.read(settingsControllerProvider);

    _scheduler.start(
      interval: Duration(minutes: settings.intervalMinutes),
      respectMeetings: settings.respectMeetingDetection,
    );

    _subs.add(_scheduler.onDue.listen((_) => _handleDue()));
    _subs.add(_notifications.actions.listen(_handleNotificationAction));
    _subs.add(_ref.read(trayServiceProvider).commands.listen(_handleTray));

    AppLogger.info('AppCoordinator started.');
  }

  Future<void> _handleDue() async {
    final settings = _ref.read(settingsControllerProvider);
    await _notifications.showReminder(withSound: settings.notificationSound);
    if (!_reminderDue.isClosed) _reminderDue.add(null);
  }

  void _handleNotificationAction(NotificationAction action) {
    switch (action) {
      case NotificationAction.done:
        unawaited(recordOutcome(ReminderOutcome.completed));
      case NotificationAction.skip:
        unawaited(recordOutcome(ReminderOutcome.skipped));
      case NotificationAction.snooze:
        unawaited(recordOutcome(ReminderOutcome.snoozed, reschedule: false));
        _scheduler.snooze();
      case NotificationAction.open:
        unawaited(_ref.read(trayServiceProvider).showWindow());
        if (!_reminderDue.isClosed) _reminderDue.add(null);
    }
  }

  void _handleTray(TrayCommand command) {
    switch (command) {
      case TrayCommand.open:
      case TrayCommand.settings:
        unawaited(_ref.read(trayServiceProvider).showWindow());
      case TrayCommand.remindNow:
        _scheduler.triggerNow();
      case TrayCommand.snooze:
        _scheduler.snooze();
      case TrayCommand.quit:
        // Handled by the platform layer; nothing to persist here.
        break;
    }
  }

  /// Persist the chosen [outcome] and (optionally) arm the next reminder.
  Future<void> recordOutcome(
    ReminderOutcome outcome, {
    bool reschedule = true,
  }) async {
    final ReminderEvent event = ReminderEvent(
      id: _newId(),
      timestamp: DateTime.now(),
      outcome: outcome,
    );
    await _ref.read(reminderRepositoryProvider).record(event);
    _ref.read(dashboardControllerProvider.notifier).refresh();
    if (reschedule) _scheduler.scheduleNext();
  }

  /// Snooze the active reminder for the default duration.
  void snooze([Duration duration = AppConfig.snoozeDuration]) =>
      _scheduler.snooze(duration);

  String _newId() =>
      '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(1 << 20)}';

  Future<void> dispose() async {
    for (final StreamSubscription<dynamic> sub in _subs) {
      await sub.cancel();
    }
    await _reminderDue.close();
  }
}

final Provider<AppCoordinator> appCoordinatorProvider =
    Provider<AppCoordinator>((Ref ref) {
  final AppCoordinator coordinator = AppCoordinator(ref);
  ref.onDispose(coordinator.dispose);
  return coordinator;
});
