import 'package:flutter/material.dart';
import '../../../core/l10n/strings_tr.dart';

class TerminalPage extends StatelessWidget {
  const TerminalPage({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text(S.navTerminal)), body: const Center(child: Text('Terminal — Faz 4')));
}
