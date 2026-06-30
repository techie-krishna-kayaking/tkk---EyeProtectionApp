import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Small, testable surface for platform capability checks so feature code never
/// branches on `Platform` directly.
class PlatformInfo {
  const PlatformInfo._();

  static bool get isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// True where a system tray / menu-bar icon is supported.
  static bool get supportsTray => isDesktop;

  /// True where active microphone usage can be reliably observed without
  /// requesting recording permission from the user.
  static bool get supportsMicDetection => isWindows || isMacOS;
}
