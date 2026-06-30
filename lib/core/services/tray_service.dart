import 'dart:async';
import 'dart:io';

import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../constants/app_config.dart';
import '../utils/logger.dart';
import '../utils/platform_info.dart';

/// Commands raised from the tray / menu-bar menu.
enum TrayCommand { open, remindNow, snooze, settings, quit }

/// Manages the desktop system-tray (Windows) / menu-bar (macOS) presence and
/// keeps the app running silently in the background when its window is closed.
class TrayService with TrayListener, WindowListener {
  final StreamController<TrayCommand> _commands =
      StreamController<TrayCommand>.broadcast();

  Stream<TrayCommand> get commands => _commands.stream;

  /// Set up the tray icon, context menu and "hide instead of quit" behaviour.
  Future<void> init() async {
    if (!PlatformInfo.supportsTray) return;

    trayManager.addListener(this);
    windowManager.addListener(this);
    await windowManager.setPreventClose(true);

    final String iconPath = Platform.isWindows
        ? 'assets/icons/tray_icon.ico'
        : 'assets/icons/tray_icon.png';

    try {
      await trayManager.setIcon(iconPath);
      await trayManager.setToolTip(AppConfig.appName);
      await _buildMenu();
    } catch (e) {
      AppLogger.warning('Tray initialisation failed: $e');
    }
  }

  Future<void> _buildMenu() async {
    await trayManager.setContextMenu(
      Menu(
        items: <MenuItem>[
          MenuItem(key: 'open', label: 'Open ${AppConfig.appName}'),
          MenuItem.separator(),
          MenuItem(key: 'remind_now', label: 'Remind me now'),
          MenuItem(key: 'snooze', label: 'Snooze 5 minutes'),
          MenuItem.separator(),
          MenuItem(key: 'settings', label: 'Settings'),
          MenuItem(key: 'quit', label: 'Quit'),
        ],
      ),
    );
  }

  @override
  void onTrayIconMouseDown() {
    unawaited(trayManager.popUpContextMenu());
  }

  @override
  void onTrayIconRightMouseDown() {
    unawaited(trayManager.popUpContextMenu());
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    final TrayCommand? command = switch (menuItem.key) {
      'open' => TrayCommand.open,
      'remind_now' => TrayCommand.remindNow,
      'snooze' => TrayCommand.snooze,
      'settings' => TrayCommand.settings,
      'quit' => TrayCommand.quit,
      _ => null,
    };
    if (command != null && !_commands.isClosed) _commands.add(command);
  }

  /// Hide to tray instead of terminating when the user closes the window.
  @override
  void onWindowClose() async {
    final bool prevent = await windowManager.isPreventClose();
    if (prevent) {
      await windowManager.hide();
    }
  }

  Future<void> showWindow() async {
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> dispose() async {
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    await _commands.close();
  }
}
