import 'package:flutter/material.dart';

import '../../../core/theme/color_schemes.dart';

class UserMessageBubble extends StatelessWidget {
  const UserMessageBubble({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        child: Container(
          margin: const EdgeInsets.fromLTRB(40, 6, 12, 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.accent, AppColors.accentDim],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: SelectableText(text, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
        ),
      ),
    );
  }
}
