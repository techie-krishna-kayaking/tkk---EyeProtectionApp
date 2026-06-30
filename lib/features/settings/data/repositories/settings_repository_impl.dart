import 'package:hive/hive.dart';

import '../../../../core/constants/app_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

/// Hive-backed [SettingsRepository]. Stores primitives directly in a typed box
/// so no custom adapter is required.
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._box);

  final Box<dynamic> _box;

  static const String _kInterval = 'interval_minutes';
  static const String _kStartup = 'launch_at_startup';
  static const String _kSound = 'notification_sound';
  static const String _kMeeting = 'respect_meeting_detection';
  static const String _kTheme = 'theme_mode';
  static const String _kLanguage = 'language_code';

  @override
  AppSettings load() {
    return AppSettings(
      intervalMinutes: _box.get(_kInterval,
          defaultValue: AppConfig.defaultInterval.inMinutes) as int,
      launchAtStartup: _box.get(_kStartup, defaultValue: true) as bool,
      notificationSound: _box.get(_kSound, defaultValue: true) as bool,
      respectMeetingDetection:
          _box.get(_kMeeting, defaultValue: true) as bool,
      themeMode: AppThemeMode.values[
          _box.get(_kTheme, defaultValue: AppThemeMode.system.index) as int],
      languageCode: _box.get(_kLanguage, defaultValue: 'en') as String,
    );
  }

  @override
  Future<AppSettings> save(AppSettings settings) async {
    try {
      await _box.putAll(<String, dynamic>{
        _kInterval: settings.intervalMinutes,
        _kStartup: settings.launchAtStartup,
        _kSound: settings.notificationSound,
        _kMeeting: settings.respectMeetingDetection,
        _kTheme: settings.themeMode.index,
        _kLanguage: settings.languageCode,
      });
      return settings;
    } catch (e) {
      throw StorageException('Failed to persist settings: $e');
    }
  }

  @override
  Future<AppSettings> reset() async {
    await _box.clear();
    return load();
  }

  @override
  Map<String, dynamic> export() {
    final AppSettings s = load();
    return <String, dynamic>{
      'version': 1,
      _kInterval: s.intervalMinutes,
      _kStartup: s.launchAtStartup,
      _kSound: s.notificationSound,
      _kMeeting: s.respectMeetingDetection,
      _kTheme: s.themeMode.index,
      _kLanguage: s.languageCode,
    };
  }

  @override
  Future<AppSettings> import(Map<String, dynamic> data) async {
    final AppSettings current = load();
    final AppSettings merged = current.copyWith(
      intervalMinutes: data[_kInterval] as int?,
      launchAtStartup: data[_kStartup] as bool?,
      notificationSound: data[_kSound] as bool?,
      respectMeetingDetection: data[_kMeeting] as bool?,
      themeMode: data[_kTheme] is int
          ? AppThemeMode.values[data[_kTheme] as int]
          : null,
      languageCode: data[_kLanguage] as String?,
    );
    return save(merged);
  }
}
