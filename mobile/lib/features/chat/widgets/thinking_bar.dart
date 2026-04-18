import 'package:flutter/material.dart';

class ThinkingBar extends StatelessWidget {
  const ThinkingBar({super.key, required this.preview, required this.elapsed});
  final String preview;
  final Duration elapsed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: scheme.surfaceContainer,
      child: Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              preview.isEmpty ? 'Düşünüyor…' : preview,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          Text('${elapsed.inMilliseconds / 1000}s', style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
