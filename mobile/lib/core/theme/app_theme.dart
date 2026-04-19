import 'package:flutter/material.dart';

import 'color_schemes.dart';
import 'component_styles.dart';
import 'typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData dark({Color accent = AppColors.accent, bool amoled = false}) {
    final ColorScheme scheme = darkScheme(accent: accent, amoled: amoled);
    return _assemble(scheme).copyWith(
      scaffoldBackgroundColor: amoled ? AppColors.bgAmoled : AppColors.bgDark,
    );
  }

  static ThemeData light({Color accent = AppColors.accent}) {
    final ColorScheme scheme = lightScheme(accent: accent);
    return _assemble(scheme);
  }

  static ThemeData _assemble(ColorScheme scheme) {
    final TextTheme text = buildTextTheme(scheme);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: text,
      primaryTextTheme: text,
      brightness: scheme.brightness,
      cardTheme: AppComponents.card(scheme),
      appBarTheme: AppComponents.appBar(scheme),
      filledButtonTheme: AppComponents.filledButton(scheme),
      outlinedButtonTheme: AppComponents.outlinedButton(scheme),
      inputDecorationTheme: AppComponents.input(scheme),
      dividerTheme: AppComponents.divider(scheme),
      navigationBarTheme: AppComponents.navBar(scheme),
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
