class TerminalSessionEntity {
  const TerminalSessionEntity({required this.id, required this.cwd, this.alive = true, this.createdAt});
  final String id;
  final String cwd;
  final bool alive;
  final DateTime? createdAt;

  factory TerminalSessionEntity.fromJson(Map<String, dynamic> json) {
    return TerminalSessionEntity(
      id: json['id'] as String? ?? '',
      cwd: json['cwd'] as String? ?? '',
      alive: json['alive'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }
}
