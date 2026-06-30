import 'app_config.dart';

/// Static, localizable copy for reminders and the exercise routine.
class ReminderMessages {
  const ReminderMessages._();

  static const String notificationTitle = '👀 Eye Exercise Time';

  static const String notificationBody =
      'Take just 30 seconds.\n'
      '✅ Look 20 feet away.\n'
      '✅ Blink your eyes 20 times.\n'
      '✅ Roll your eyes clockwise.\n'
      '✅ Roll your eyes anti-clockwise.\n'
      '✅ Relax.';

  /// Ordered steps rendered on the guided exercise screen.
  static const List<ExerciseStep> steps = <ExerciseStep>[
    ExerciseStep(
      title: 'Look Far Away',
      instruction: 'Focus on something at least 20 feet away.',
      seconds: 6,
    ),
    ExerciseStep(
      title: 'Blink Gently',
      instruction: 'Blink slowly 20 times to refresh your tear film.',
      seconds: 6,
    ),
    ExerciseStep(
      title: 'Roll Clockwise',
      instruction: 'Roll your eyes slowly in a clockwise circle.',
      seconds: 6,
    ),
    ExerciseStep(
      title: 'Roll Anti-clockwise',
      instruction: 'Now reverse — roll your eyes anti-clockwise.',
      seconds: 6,
    ),
    ExerciseStep(
      title: 'Relax & Breathe',
      instruction: 'Close your eyes and take a slow, deep breath.',
      seconds: 6,
    ),
  ];

  /// Convenience getter so the UI never hardcodes the brand name.
  static String get appName => AppConfig.appName;

  static String softHourTitle(DateTime when) {
    return 'Gentle reminder • ${_hourLabel(when)}';
  }

  static String softHourBody(DateTime when) {
    return 'It is ${_hourLabel(when)}.\nTake a soft 30-second eye break.';
  }

  static String _hourLabel(DateTime when) {
    final String h = when.hour.toString().padLeft(2, '0');
    return '$h:00';
  }
}

/// A single step inside the guided routine.
class ExerciseStep {
  const ExerciseStep({
    required this.title,
    required this.instruction,
    required this.seconds,
  });

  final String title;
  final String instruction;
  final int seconds;
}
