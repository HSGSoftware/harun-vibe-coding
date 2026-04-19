class ConversationEntity {
  const ConversationEntity({
    required this.id,
    required this.projectId,
    required this.provider,
    required this.model,
    required this.title,
    this.archived = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String projectId;
  final String provider;
  final String model;
  final String title;
  final bool archived;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ConversationEntity.fromJson(Map<String, dynamic> json) {
    int? ms(dynamic v) => v is num ? v.toInt() : null;
    return ConversationEntity(
      id: json['ID'] as String? ?? json['id'] as String? ?? '',
      projectId: json['ProjectID'] as String? ?? json['project_id'] as String? ?? '',
      provider: json['Provider'] as String? ?? json['provider'] as String? ?? '',
      model: json['Model'] as String? ?? json['model'] as String? ?? '',
      title: json['Title'] as String? ?? json['title'] as String? ?? '',
      archived: (json['Archived'] ?? json['archived'] ?? false) as bool,
      createdAt: ms(json['CreatedAt']) != null ? DateTime.fromMillisecondsSinceEpoch(ms(json['CreatedAt'])!) : null,
      updatedAt: ms(json['UpdatedAt']) != null ? DateTime.fromMillisecondsSinceEpoch(ms(json['UpdatedAt'])!) : null,
    );
  }
}
