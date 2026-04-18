import 'package:flutter/material.dart';

class ArrowKeyPad extends StatelessWidget {
  const ArrowKeyPad({super.key, required this.onSend});
  final void Function(String data) onSend;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _btn(Icons.keyboard_arrow_up, () => onSend('\x1b[A')),
        _btn(Icons.keyboard_arrow_down, () => onSend('\x1b[B')),
        _btn(Icons.keyboard_arrow_left, () => onSend('\x1b[D')),
        _btn(Icons.keyboard_arrow_right, () => onSend('\x1b[C')),
      ],
    );
  }

  Widget _btn(IconData icon, VoidCallback cb) {
    return IconButton(
      onPressed: cb,
      icon: Icon(icon, size: 18),
      visualDensity: VisualDensity.compact,
    );
  }
}
