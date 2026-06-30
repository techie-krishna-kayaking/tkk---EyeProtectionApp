import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'app/app.dart';
import 'app/di/app_coordinator.dart';
import 'app/di/providers.dart';
import 'core/constants/app_config.dart';
import 'core/services/notification_service.dart';
import 'core/utils/logger.dart';
import 'core/utils/platform_info.dart';
import 'features/reminder/data/models/reminder_event_model.dart';
import 'features/settings/presentation/controllers/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.init();

  await _configureDesktopWindow();

  // --- Local storage --------------------------------------------------------
  await Hive.initFlutter();
  Hive.registerAdapter(ReminderEventAdapter());
  final Box<dynamic> settingsBox = await Hive.openBox<dynamic>(
    AppConfig.settingsBox,
  );
  final Box<ReminderEventModel> historyBox =
      await Hive.openBox<ReminderEventModel>(AppConfig.historyBox);

  // --- Dependency injection container --------------------------------------
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      settingsBoxProvider.overrideWithValue(settingsBox),
      historyBoxProvider.overrideWithValue(historyBox),
    ],
  );

  await _initServices(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const EyeGuardApp(),
    ),
  );
}

/// Set up the desktop window: compact default size, hidden from the taskbar
/// when minimised to tray, and a native title bar.
Future<void> _configureDesktopWindow() async {
  if (!PlatformInfo.isDesktop) return;
  await windowManager.ensureInitialized();
  const WindowOptions options = WindowOptions(
    size: Size(420, 720),
    minimumSize: Size(380, 600),
    center: true,
    title: AppConfig.appName,
    titleBarStyle: TitleBarStyle.normal,
  );
  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

/// Initialise platform services and start the runtime coordinator.
Future<void> _initServices(ProviderContainer container) async {
  final NotificationService notifications =
      container.read(notificationServiceProvider);
  await notifications.init();
  await notifications.requestPermissions();

  await container.read(microphoneServiceProvider).start();

  if (PlatformInfo.supportsTray) {
    await container.read(trayServiceProvider).init();
  }

  // Reflect the persisted "start at login" preference on the OS.
  final bool startup =
      container.read(settingsControllerProvider).launchAtStartup;
  await container.read(autostartServiceProvider).setEnabled(startup);

  container.read(appCoordinatorProvider).start();
  AppLogger.info('${AppConfig.appName} ready.');
}
