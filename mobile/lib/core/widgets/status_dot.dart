import 'package:flutter/material.dart';

import '../theme/color_schemes.dart';

/// Tiny colored dot for status indicators (project running, server health, etc.).
class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.status, this.size = 8});

  final ProjectStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (status) {
      ProjectStatus.running => AppColors.success,
      ProjectStatus.starting => AppColors.warning,
      ProjectStatus.stopped => AppColors.onSurfaceDim,
      ProjectStatus.error => AppColors.danger,
    };
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: status == ProjectStatus.running
            ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 6, spreadRadius: 1)]
            : null,
      ),
    );
  }
}

enum ProjectStatus { stopped, starting, running, error }
