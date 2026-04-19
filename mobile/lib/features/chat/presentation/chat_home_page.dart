import 'package:flutter/material.dart';
import '../../../core/l10n/strings_tr.dart';

class ChatHomePage extends StatelessWidget {
  const ChatHomePage({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text(S.navChat)), body: const Center(child: Text('AI ana — Faz 5')));
}
