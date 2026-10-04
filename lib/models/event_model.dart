class EventModel {
  final int id;
  final String name;
  final String image;
  final String description;
  final String shortDescription;
  final String venue;
  final String startDate;
  final String endDate;
  final bool isActive;

  EventModel({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.shortDescription,
    required this.venue,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      shortDescription: json['short_description'] ?? '',
      venue: json['venue'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'description': description,
      'short_description': shortDescription,
      'venue': venue,
      'start_date': startDate,
      'end_date': endDate,
      'is_active': isActive,
    };
  }
}
