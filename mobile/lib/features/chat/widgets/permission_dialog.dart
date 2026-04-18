import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/l10n/strings_tr.dart';
import '../../../domain/entities/message.dart';

Future<({bool allow, bool always})?> showPermissionDialog(
  BuildContext context,
  PermissionRequest req,
) {
  return showModalBottomSheet<({bool allow, bool always})>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      final scheme = Theme.of(ctx).colorScheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lock_outline, color: scheme.primary),
                  const SizedBox(width: 8),
                  Text(S.permissionTitle, style: Theme.of(ctx).textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 8),
              Text('${req.toolName}',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(color: scheme.primary)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  const JsonEncoder.withIndent('  ').convert(req.input),
                  style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton(
                    onPressed: () => Navigator.of(ctx).pop((allow: true, always: false)),
                    child: const Text(S.permissionAllow),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop((allow: true, always: true)),
                    child: const Text(S.permissionAllowAlways),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop((allow: false, always: false)),
                    child: const Text(S.permissionDeny),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
