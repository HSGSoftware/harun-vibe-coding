import 'package:flutter/material.dart';

/// Accent color locked by plan.md §0: #5468FF on Material 3 dark-first scheme.
class AppColors {
  const AppColors._();

  static const Color accent = Color(0xFF5468FF);
  static const Color accentDim = Color(0xFF3B4BD1);
  static const Color danger = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  static const Color magenta = Color(0xFFEC4899);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color cyan = Color(0xFF22D3EE);

  static const Color bgDark = Color(0xFF0F1115);
  static const Color bgAmoled = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF171A21);
  static const Color surfaceDark2 = Color(0xFF1F2430);
  static const Color onSurfaceDark = Color(0xFFE6E7EA);
  static const Color onSurfaceDim = Color(0xFF9BA1A9);
  static const Color borderDark = Color(0xFF2A2F3B);
}

ColorScheme darkScheme({Color accent = AppColors.accent, bool amoled = false}) {
  return ColorScheme(
    brightness: Brightness.dark,
    primary: accent,
    onPrimary: Colors.white,
    primaryContainer: AppColors.accentDim,
    onPrimaryContainer: Colors.white,
    secondary: AppColors.purple,
    onSecondary: Colors.white,
    error: AppColors.danger,
    onError: Colors.white,
    surface: amoled ? AppColors.bgAmoled : AppColors.surfaceDark,
    onSurface: AppColors.onSurfaceDark,
    surfaceContainerHighest: AppColors.surfaceDark2,
    surfaceContainer: AppColors.surfaceDark2,
    outline: AppColors.borderDark,
    outlineVariant: AppColors.borderDark,
  );
}

ColorScheme lightScheme({Color accent = AppColors.accent}) {
  return ColorScheme.fromSeed(seedColor: accent, brightness: Brightness.light);
}
