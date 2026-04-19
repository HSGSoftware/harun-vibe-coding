class FileNode {
  const FileNode({
    required this.name,
    required this.path,
    required this.isDir,
    this.size = 0,
    this.children = const [],
  });

  final String name;
  final String path;
  final bool isDir;
  final int size;
  final List<FileNode> children;

  factory FileNode.fromJson(Map<String, dynamic> json) {
    final raw = (json['children'] as List?) ?? const [];
    return FileNode(
      name: json['name'] as String? ?? '',
      path: json['path'] as String? ?? '',
      isDir: json['is_dir'] as bool? ?? false,
      size: (json['size'] as num?)?.toInt() ?? 0,
      children: raw
          .map((e) => FileNode.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class FileContent {
  const FileContent({
    required this.content,
    required this.size,
    required this.language,
    required this.encoding,
    this.mtime,
  });

  final String content;
  final int size;
  final String language;
  final String encoding;
  final DateTime? mtime;

  factory FileContent.fromJson(Map<String, dynamic> json) {
    return FileContent(
      content: json['content'] as String? ?? '',
      size: (json['size'] as num?)?.toInt() ?? 0,
      language: json['language'] as String? ?? 'plaintext',
      encoding: json['encoding'] as String? ?? 'utf-8',
      mtime: DateTime.tryParse(json['mtime'] as String? ?? ''),
    );
  }
}
