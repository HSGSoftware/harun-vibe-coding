import 'package:intl/intl.dart';

class Formatters {
  const Formatters._();

  static String shortDate(DateTime dt) => DateFormat('dd MMM, HH:mm', 'tr').format(dt);
  static String time(DateTime dt) => DateFormat('HH:mm', 'tr').format(dt);
  static String relative(DateTime dt) {
    final Duration diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} sa önce';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    return shortDate(dt);
  }

  static String bytes(int b) {
    if (b < 1024) return '$b B';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(1)} KB';
    if (b < 1024 * 1024 * 1024) return '${(b / 1024 / 1024).toStringAsFixed(1)} MB';
    return '${(b / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
  }

  static String cost(double usd) => '\$${usd.toStringAsFixed(4)}';
}
