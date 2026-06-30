import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// A lightweight, fully custom-painted eye that blinks and rolls — no image or
/// Lottie asset required, keeping the binary small and the animation cheap.
class AnimatedEye extends StatelessWidget {
  const AnimatedEye({
    required this.controller,
    required this.mode,
    this.size = 180,
    super.key,
  });

  final AnimationController controller;
  final EyeMode mode;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, _) {
        return CustomPaint(
          size: Size.square(size),
          painter: _EyePainter(progress: controller.value, mode: mode),
        );
      },
    );
  }
}

/// The visual behaviour the eye should perform for the current step.
enum EyeMode { gaze, blink, rollClockwise, rollAntiClockwise, breathe }

class _EyePainter extends CustomPainter {
  _EyePainter({required this.progress, required this.mode});

  final double progress;
  final EyeMode mode;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double w = size.width;
    final double h = size.height;

    final Paint sclera = Paint()..color = Colors.white;
    final Paint outline = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    // Eyelid openness: full for most modes, oscillates for blink.
    double openness = 1;
    if (mode == EyeMode.blink) {
      openness = (math.sin(progress * math.pi * 6).abs()).clamp(0.08, 1.0);
    } else if (mode == EyeMode.breathe) {
      openness = 0.55 + 0.45 * (0.5 + 0.5 * math.sin(progress * math.pi * 2));
    }

    final double eyeHeight = h * 0.5 * openness;
    final Rect eyeRect = Rect.fromCenter(
      center: center,
      width: w * 0.9,
      height: eyeHeight,
    );

    // Almond-shaped eye via two arcs.
    final Path eye = Path()
      ..moveTo(eyeRect.left, center.dy)
      ..quadraticBezierTo(center.dx, eyeRect.top, eyeRect.right, center.dy)
      ..quadraticBezierTo(center.dx, eyeRect.bottom, eyeRect.left, center.dy)
      ..close();

    canvas.drawPath(eye, sclera);
    canvas.save();
    canvas.clipPath(eye);

    // Iris position for rolling modes.
    Offset pupil = center;
    final double radius = w * 0.18;
    if (mode == EyeMode.rollClockwise || mode == EyeMode.rollAntiClockwise) {
      final double dir = mode == EyeMode.rollClockwise ? 1 : -1;
      final double angle = dir * progress * math.pi * 2;
      pupil = center +
          Offset(math.cos(angle), math.sin(angle)) * (w * 0.22);
    }

    canvas.drawCircle(
      pupil,
      radius,
      Paint()..color = AppColors.primary.withValues(alpha: 0.85),
    );
    canvas.drawCircle(pupil, radius * 0.45, Paint()..color = Colors.black87);
    canvas.drawCircle(
      pupil.translate(-radius * 0.3, -radius * 0.3),
      radius * 0.18,
      Paint()..color = Colors.white,
    );
    canvas.restore();

    canvas.drawPath(eye, outline);
  }

  @override
  bool shouldRepaint(_EyePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.mode != mode;
}
