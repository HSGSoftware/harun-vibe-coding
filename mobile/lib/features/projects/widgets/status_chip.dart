import 'package:flutter/material.dart';

import '../../../core/l10n/strings_tr.dart';
import '../../../core/widgets/status_dot.dart';

class ProjectStatusChip extends StatelessWidget {
  const ProjectStatusChip({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (ProjectStatus dot, String label) = switch (status) {
      'running' => (ProjectStatus.running, S.statusRunning),
      'starting' => (ProjectStatus.starting, S.statusStarting),
      'error' => (ProjectStatus.error, S.statusError),
      _ => (ProjectStatus.stopped, S.statusStopped),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StatusDot(status: dot),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
