import 'package:flutter/services.dart';

class ClipboardX {
  const ClipboardX._();
  static Future<void> copy(String text) => Clipboard.setData(ClipboardData(text: text));
  static Future<String?> paste() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }
}
