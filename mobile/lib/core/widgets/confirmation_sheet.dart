import 'package:flutter/material.dart';

import '../l10n/strings_tr.dart';

Future<bool> showConfirmationSheet({
  required BuildContext context,
  required String title,
  String? body,
  String confirmLabel = S.confirm,
  String cancelLabel = S.cancel,
  bool destructive = false,
}) async {
  final ColorScheme scheme = Theme.of(context).colorScheme;
  final bool? result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: scheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(ctx).textTheme.titleLarge),
            if (body != null) ...[
              const SizedBox(height: 10),
              Text(body, style: Theme.of(ctx).textTheme.bodyMedium),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(cancelLabel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: destructive
                        ? FilledButton.styleFrom(backgroundColor: scheme.error)
                        : null,
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text(confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}
