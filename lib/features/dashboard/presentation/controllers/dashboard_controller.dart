import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../reminder/domain/entities/reminder_event.dart';
import '../../domain/entities/dashboard_stats.dart';

/// Notifier that recomputes [DashboardStats] from reminder history on demand.
class DashboardController extends StateNotifier<DashboardStats> {
  DashboardController(this._ref) : super(DashboardStats.empty) {
    refresh();
  }

  final Ref _ref;

  /// Recompute statistics from the current history snapshot.
  void refresh() {
    final List<ReminderEvent> events =
        _ref.read(reminderRepositoryProvider).all();
    state = _ref.read(calculateStatsProvider)(events);
  }
}

final StateNotifierProvider<DashboardController, DashboardStats>
    dashboardControllerProvider =
    StateNotifierProvider<DashboardController, DashboardStats>(
  (Ref ref) => DashboardController(ref),
);
