class RequestTemplate {
  final String id;
  final String title;
  final String category;
  final int? estimatedMinutes;
  final String? iconStr;
  final String? colorStr;

  RequestTemplate({
    required this.id,
    required this.title,
    required this.category,
    this.estimatedMinutes,
    this.iconStr,
    this.colorStr,
  });

  factory RequestTemplate.fromJson(Map<String, dynamic> json) {
    return RequestTemplate(
      id: json['id'] as String? ?? json['uuid'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      estimatedMinutes: json['estimatedMinutes'] as int? ?? json['estimated_minutes'] as int?,
      iconStr: json['icon'] as String?,
      colorStr: json['color'] as String?,
    );
  }
}
