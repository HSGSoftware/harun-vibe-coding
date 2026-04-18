import 'package:flutter/material.dart';

import '../../../core/utils/env_colors.dart';

class EnvBadge extends StatelessWidget {
  const EnvBadge({super.key, required this.env});
  final String env;

  @override
  Widget build(BuildContext context) {
    final Color color = envColorFor(env);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(env, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
