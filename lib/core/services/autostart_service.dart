import 'dart:io' show Platform;

import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../constants/app_config.dart';
import '../utils/logger.dart';
import '../utils/platform_info.dart';

/// Manages "Start at login" on desktop platforms (Windows & macOS).
///
/// On Android, boot-time restart is handled by a native `BOOT_COMPLETED`
/// receiver; on iOS the OS does not permit launch-at-login, so this is a no-op
/// there (documented behaviour).
class AutostartService {
  bool _configured = false;

  Future<void> _ensureConfigured() async {
    if (_configured || !PlatformInfo.isDesktop) return;
    final PackageInfo info = await PackageInfo.fromPlatform();
    launchAtStartup.setup(
      appName: info.appName.isNotEmpty ? info.appName : AppConfig.appName,
      appPath: Platform.resolvedExecutable,
      packageName: AppConfig.appId,
    );
    _configured = true;
  }

  /// Enable or disable launch-at-login. Returns the effective state.
  Future<bool> setEnabled(bool enabled) async {
    if (!PlatformInfo.isDesktop) return false;
    try {
      await _ensureConfigured();
      if (enabled) {
        await launchAtStartup.enable();
      } else {
        await launchAtStartup.disable();
      }
      return enabled;
    } catch (e) {
      AppLogger.warning('Failed to update launch-at-startup: $e');
      return !enabled;
    }
  }

  /// Whether the app is currently registered to launch at login.
  Future<bool> isEnabled() async {
    if (!PlatformInfo.isDesktop) return false;
    try {
      await _ensureConfigured();
      return launchAtStartup.isEnabled();
    } catch (_) {
      return false;
    }
  }
}
