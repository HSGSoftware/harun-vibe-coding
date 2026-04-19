import 'package:flutter/material.dart';

import '../../../core/utils/clipboard.dart';
import '../../../domain/entities/project.dart';
import 'env_badge.dart';
import 'status_chip.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    required this.onToggleStart,
    this.onLongPress,
  });

  final ProjectEntity project;
  final VoidCallback onTap;
  final VoidCallback onToggleStart;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EnvBadge(env: project.env),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(project.name, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(project.path,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      if (project.port != 0)
                        Text('Port ${project.runningPort ?? project.port}',
                            style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ProjectStatusChip(status: project.status),
                    const SizedBox(height: 6),
                    Icon(
                      project.favorite ? Icons.star : Icons.star_border,
                      size: 18,
                      color: project.favorite ? const Color(0xFFF59E0B) : scheme.outline,
                    ),
                  ],
                ),
              ],
            ),
            if (project.tunnelUrl != null) ...[
              const SizedBox(height: 10),
              _TunnelChip(url: project.tunnelUrl!),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: onToggleStart,
                    child: Text(project.isRunning || project.isStarting ? 'Durdur' : 'Başlat'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TunnelChip extends StatelessWidget {
  const _TunnelChip({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.public, size: 16, color: Color(0xFF3B82F6)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(url, style: const TextStyle(fontSize: 12, color: Color(0xFF3B82F6)),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        IconButton(
          onPressed: () => ClipboardX.copy(url),
          icon: const Icon(Icons.copy, size: 16),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
