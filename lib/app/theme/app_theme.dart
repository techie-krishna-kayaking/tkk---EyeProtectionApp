import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Material 3 light & dark themes with a single shared shape language so the
/// UI stays consistent across desktop and mobile.
class AppTheme {
  const AppTheme._();

  static const String _fontFamily = 'Inter';
  static const double _radius = 18;

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: isDark ? AppColors.primaryDark : AppColors.primary,
      secondary: isDark ? AppColors.accentDark : AppColors.accent,
      surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      error: AppColors.danger,
    );

    final Color background =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final Color textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final Color mutedText =
        isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: _fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        foregroundColor: textColor,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        ),
      ),
      textTheme: _textTheme(textColor, mutedText),
      dividerTheme: DividerThemeData(
        color: (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
            .withValues(alpha: 0.12),
        thickness: 1,
      ),
    );
  }

  static TextTheme _textTheme(Color text, Color muted) {
    return TextTheme(
      displaySmall: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 32,
        color: text,
      ),
      headlineMedium: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 24,
        color: text,
      ),
      titleLarge: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: text,
      ),
      bodyLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 15,
        color: text,
      ),
      bodyMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        color: muted,
      ),
      labelLarge: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: text,
      ),
    );
  }
}
