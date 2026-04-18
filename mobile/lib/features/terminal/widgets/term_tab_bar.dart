import 'package:flutter/material.dart';

import '../../../domain/entities/terminal_session.dart';

class TermTabBar extends StatelessWidget {
  const TermTabBar({
    super.key,
    required this.sessions,
    required this.activeId,
    required this.onTap,
    required this.onClose,
    required this.onNew,
  });

  final List<TerminalSessionEntity> sessions;
  final String? activeId;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onClose;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: sessions.length,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              separatorBuilder: (_, __) => const SizedBox(width: 4),
              itemBuilder: (_, i) {
                final s = sessions[i];
                final bool active = s.id == activeId;
                return InkWell(
                  onTap: () => onTap(s.id),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15) : null,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: active
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.terminal, size: 14),
                        const SizedBox(width: 6),
                        Text('Tab ${i + 1}', style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => onClose(s.id),
                          child: const Icon(Icons.close, size: 14),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(onPressed: onNew, icon: const Icon(Icons.add)),
        ],
      ),
    );
  }
}
