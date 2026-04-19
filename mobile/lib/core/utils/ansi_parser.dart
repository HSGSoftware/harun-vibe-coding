import 'package:flutter/material.dart';

/// Very small ANSI SGR parser — enough to color common dev-server logs.
/// For full VT support the terminal feature uses `xterm` which has its own parser.
class AnsiSpan {
  const AnsiSpan(this.text, this.style);
  final String text;
  final TextStyle? style;
}

class AnsiParser {
  AnsiParser({required this.defaultStyle});
  final TextStyle defaultStyle;

  static final RegExp _re = RegExp(r'\x1B\[([0-9;]*)m');

  List<AnsiSpan> parse(String input) {
    final List<AnsiSpan> out = <AnsiSpan>[];
    TextStyle current = defaultStyle;
    int cursor = 0;
    for (final RegExpMatch m in _re.allMatches(input)) {
      if (m.start > cursor) {
        out.add(AnsiSpan(input.substring(cursor, m.start), current));
      }
      current = _apply(current, m.group(1) ?? '');
      cursor = m.end;
    }
    if (cursor < input.length) {
      out.add(AnsiSpan(input.substring(cursor), current));
    }
    return out;
  }

  TextStyle _apply(TextStyle base, String codes) {
    if (codes.isEmpty) return defaultStyle;
    TextStyle out = base;
    for (final String raw in codes.split(';')) {
      final int code = int.tryParse(raw) ?? 0;
      switch (code) {
        case 0:
          out = defaultStyle;
          break;
        case 1:
          out = out.copyWith(fontWeight: FontWeight.bold);
          break;
        case 30:
          out = out.copyWith(color: Colors.black);
          break;
        case 31:
          out = out.copyWith(color: const Color(0xFFEF4444));
          break;
        case 32:
          out = out.copyWith(color: const Color(0xFF22C55E));
          break;
        case 33:
          out = out.copyWith(color: const Color(0xFFF59E0B));
          break;
        case 34:
          out = out.copyWith(color: const Color(0xFF3B82F6));
          break;
        case 35:
          out = out.copyWith(color: const Color(0xFFEC4899));
          break;
        case 36:
          out = out.copyWith(color: const Color(0xFF22D3EE));
          break;
        case 37:
          out = out.copyWith(color: Colors.white);
          break;
        case 90:
          out = out.copyWith(color: const Color(0xFF9BA1A9));
          break;
        default:
          break;
      }
    }
    return out;
  }
}
