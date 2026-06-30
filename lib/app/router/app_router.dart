import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/exercise/presentation/screens/exercise_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../shell/home_shell.dart';

/// Centralised navigation graph. A [ShellRoute] hosts the persistent sidebar /
/// bottom navigation, while the exercise screen is pushed full-screen on top.
class AppRouter {
  const AppRouter._();

  static const String dashboard = '/';
  static const String settings = '/settings';
  static const String exercise = '/exercise';

  static GoRouter build() {
    return GoRouter(
      initialLocation: dashboard,
      routes: <RouteBase>[
        ShellRoute(
          builder: (context, state, child) => HomeShell(child: child),
          routes: <RouteBase>[
            GoRoute(
              path: dashboard,
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: settings,
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
        GoRoute(
          path: exercise,
          pageBuilder: (context, state) => const NoTransitionPage<void>(
            child: ExerciseScreen(),
          ),
        ),
      ],
    );
  }
}
