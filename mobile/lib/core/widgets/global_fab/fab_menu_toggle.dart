import 'package:flutter/material.dart';

import 'fab_context_provider.dart';

class FabMenuToggle extends StatelessWidget {
  const FabMenuToggle({super.key, required this.action, required this.onClose});
  final FabAction action;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final bool value = action.toggled ?? false;
    return SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: action.enabled
                ? () {
                    action.onTap?.call();
                  }
                : null,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: value ? action.color : Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
                border: Border.all(color: value ? action.color : Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Icon(action.icon, color: value ? Colors.white : Theme.of(context).colorScheme.onSurface),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            action.label,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
