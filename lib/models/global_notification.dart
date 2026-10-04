class GlobalNotification {
  final int id;
  final String title;
  final String message;
  final String? url;
  final DateTime createdAt;

  GlobalNotification({
    required this.id,
    required this.title,
    required this.message,
    this.url,
    required this.createdAt,
  });

  factory GlobalNotification.fromJson(Map<String, dynamic> json) {
    return GlobalNotification(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      url: json['url'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }
}
