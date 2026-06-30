import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/app_coordinator.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/reminder_messages.dart';
import '../../../reminder/domain/entities/reminder_event.dart';
import '../widgets/animated_eye.dart';
import '../widgets/progress_ring.dart';

/// The guided 30-second eye-exercise experience with step-by-step animations,
/// a countdown ring and a completion celebration.
class ExerciseScreen extends ConsumerStatefulWidget {
  const ExerciseScreen({super.key});

  @override
  ConsumerState<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends ConsumerState<ExerciseScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _eyeController;
  Timer? _ticker;

  int _stepIndex = 0;
  int _secondsLeftInStep = 0;
  int _totalElapsed = 0;
  bool _completed = false;

  List<ExerciseStep> get _steps => ReminderMessages.steps;
  int get _totalSeconds =>
      _steps.fold<int>(0, (int sum, ExerciseStep s) => sum + s.seconds);

  @override
  void initState() {
    super.initState();
    _eyeController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
    _beginStep(0);
    _ticker = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void _beginStep(int index) {
    _stepIndex = index;
    _secondsLeftInStep = _steps[index].seconds;
  }

  void _onTick(Timer timer) {
    if (!mounted) return;
    setState(() {
      _secondsLeftInStep--;
      _totalElapsed++;
      if (_secondsLeftInStep <= 0) {
        if (_stepIndex < _steps.length - 1) {
          _beginStep(_stepIndex + 1);
        } else {
          _finish();
        }
      }
    });
  }

  EyeMode _modeFor(int index) => switch (index) {
        0 => EyeMode.gaze,
        1 => EyeMode.blink,
        2 => EyeMode.rollClockwise,
        3 => EyeMode.rollAntiClockwise,
        _ => EyeMode.breathe,
      };

  Future<void> _finish() async {
    _ticker?.cancel();
    setState(() => _completed = true);
    await ref
        .read(appCoordinatorProvider)
        .recordOutcome(ReminderOutcome.completed);
  }

  Future<void> _skip() async {
    _ticker?.cancel();
    await ref
        .read(appCoordinatorProvider)
        .recordOutcome(ReminderOutcome.skipped);
    if (mounted) _close();
  }

  void _snooze() {
    _ticker?.cancel();
    ref.read(appCoordinatorProvider).snooze();
    _close();
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _eyeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.heroGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: _completed ? _buildCompletion() : _buildExercise(),
          ),
        ),
      ),
    );
  }

  Widget _buildExercise() {
    final ExerciseStep step = _steps[_stepIndex];
    final double progress = _totalElapsed / _totalSeconds;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            ReminderMessages.notificationTitle,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 32),
          AnimatedEye(controller: _eyeController, mode: _modeFor(_stepIndex)),
          const SizedBox(height: 36),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: Column(
              key: ValueKey<int>(_stepIndex),
              children: <Widget>[
                Text(
                  step.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  step.instruction,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          ProgressRing(
            progress: progress,
            label: '$_secondsLeftInStep',
            color: Colors.white,
          ),
          const SizedBox(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                onPressed: _snooze,
                child: const Text(
                  'Snooze 5 min',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: _skip,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Skip'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletion() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.6, end: 1),
            duration: const Duration(milliseconds: 450),
            curve: Curves.elasticOut,
            builder: (BuildContext context, double scale, Widget? child) =>
                Transform.scale(scale: scale, child: child),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 110,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Great job!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your eyes thank you. See you in a bit!',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 36),
          FilledButton(
            onPressed: _close,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
