import 'package:flutter/material.dart';

import '../../../core/l10n/strings_tr.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({super.key, required this.onSubmit, this.busy = false, this.onAbort});
  final ValueChanged<String> onSubmit;
  final bool busy;
  final VoidCallback? onAbort;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty || widget.busy) return;
    widget.onSubmit(text);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 6, 8, MediaQuery.of(context).viewInsets.bottom + 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              focusNode: _focus,
              minLines: 1,
              maxLines: 6,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                hintText: S.chatInputHint,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 6),
          widget.busy
              ? IconButton.filled(onPressed: widget.onAbort, icon: const Icon(Icons.stop_circle))
              : IconButton.filled(onPressed: _submit, icon: const Icon(Icons.send_rounded)),
        ],
      ),
    );
  }
}
