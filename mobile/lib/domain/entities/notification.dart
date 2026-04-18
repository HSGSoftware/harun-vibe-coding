class NotificationAction {
  const NotificationAction({required this.id, required this.label});
  final String id;
  final String label;
}

class NotificationEntity {
  const NotificationEntity({
    required this.id,
    required this.category,
    required this.title,
    required this.body,
    this.importance = 'normal',
    this.deepLink,
    this.actions = const [],
    this.read = false,
    this.createdAt,
  });

  final String id;
  final String category;
  final String title;
  final String body;
  final String importance;
  final String? deepLink;
  final List<NotificationAction> actions;
  final bool read;
  final DateTime? createdAt;

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    final actionsRaw = (json['actions'] as List?) ?? const [];
    return NotificationEntity(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? 'system',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      importance: json['importance'] as String? ?? 'normal',
      deepLink: json['deep_link'] as String?,
      actions: actionsRaw
          .map((e) => NotificationAction(
                id: (e as Map)['id'] as String? ?? '',
                label: (e)['label'] as String? ?? '',
              ))
          .toList(),
      read: json['read'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }
}
