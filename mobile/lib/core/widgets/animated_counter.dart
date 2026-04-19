import 'package:flutter/material.dart';

class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({super.key, required this.value, this.style, this.duration = const Duration(milliseconds: 350)});
  final int value;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Text(v.round().toString(), style: style),
    );
  }
}
