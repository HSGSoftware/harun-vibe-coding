import 'package:flutter/material.dart';

class ChatSessionPage extends StatelessWidget {
  const ChatSessionPage({super.key, required this.conversationId});
  final String conversationId;
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: Text('Sohbet $conversationId')), body: const Center(child: Text('Sohbet — Faz 5-6')));
}
