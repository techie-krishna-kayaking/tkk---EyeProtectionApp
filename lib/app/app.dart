import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_config.dart';
import '../features/settings/domain/entities/app_settings.dart';
import '../features/settings/presentation/controllers/settings_controller.dart';
import 'di/app_coordinator.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Root widget. Owns the [GoRouter], applies the themed [MaterialApp] and
/// bridges coordinator "reminder due" events into navigation.
class EyeGuardApp extends ConsumerStatefulWidget {
  const EyeGuardApp({super.key});

  @override
  ConsumerState<EyeGuardApp> createState() => _EyeGuardAppState();
}

class _EyeGuardAppState extends ConsumerState<EyeGuardApp> {
  late final GoRouter _router = AppRouter.build();
  StreamSubscription<void>? _dueSub;

  @override
  void initState() {
    super.initState();
    // Navigate to the guided exercise whenever a reminder becomes due.
    _dueSub = ref.read(appCoordinatorProvider).onReminderDue.listen((_) {
      if (mounted) _router.push(AppRouter.exercise);
    });
  }

  @override
  void dispose() {
    _dueSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppThemeMode mode =
        ref.watch(settingsControllerProvider.select((s) => s.themeMode));

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _toMaterial(mode),
      routerConfig: _router,
    );
  }

  ThemeMode _toMaterial(AppThemeMode mode) => switch (mode) {
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
        AppThemeMode.system => ThemeMode.system,
      };
}
