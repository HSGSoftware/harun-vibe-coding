import 'package:flutter/material.dart';

class PermissionRequestCard extends StatelessWidget {
  const PermissionRequestCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.granted,
    required this.onRequest,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool granted;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: granted ? const Color(0xFF22C55E) : scheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(body, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (granted)
            const Icon(Icons.check_circle, color: Color(0xFF22C55E))
          else
            OutlinedButton(onPressed: onRequest, child: const Text('İzin Ver')),
        ],
      ),
    );
  }
}
