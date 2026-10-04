class MeetingRoomModel {
  final int id;
  final String name;
  final String slug;
  final int capacity;
  final double area;
  final String description;
  final String imageCover;
  final bool available;
  final bool canHostWedding;
  final String? weddingBrochure;
  final List<MeetingRoomAmenity> amenities;
  final List<SeatingArrangement> seatingArrangements;
  final List<MeetingRoomImage> images;
  final List<MeetingRoomImage> weddingImages;

  MeetingRoomModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.capacity,
    required this.area,
    required this.description,
    required this.imageCover,
    required this.available,
    required this.canHostWedding,
    this.weddingBrochure,
    required this.amenities,
    required this.seatingArrangements,
    required this.images,
    required this.weddingImages,
  });

  factory MeetingRoomModel.fromJson(Map<String, dynamic> json) {
    return MeetingRoomModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      capacity: json['capacity'] ?? 0,
      area: (json['area'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      imageCover: json['image_cover'] ?? '',
      available: json['available'] ?? false,
      canHostWedding: json['can_host_wedding'] ?? false,
      weddingBrochure: json['wedding_brochure'],
      amenities: (json['amenities'] as List? ?? [])
          .map((e) => MeetingRoomAmenity.fromJson(e))
          .toList(),
      seatingArrangements: (json['seating_arrangements'] as List? ?? [])
          .map((e) => SeatingArrangement.fromJson(e))
          .toList(),
      images: (json['images'] as List? ?? [])
          .map((e) => MeetingRoomImage.fromJson(e))
          .toList(),
      weddingImages: (json['wedding_images'] as List? ?? [])
          .map((e) => MeetingRoomImage.fromJson(e))
          .toList(),
    );
  }
}

class MeetingRoomAmenity {
  final int id;
  final String name;
  final String? description;
  final String? icon;

  MeetingRoomAmenity({
    required this.id,
    required this.name,
    this.description,
    this.icon,
  });

  factory MeetingRoomAmenity.fromJson(Map<String, dynamic> json) {
    return MeetingRoomAmenity(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
    );
  }
}

class SeatingArrangement {
  final int id;
  final String name;
  final String description;
  final int capacity;
  final String image;

  SeatingArrangement({
    required this.id,
    required this.name,
    required this.description,
    required this.capacity,
    required this.image,
  });

  factory SeatingArrangement.fromJson(Map<String, dynamic> json) {
    return SeatingArrangement(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      capacity: json['capacity'] ?? 0,
      image: json['image'] ?? '',
    );
  }
}

class MeetingRoomImage {
  final int id;
  final String image;

  MeetingRoomImage({
    required this.id,
    required this.image,
  });

  factory MeetingRoomImage.fromJson(Map<String, dynamic> json) {
    return MeetingRoomImage(
      id: json['id'],
      image: json['image'],
    );
  }
}
