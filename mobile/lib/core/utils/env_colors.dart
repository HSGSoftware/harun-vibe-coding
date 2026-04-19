import 'package:flutter/material.dart';

/// Color key per project environment — the colored chip on project cards.
Color envColorFor(String env) {
  switch (env) {
    case 'flutter':
      return const Color(0xFF02569B);
    case 'dart':
      return const Color(0xFF0175C2);
    case 'nodejs':
    case 'node':
    case 'javascript':
    case 'typescript':
      return const Color(0xFF16A34A);
    case 'react':
    case 'nextjs':
    case 'vite':
      return const Color(0xFF06B6D4);
    case 'python':
    case 'django':
    case 'flask':
    case 'fastapi':
      return const Color(0xFFEAB308);
    case 'go':
    case 'golang':
      return const Color(0xFF0EA5E9);
    case 'rust':
      return const Color(0xFFEF4444);
    case 'kotlin':
      return const Color(0xFF7C3AED);
    default:
      return const Color(0xFF64748B);
  }
}
