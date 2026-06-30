import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/services/autostart_service.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

/// MVVM view-model for the Settings screen. Owns the persisted [AppSettings]
/// and keeps side-effecting services (autostart, scheduler) in sync.
class SettingsController extends StateNotifier<AppSettings> {
  SettingsController(this._repository, this._autostart, this._ref)
      : super(_repository.load());

  final SettingsRepository _repository;
  final AutostartService _autostart;
  final Ref _ref;

  Future<void> setInterval(int minutes) async {
    if (!AppConfig.selectableIntervalsMinutes.contains(minutes)) return;
    await _persist(state.copyWith(intervalMinutes: minutes));
    _ref.read(reminderSchedulerProvider).reconfigure(
          interval: Duration(minutes: minutes),
          respectMeetings: state.respectMeetingDetection,
        );
  }

  Future<void> setLaunchAtStartup(bool value) async {
    final bool effective = await _autostart.setEnabled(value);
    await _persist(state.copyWith(launchAtStartup: effective));
  }

  Future<void> setNotificationSound(bool value) =>
      _persist(state.copyWith(notificationSound: value));

  Future<void> setRespectMeetingDetection(bool value) async {
    await _persist(state.copyWith(respectMeetingDetection: value));
    _ref.read(reminderSchedulerProvider).reconfigure(
          interval: Duration(minutes: state.intervalMinutes),
          respectMeetings: value,
        );
  }

  Future<void> setThemeMode(AppThemeMode mode) =>
      _persist(state.copyWith(themeMode: mode));

  Future<void> setLanguage(String code) =>
      _persist(state.copyWith(languageCode: code));

  Future<void> resetToDefaults() async {
    state = await _repository.reset();
  }

  Map<String, dynamic> exportSettings() => _repository.export();

  Future<void> importSettings(Map<String, dynamic> data) async {
    state = await _repository.import(data);
  }

  Future<void> _persist(AppSettings next) async {
    state = await _repository.save(next);
  }
}

final StateNotifierProvider<SettingsController, AppSettings>
    settingsControllerProvider =
    StateNotifierProvider<SettingsController, AppSettings>(
  (Ref ref) => SettingsController(
    ref.watch(settingsRepositoryProvider),
    ref.watch(autostartServiceProvider),
    ref,
  ),
);
