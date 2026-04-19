import 'package:flutter/material.dart';

import '../../utils/haptics.dart';
import 'fab_context_provider.dart';

class FabMenuButton extends StatelessWidget {
  const FabMenuButton({super.key, required this.action, required this.onClose});
  final FabAction action;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final bool disabled = !action.enabled;
    return Opacity(
      opacity: disabled ? 0.4 : 1,
      child: InkResponse(
        onTap: disabled
            ? null
            : () async {
                await Haptics.select();
                action.onTap?.call();
                onClose();
              },
        radius: 36,
        child: SizedBox(
          width: 72,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: action.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: action.color.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 3)),
                  ],
                ),
                child: Icon(action.icon, color: Colors.white),
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
        ),
      ),
    );
  }
}
