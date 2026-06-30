import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../core/services/autostart_service.dart';
import '../../core/services/microphone_activity_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/tray_service.dart';
import '../../features/dashboard/domain/usecases/calculate_stats.dart';
import '../../features/reminder/data/models/reminder_event_model.dart';
import '../../features/reminder/data/repositories/reminder_repository_impl.dart';
import '../../features/reminder/domain/repositories/reminder_repository.dart';
import '../../features/reminder/presentation/scheduler/reminder_scheduler.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';

/// Hive boxes are opened during bootstrap and injected here via overrides.
final Provider<Box<dynamic>> settingsBoxProvider = Provider<Box<dynamic>>(
  (Ref ref) => throw UnimplementedError('settingsBoxProvider must be overridden'),
);

final Provider<Box<ReminderEventModel>> historyBoxProvider =
    Provider<Box<ReminderEventModel>>(
  (Ref ref) => throw UnimplementedError('historyBoxProvider must be overridden'),
);

// ---------------------------------------------------------------------------
// Repositories
// ---------------------------------------------------------------------------

final Provider<SettingsRepository> settingsRepositoryProvider =
    Provider<SettingsRepository>(
  (Ref ref) => SettingsRepositoryImpl(ref.watch(settingsBoxProvider)),
);

final Provider<ReminderRepository> reminderRepositoryProvider =
    Provider<ReminderRepository>(
  (Ref ref) => ReminderRepositoryImpl(ref.watch(historyBoxProvider)),
);

// ---------------------------------------------------------------------------
// Services (singletons disposed with the container)
// ---------------------------------------------------------------------------

final Provider<NotificationService> notificationServiceProvider =
    Provider<NotificationService>((Ref ref) {
  final NotificationService service = NotificationService();
  ref.onDispose(service.dispose);
  return service;
});

final Provider<MicrophoneActivityService> microphoneServiceProvider =
    Provider<MicrophoneActivityService>((Ref ref) {
  final MicrophoneActivityService service = MicrophoneActivityService();
  ref.onDispose(service.dispose);
  return service;
});

final Provider<AutostartService> autostartServiceProvider =
    Provider<AutostartService>((Ref ref) => AutostartService());

final Provider<TrayService> trayServiceProvider =
    Provider<TrayService>((Ref ref) {
  final TrayService service = TrayService();
  ref.onDispose(service.dispose);
  return service;
});

final Provider<ReminderScheduler> reminderSchedulerProvider =
    Provider<ReminderScheduler>((Ref ref) {
  final ReminderScheduler scheduler = ReminderScheduler(
    micService: ref.watch(microphoneServiceProvider),
  );
  ref.onDispose(scheduler.dispose);
  return scheduler;
});

// ---------------------------------------------------------------------------
// Use cases
// ---------------------------------------------------------------------------

final Provider<CalculateStats> calculateStatsProvider =
    Provider<CalculateStats>((Ref ref) => const CalculateStats());
