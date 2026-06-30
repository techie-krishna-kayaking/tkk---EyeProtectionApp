import 'package:flutter/material.dart';

/// Brand palette. Apple-inspired, calm and low-strain for an eye-care app.
class AppColors {
  const AppColors._();

  // Brand
  static const Color primary = Color(0xFF3D7BFF);
  static const Color primaryDark = Color(0xFF6FA1FF);
  static const Color accent = Color(0xFF22C7A9);
  static const Color accentDark = Color(0xFF4FE0C6);

  // Light surfaces
  static const Color lightBackground = Color(0xFFF6F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFEEF2F9);
  static const Color lightText = Color(0xFF14181F);
  static const Color lightTextMuted = Color(0xFF5A6472);

  // Dark surfaces
  static const Color darkBackground = Color(0xFF0E1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkSurfaceMuted = Color(0xFF1F2630);
  static const Color darkText = Color(0xFFEDF1F7);
  static const Color darkTextMuted = Color(0xFF9AA6B6);

  // Semantic
  static const Color success = Color(0xFF2BB673);
  static const Color warning = Color(0xFFF5A623);
  static const Color danger = Color(0xFFE0526A);

  // Gradient used on the exercise / hero surfaces.
  static const List<Color> heroGradient = <Color>[
    Color(0xFF3D7BFF),
    Color(0xFF22C7A9),
  ];
}
