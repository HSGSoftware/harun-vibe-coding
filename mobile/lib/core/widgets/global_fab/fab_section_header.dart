import 'package:flutter/material.dart';

class FabSectionHeader extends StatelessWidget {
  const FabSectionHeader({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 12, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.1,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
            ),
      ),
    );
  }
}
