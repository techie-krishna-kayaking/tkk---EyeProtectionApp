import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../constants/app_config.dart';
import '../constants/reminder_messages.dart';
import '../utils/logger.dart';

/// Identifiers carried back when the user taps a notification action.
enum NotificationAction { open, done, snooze, skip }

/// Wraps `flutter_local_notifications` to present the hourly reminder as a
/// native, sound-respecting notification with Done / Snooze / Skip actions.
class NotificationService {
  NotificationService([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const int _reminderId = 1001;
  static const String _channelId = 'eyeguard_reminders';
  static const String _channelName = 'Eye Exercise Reminders';

  final StreamController<NotificationAction> _actions =
      StreamController<NotificationAction>.broadcast();

  /// Emits whenever the user interacts with a reminder notification.
  Stream<NotificationAction> get actions => _actions.stream;

  /// Initialise platform plugins and request permission where required.
  Future<void> init() async {
    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings darwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: false,
      notificationCategories: <DarwinNotificationCategory>[
        DarwinNotificationCategory(
          'eyeguard_reminder',
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain('done', 'Done'),
            DarwinNotificationAction.plain('snooze', 'Snooze 5 min'),
            DarwinNotificationAction.plain('skip', 'Skip'),
          ],
          options: <DarwinNotificationCategoryOption>{
            DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
          },
        ),
      ],
    );
    const LinuxInitializationSettings linux =
        LinuxInitializationSettings(defaultActionName: 'Open');

    final InitializationSettings settings = InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
      linux: linux,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onResponse,
    );
    AppLogger.info('NotificationService initialised.');
  }

  /// Ask the OS for notification permission (Android 13+, iOS, macOS).
  Future<bool> requestPermissions() async {
    final bool? android = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    final bool? ios = await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, sound: true);
    final bool? macos = await _plugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, sound: true);
    return android ?? ios ?? macos ?? true;
  }

  /// Show the hourly reminder. [withSound] honours the user's preference and
  /// the OS Focus / Do-Not-Disturb state (handled natively by the channel).
  Future<void> showReminder({required bool withSound}) async {
    final AndroidNotificationDetails android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Gentle hourly prompts to rest your eyes.',
      importance: Importance.high,
      priority: Priority.high,
      playSound: withSound,
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction('done', 'Done'),
        AndroidNotificationAction('snooze', 'Snooze 5 min'),
        AndroidNotificationAction('skip', 'Skip'),
      ],
    );
    final DarwinNotificationDetails darwin = DarwinNotificationDetails(
      presentSound: withSound,
      categoryIdentifier: 'eyeguard_reminder',
    );

    await _plugin.show(
      _reminderId,
      ReminderMessages.notificationTitle,
      '${AppConfig.appName} • ${ReminderMessages.notificationBody}',
      NotificationDetails(android: android, iOS: darwin, macOS: darwin),
    );
  }

  void _onResponse(NotificationResponse response) {
    final NotificationAction action = switch (response.actionId) {
      'done' => NotificationAction.done,
      'snooze' => NotificationAction.snooze,
      'skip' => NotificationAction.skip,
      _ => NotificationAction.open,
    };
    if (!_actions.isClosed) _actions.add(action);
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  Future<void> dispose() => _actions.close();
}
