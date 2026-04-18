class BackupEntity {
  const BackupEntity({
    required this.id,
    required this.projectId,
    required this.type,
    this.sizeBytes = 0,
    this.path,
    this.commitHash,
    this.trigger = 'manual',
    this.note,
    this.createdAt,
  });

  final String id;
  final String projectId;
  final String type;
  final int sizeBytes;
  final String? path;
  final String? commitHash;
  final String trigger;
  final String? note;
  final DateTime? createdAt;

  factory BackupEntity.fromJson(Map<String, dynamic> json) {
    return BackupEntity(
      id: json['id'] as String? ?? '',
      projectId: json['project_id'] as String? ?? '',
      type: json['type'] as String? ?? 'local_zip',
      sizeBytes: (json['size_bytes'] as num?)?.toInt() ?? 0,
      path: json['path'] as String?,
      commitHash: json['commit_hash'] as String?,
      trigger: json['trigger'] as String? ?? 'manual',
      note: json['note'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }
}
