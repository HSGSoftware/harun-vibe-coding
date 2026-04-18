import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AssistantMessageBubble extends StatelessWidget {
  const AssistantMessageBubble({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 6, 40, 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: MarkdownBody(
            data: text.isEmpty ? '…' : text,
            selectable: true,
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              code: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12),
              codeblockDecoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
