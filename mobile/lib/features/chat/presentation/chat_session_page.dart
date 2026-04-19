import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/entities/message.dart';
import '../widgets/assistant_message.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/permission_dialog.dart';
import '../widgets/thinking_bar.dart';
import '../widgets/tool_call_card.dart';
import '../widgets/tool_result_card.dart';
import '../widgets/user_message.dart';
import 'providers/chat_stream_provider.dart';

class ChatSessionPage extends ConsumerStatefulWidget {
  const ChatSessionPage({super.key, required this.conversationId});
  final String conversationId;

  @override
  ConsumerState<ChatSessionPage> createState() => _ChatSessionPageState();
}

class _ChatSessionPageState extends ConsumerState<ChatSessionPage> {
  String? _lastHandledToolUseId;

  @override
  Widget build(BuildContext context) {
    ref.listen(chatStreamProvider(widget.conversationId), (_, next) async {
      final st = next.valueOrNull;
      if (st?.pending != null && st!.pending!.toolUseId != _lastHandledToolUseId) {
        _lastHandledToolUseId = st.pending!.toolUseId;
        final res = await showPermissionDialog(context, st.pending!);
        if (!mounted || res == null) return;
        ref.read(chatStreamProvider(widget.conversationId).notifier).decide(
              widget.conversationId,
              st.pending!.toolUseId,
              res.allow,
              always: res.always,
            );
      }
    });

    final async = ref.watch(chatStreamProvider(widget.conversationId));
    return Scaffold(
      appBar: AppBar(title: const Text('Sohbet')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (st) => Column(
          children: [
            if (st.busy || st.thinking.isNotEmpty)
              ThinkingBar(preview: st.thinking, elapsed: Duration.zero),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: st.messages.length,
                itemBuilder: (_, i) {
                  final m = st.messages[i];
                  return switch (m.kind) {
                    MessageKind.user => UserMessageBubble(text: m.text),
                    MessageKind.assistant => AssistantMessageBubble(text: m.text),
                    MessageKind.toolCall => ToolCallCard(message: m),
                    MessageKind.toolResult => ToolResultCard(message: m),
                    MessageKind.system => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: Text(m.text, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      ),
                  };
                },
              ),
            ),
            ChatInputBar(
              busy: st.busy,
              onAbort: () =>
                  ref.read(chatStreamProvider(widget.conversationId).notifier).abort(widget.conversationId),
              onSubmit: (text) => ref
                  .read(chatStreamProvider(widget.conversationId).notifier)
                  .send(widget.conversationId, text),
            ),
          ],
        ),
      ),
    );
  }
}
