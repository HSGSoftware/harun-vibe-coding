class SetupStateEntity {
  const SetupStateEntity({
    required this.completed,
    required this.step,
    this.missing = const [],
  });

  final bool completed;
  final int step;
  final List<String> missing;

  factory SetupStateEntity.fromJson(Map<String, dynamic> json) {
    return SetupStateEntity(
      completed: json['completed'] as bool? ?? false,
      step: (json['step'] as num?)?.toInt() ?? 1,
      missing: ((json['missing'] as List?) ?? const []).map((e) => e.toString()).toList(),
    );
  }
}
