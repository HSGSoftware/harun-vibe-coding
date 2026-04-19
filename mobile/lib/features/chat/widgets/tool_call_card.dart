import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../domain/entities/message.dart';

class ToolCallCard extends StatefulWidget {
  const ToolCallCard({super.key, required this.message});
  final ChatMessage message;

  @override
  State<ToolCallCard> createState() => _ToolCallCardState();
}

class _ToolCallCardState extends State<ToolCallCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final summary = _summary(widget.message);
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 40, 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                const Icon(Icons.build_circle_outlined, size: 16),
                const SizedBox(width: 6),
                Expanded(child: Text('${widget.message.toolName ?? '—'}  $summary', style: Theme.of(context).textTheme.labelMedium)),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 18),
              ],
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 6),
            SelectableText(
              const JsonEncoder.withIndent('  ').convert(widget.message.toolInput ?? {}),
              style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  String _summary(ChatMessage m) {
    final input = m.toolInput;
    if (input == null) return '';
    if (input['path'] is String) return input['path'] as String;
    if (input['command'] is String) {
      final cmd = (input['command'] as String).trim();
      return cmd.length > 60 ? '${cmd.substring(0, 60)}…' : cmd;
    }
    return '';
  }
}
