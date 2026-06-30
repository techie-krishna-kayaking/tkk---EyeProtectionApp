import 'package:equatable/equatable.dart';

/// How the app should follow the system / user theme preference.
enum AppThemeMode { system, light, dark }

/// Immutable user preferences. Persisted via the settings repository.
class AppSettings extends Equatable {
  const AppSettings({
    this.intervalMinutes = 60,
    this.launchAtStartup = true,
    this.notificationSound = true,
    this.respectMeetingDetection = true,
    this.themeMode = AppThemeMode.system,
    this.languageCode = 'en',
  });

  /// Reminder cadence in minutes (one of [AppConfig.selectableIntervalsMinutes]).
  final int intervalMinutes;

  /// Whether the app starts when the user logs in.
  final bool launchAtStartup;

  /// Play a sound with the reminder notification.
  final bool notificationSound;

  /// Suppress reminders while the microphone is in use.
  final bool respectMeetingDetection;

  final AppThemeMode themeMode;
  final String languageCode;

  AppSettings copyWith({
    int? intervalMinutes,
    bool? launchAtStartup,
    bool? notificationSound,
    bool? respectMeetingDetection,
    AppThemeMode? themeMode,
    String? languageCode,
  }) {
    return AppSettings(
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      launchAtStartup: launchAtStartup ?? this.launchAtStartup,
      notificationSound: notificationSound ?? this.notificationSound,
      respectMeetingDetection:
          respectMeetingDetection ?? this.respectMeetingDetection,
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        intervalMinutes,
        launchAtStartup,
        notificationSound,
        respectMeetingDetection,
        themeMode,
        languageCode,
      ];
}
