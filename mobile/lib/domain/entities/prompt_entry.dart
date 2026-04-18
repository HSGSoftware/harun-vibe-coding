class PromptEntry {
  const PromptEntry({required this.id, required this.title, required this.content, this.tags = ''});
  final String id;
  final String title;
  final String content;
  final String tags;

  factory PromptEntry.fromJson(Map<String, dynamic> json) {
    return PromptEntry(
      id: json['ID'] as String? ?? json['id'] as String? ?? '',
      title: json['Title'] as String? ?? json['title'] as String? ?? '',
      content: json['Content'] as String? ?? json['content'] as String? ?? '',
      tags: json['Tags'] as String? ?? json['tags'] as String? ?? '',
    );
  }
}
