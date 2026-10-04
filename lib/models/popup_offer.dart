class PopupOffer {
  final int id;
  final String title;
  final String description;
  final String? image;
  final String? offerLink;

  PopupOffer({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    this.offerLink,
  });

  factory PopupOffer.fromJson(Map<String, dynamic> json) {
    return PopupOffer(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'],
      offerLink: json['offer_link'],
    );
  }
}
