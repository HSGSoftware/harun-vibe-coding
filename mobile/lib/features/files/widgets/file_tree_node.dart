import 'package:flutter/material.dart';

import '../../../core/utils/file_icons.dart';
import '../../../domain/entities/file_node.dart';

class FileTreeNode extends StatefulWidget {
  const FileTreeNode({
    super.key,
    required this.node,
    required this.onTapFile,
    this.initiallyExpanded = false,
    this.depth = 0,
  });

  final FileNode node;
  final void Function(FileNode) onTapFile;
  final bool initiallyExpanded;
  final int depth;

  @override
  State<FileTreeNode> createState() => _FileTreeNodeState();
}

class _FileTreeNodeState extends State<FileTreeNode> {
  late bool _expanded = widget.initiallyExpanded || widget.depth == 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final indent = widget.depth * 14.0;
    if (!widget.node.isDir) {
      return InkWell(
        onTap: () => widget.onTapFile(widget.node),
        child: Padding(
          padding: EdgeInsets.fromLTRB(indent + 12, 6, 12, 6),
          child: Row(
            children: [
              Icon(fileIconFor(widget.node.name), size: 16, color: scheme.onSurface.withValues(alpha: 0.7)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(widget.node.name, style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: EdgeInsets.fromLTRB(indent + 6, 6, 12, 6),
            child: Row(
              children: [
                Icon(_expanded ? Icons.keyboard_arrow_down : Icons.chevron_right, size: 18),
                const SizedBox(width: 4),
                Icon(_expanded ? Icons.folder_open : Icons.folder, size: 16, color: const Color(0xFFF59E0B)),
                const SizedBox(width: 8),
                Expanded(child: Text(widget.node.name, style: Theme.of(context).textTheme.titleSmall)),
              ],
            ),
          ),
        ),
        if (_expanded)
          for (final child in widget.node.children)
            FileTreeNode(
              node: child,
              onTapFile: widget.onTapFile,
              depth: widget.depth + 1,
            ),
      ],
    );
  }
}
