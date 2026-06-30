import '../entities/app_settings.dart';

/// Contract for reading and persisting user [AppSettings].
abstract interface class SettingsRepository {
  /// Returns the current settings, falling back to sane defaults.
  AppSettings load();

  /// Persists [settings] and returns the saved value.
  Future<AppSettings> save(AppSettings settings);

  /// Restores defaults.
  Future<AppSettings> reset();

  /// Serialises settings for the Export feature.
  Map<String, dynamic> export();

  /// Applies a previously exported map (Import / Restore feature).
  Future<AppSettings> import(Map<String, dynamic> data);
}
