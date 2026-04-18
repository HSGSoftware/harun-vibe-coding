import 'package:flutter/material.dart';

class CtrlKeyRow extends StatelessWidget {
  const CtrlKeyRow({super.key, required this.onSend});
  final void Function(String data) onSend;

  @override
  Widget build(BuildContext context) {
    final entries = <({String label, String data})>[
      (label: 'ESC', data: '\x1b'),
      (label: 'TAB', data: '\t'),
      (label: '^C', data: '\x03'),
      (label: '^Z', data: '\x1a'),
      (label: '^D', data: '\x04'),
      (label: '|', data: '|'),
      (label: '/', data: '/'),
      (label: '~', data: '~'),
    ];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final e = entries[i];
          return OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: const Size(40, 32), padding: const EdgeInsets.symmetric(horizontal: 10)),
            onPressed: () => onSend(e.data),
            child: Text(e.label, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12)),
          );
        },
      ),
    );
  }
}
