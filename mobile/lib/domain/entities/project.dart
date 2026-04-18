class ProjectEntity {
  const ProjectEntity({
    required this.id,
    required this.name,
    required this.path,
    required this.env,
    required this.port,
    required this.entryCmd,
    required this.source,
    required this.status,
    this.gitRepo,
    this.gitBranch,
    this.group,
    this.favorite = false,
    this.lastOpened,
    this.createdAt,
    this.runningPort,
    this.tunnelUrl,
  });

  final String id;
  final String name;
  final String path;
  final String env;
  final int port;
  final String entryCmd;
  final String source;
  final String status;
  final String? gitRepo;
  final String? gitBranch;
  final String? group;
  final bool favorite;
  final DateTime? lastOpened;
  final DateTime? createdAt;
  final int? runningPort;
  final String? tunnelUrl;

  factory ProjectEntity.fromJson(Map<String, dynamic> json) {
    DateTime? ts(String key) {
      final raw = json[key];
      if (raw == null) return null;
      if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
      return null;
    }

    return ProjectEntity(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      path: json['path'] as String? ?? '',
      env: json['env'] as String? ?? 'generic',
      port: (json['port'] as num?)?.toInt() ?? 0,
      entryCmd: json['entry_cmd'] as String? ?? '',
      source: json['source'] as String? ?? 'empty',
      status: json['status'] as String? ?? 'stopped',
      gitRepo: json['git_repo'] as String?,
      gitBranch: json['git_branch'] as String?,
      group: json['group'] as String?,
      favorite: json['favorite'] as bool? ?? false,
      lastOpened: ts('last_opened'),
      createdAt: ts('created_at'),
      runningPort: (json['running_port'] as num?)?.toInt(),
      tunnelUrl: json['tunnel_url'] as String?,
    );
  }

  bool get isRunning => status == 'running';
  bool get isStarting => status == 'starting';
  bool get hasError => status == 'error';
}
