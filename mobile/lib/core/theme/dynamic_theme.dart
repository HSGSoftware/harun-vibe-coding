import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_theme.dart';
import 'color_schemes.dart';

/// Theme mode options exposed in settings.
enum AppThemeMode { system, dark, amoled, light }

/// Current theme selection (mode + accent).
class ThemeSelection {
  const ThemeSelection({this.mode = AppThemeMode.system, this.accent = AppColors.accent});
  final AppThemeMode mode;
  final Color accent;

  ThemeSelection copyWith({AppThemeMode? mode, Color? accent}) {
    return ThemeSelection(mode: mode ?? this.mode, accent: accent ?? this.accent);
  }

  ThemeData buildDarkVariant() {
    return AppTheme.dark(accent: accent, amoled: mode == AppThemeMode.amoled);
  }

  ThemeData buildLightVariant() => AppTheme.light(accent: accent);

  ThemeMode get materialThemeMode {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.dark:
      case AppThemeMode.amoled:
        return ThemeMode.dark;
    }
  }
}

class ThemeController extends Notifier<ThemeSelection> {
  @override
  ThemeSelection build() => const ThemeSelection();

  void setMode(AppThemeMode mode) => state = state.copyWith(mode: mode);
  void setAccent(Color color) => state = state.copyWith(accent: color);
}

final themeControllerProvider = NotifierProvider<ThemeController, ThemeSelection>(ThemeController.new);
