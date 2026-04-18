import 'package:flutter/material.dart';

import 'fab_menu_panel.dart';

/// Full-screen overlay that dims the background and hosts [FabMenuPanel].
/// Tapping outside closes the menu; the panel opens with a short scale+fade.
class FabMenuOverlay extends StatelessWidget {
  const FabMenuOverlay({super.key, required this.onClose, required this.origin});
  final VoidCallback onClose;
  final Offset origin;

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.opaque,
            child: ColoredBox(color: const Color(0x88000000)),
          ),
        ),
        Positioned(
          right: screen.width - origin.dx - 260,
          bottom: screen.height - origin.dy + 12,
          child: AnimatedScale(
            scale: 1,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: FabMenuPanel(onClose: onClose),
          ),
        ),
      ],
    );
  }
}
