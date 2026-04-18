import 'package:flutter/material.dart';

/// Maps common filenames / extensions to a representative Material icon.
IconData fileIconFor(String filename) {
  final String lower = filename.toLowerCase();
  if (lower.endsWith('.dart')) return Icons.flutter_dash;
  if (lower.endsWith('.go')) return Icons.code;
  if (lower.endsWith('.kt') || lower.endsWith('.kts')) return Icons.android;
  if (lower.endsWith('.py')) return Icons.integration_instructions;
  if (lower.endsWith('.js') || lower.endsWith('.ts') || lower.endsWith('.tsx') || lower.endsWith('.jsx')) {
    return Icons.javascript;
  }
  if (lower.endsWith('.json')) return Icons.data_object;
  if (lower.endsWith('.yaml') || lower.endsWith('.yml')) return Icons.description;
  if (lower.endsWith('.md')) return Icons.article;
  if (lower.endsWith('.png') || lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.svg')) {
    return Icons.image;
  }
  if (lower.endsWith('.lock') || lower == 'yarn.lock' || lower == 'package-lock.json') return Icons.lock;
  if (lower == '.gitignore' || lower == '.env') return Icons.settings;
  return Icons.insert_drive_file_outlined;
}
