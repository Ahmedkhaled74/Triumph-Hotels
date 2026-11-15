class GlobalNotification {
  final int id;
  final String title;
  final String message;
  final String? url;
  final DateTime createdAt;

  final String? type;
  final int? offerId;
  final String? hotelSlug;

  GlobalNotification({
    required this.id,
    required this.title,
    required this.message,
    this.url,
    required this.createdAt,
    this.type,
    this.offerId,
    this.hotelSlug,
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
      type: json['type'],
      offerId: json['offer_id'] is int ? json['offer_id'] : int.tryParse(json['offer_id']?.toString() ?? ''),
      hotelSlug: json['hotel_slug'],
    );
  }
}
