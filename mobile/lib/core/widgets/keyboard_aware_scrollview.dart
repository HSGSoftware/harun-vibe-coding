import 'package:flutter/material.dart';

class KeyboardAwareScrollView extends StatelessWidget {
  const KeyboardAwareScrollView({super.key, required this.child, this.padding});
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.of(context).viewInsets.bottom;
    return SingleChildScrollView(
      padding: (padding ?? EdgeInsets.zero).copyWith(bottom: (padding?.bottom ?? 0) + bottom),
      physics: const BouncingScrollPhysics(),
      child: child,
    );
  }
}
