import 'package:flutter/material.dart';

class SwipeActionTile extends StatelessWidget {
  const SwipeActionTile({
    super.key,
    required this.child,
    required this.onStartStop,
    required this.onDelete,
    required this.keyId,
  });

  final String keyId;
  final Widget child;
  final Future<void> Function() onStartStop;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Dismissible(
      key: ValueKey(keyId),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: scheme.primary.withValues(alpha: 0.15),
        child: Icon(Icons.play_arrow_rounded, color: scheme.primary),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: scheme.error.withValues(alpha: 0.25),
        child: Icon(Icons.delete_rounded, color: scheme.error),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await onStartStop();
          return false;
        }
        await onDelete();
        return false;
      },
      child: child,
    );
  }
}
