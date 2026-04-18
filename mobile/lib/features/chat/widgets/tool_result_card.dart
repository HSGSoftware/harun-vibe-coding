import 'package:flutter/material.dart';

import '../../../domain/entities/message.dart';

class ToolResultCard extends StatelessWidget {
  const ToolResultCard({super.key, required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isError = message.isError;
    final scheme = Theme.of(context).colorScheme;
    final color = isError ? scheme.error : const Color(0xFF22C55E);
    final text = message.text.length > 2000 ? '${message.text.substring(0, 2000)}…' : message.text;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 2, 40, 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isError ? Icons.error_outline : Icons.check_circle_outline, size: 14, color: color),
              const SizedBox(width: 6),
              Text(isError ? 'Hata' : 'Tamamlandı', style: TextStyle(color: color, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          SelectableText(text, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11)),
        ],
      ),
    );
  }
}
