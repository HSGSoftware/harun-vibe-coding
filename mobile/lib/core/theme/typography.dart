import 'package:flutter/material.dart';

/// Inter for UI, JetBrainsMono for code/terminal. Falls back to platform fonts
/// if assets are missing (used in tests).
TextTheme buildTextTheme(ColorScheme scheme) {
  const String ui = 'Inter';
  final Color fg = scheme.onSurface;
  final Color fgDim = scheme.onSurface.withValues(alpha: 0.68);

  return TextTheme(
    displayLarge: TextStyle(fontFamily: ui, fontSize: 32, fontWeight: FontWeight.w700, color: fg, height: 1.15),
    displayMedium: TextStyle(fontFamily: ui, fontSize: 28, fontWeight: FontWeight.w700, color: fg),
    headlineLarge: TextStyle(fontFamily: ui, fontSize: 24, fontWeight: FontWeight.w700, color: fg),
    headlineMedium: TextStyle(fontFamily: ui, fontSize: 20, fontWeight: FontWeight.w600, color: fg),
    headlineSmall: TextStyle(fontFamily: ui, fontSize: 18, fontWeight: FontWeight.w600, color: fg),
    titleLarge: TextStyle(fontFamily: ui, fontSize: 17, fontWeight: FontWeight.w600, color: fg),
    titleMedium: TextStyle(fontFamily: ui, fontSize: 15, fontWeight: FontWeight.w600, color: fg),
    titleSmall: TextStyle(fontFamily: ui, fontSize: 13, fontWeight: FontWeight.w600, color: fg),
    bodyLarge: TextStyle(fontFamily: ui, fontSize: 15, fontWeight: FontWeight.w400, color: fg, height: 1.4),
    bodyMedium: TextStyle(fontFamily: ui, fontSize: 14, fontWeight: FontWeight.w400, color: fg, height: 1.4),
    bodySmall: TextStyle(fontFamily: ui, fontSize: 12, fontWeight: FontWeight.w400, color: fgDim),
    labelLarge: TextStyle(fontFamily: ui, fontSize: 14, fontWeight: FontWeight.w600, color: fg),
    labelMedium: TextStyle(fontFamily: ui, fontSize: 12, fontWeight: FontWeight.w500, color: fg),
    labelSmall: TextStyle(fontFamily: ui, fontSize: 11, fontWeight: FontWeight.w500, color: fgDim),
  );
}

const TextStyle kMonoStyle = TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13, height: 1.45);
