/// Centralized, configurable application metadata.
///
/// Rename the product by changing [appName] (and the `name:`/bundle ids in the
/// native projects). Everything user-facing reads from here.
class AppConfig {
  const AppConfig._();

  /// Display name shown in UI, notifications, tray tooltip and window title.
  /// Change this single value to rebrand the application.
  static const String appName = 'TKK EyeGuard';

  /// Short tagline used in the about dialog and notifications.
  static const String tagline = 'Healthy eyes, every hour.';

  /// Reverse-DNS identifier used for storage namespacing.
  static const String appId = 'com.techiekrishnakayaking.eyeguard';

  /// Hive box names.
  static const String settingsBox = 'eyeguard_settings';
  static const String historyBox = 'eyeguard_history';

  /// Default reminder cadence.
  static const Duration defaultInterval = Duration(minutes: 60);

  /// Allowed reminder intervals (minutes) surfaced in Settings.
  static const List<int> selectableIntervalsMinutes = <int>[30, 45, 60, 90, 120];

  /// After the microphone is released, wait inside this window (inclusive)
  /// before resurfacing a deferred reminder so we never interrupt the tail of
  /// a call.
  static const Duration micCooldownMin = Duration(minutes: 2);
  static const Duration micCooldownMax = Duration(minutes: 5);

  /// Default snooze duration.
  static const Duration snoozeDuration = Duration(minutes: 5);

  /// Duration of the guided eye-exercise routine.
  static const Duration exerciseDuration = Duration(seconds: 30);
}
