
class RoomAmenity {
  final int id;
  final String name;
  final String? icon;

  RoomAmenity({required this.id, required this.name, this.icon});

  factory RoomAmenity.fromJson(Map<String, dynamic> json) {
    return RoomAmenity(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'],
    );
  }
}

class RoomImageDetail {
  final int id;
  final String image;
  final String? caption;

  RoomImageDetail({required this.id, required this.image, this.caption});

  factory RoomImageDetail.fromJson(Map<String, dynamic> json) {
    return RoomImageDetail(
      id: json['id'] ?? 0,
      image: json['image'] ?? '',
      caption: json['caption'],
    );
  }
}

class RoomSpecification {
  final int id;
  final String name;
  final String? description;
  final String? icon;

  RoomSpecification({required this.id, required this.name, this.description, this.icon});

  factory RoomSpecification.fromJson(Map<String, dynamic> json) {
    return RoomSpecification(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      icon: json['icon'],
    );
  }
}

class RoomModel {
  final String id;
  final String name;
  final String? slug;
  final String description;
  final String? shortDescription;
  final String? title;
  final String imageUrl;
  final double price;
  final List<String> features;
  final int maxGuests;
  final double size;
  final String? bedType;
  final int? numberOfBeds;
  final String? roomViews;
  final int? numberOfBathrooms;
  final String? numberOfPersons;
  final bool isAvailable;
  final bool isSuit;
  final bool? includesBreakfast;
  final double? roomDiscount;
  final String? virtualTourLink;
  final List<String>? policySections;
  final List<RoomAmenity>? fullAmenities;
  final List<RoomAmenity>? fullFeatures;
  final List<RoomImageDetail>? galleryImages;
  final List<RoomSpecification>? specifications;
  final int? displayOrder;

  RoomModel({
    required this.id,
    required this.name,
    this.slug,
    required this.description,
    this.shortDescription,
    this.title,
    required this.imageUrl,
    required this.price,
    required this.features,
    required this.maxGuests,
    required this.size,
    this.bedType,
    this.numberOfBeds,
    this.roomViews,
    this.numberOfBathrooms,
    this.numberOfPersons,
    this.isAvailable = true,
    this.isSuit = false,
    this.includesBreakfast,
    this.roomDiscount,
    this.virtualTourLink,
    this.policySections,
    this.fullAmenities,
    this.fullFeatures,
    this.galleryImages,
    this.specifications,
    this.displayOrder,
  });

  // Factory method for creating from API response
  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      slug: json['slug'],
      description: json['description'] ?? '',
      shortDescription: json['short_description'],
      title: json['title'],
      imageUrl: json['image_cover'] ?? json['imageUrl'] ?? json['image_url'] ?? '',
      price: double.tryParse(json['price_per_night']?.toString() ?? '') ?? (json['price'] ?? 0.0).toDouble(),
      features: json['features'] is List && json['features'].isNotEmpty && json['features'][0] is String 
          ? List<String>.from(json['features']) 
          : [],
      maxGuests: int.tryParse(json['number_of_persons']?.split('-').last ?? '') ?? json['maxGuests'] ?? json['max_guests'] ?? 0,
      size: (json['area'] ?? json['size'] ?? 0.0).toDouble(),
      bedType: json['bed_type'],
      numberOfBeds: json['number_of_beds'],
      roomViews: json['room_views'],
      numberOfBathrooms: json['number_of_bathrooms'],
      numberOfPersons: json['number_of_persons']?.toString(),
      isAvailable: json['is_available'] ?? true,
      isSuit: json['is_suit'] ?? false,
      includesBreakfast: json['includes_breakfast'],
      roomDiscount: (json['room_discount'] ?? 0.0).toDouble(),
      virtualTourLink: json['virtual_tour_link'],
      policySections: [
        if (json['room_policy_section_1'] != null) json['room_policy_section_1'],
        if (json['room_policy_section_2'] != null) json['room_policy_section_2'],
        if (json['room_policy_section_3'] != null) json['room_policy_section_3'],
        if (json['room_policy_section_4'] != null) json['room_policy_section_4'],
        if (json['room_policy_section_5'] != null) json['room_policy_section_5'],
      ],
      fullAmenities: json['amenities'] != null ? (json['amenities'] as List).map((e) => RoomAmenity.fromJson(e)).toList() : null,
      fullFeatures: json['features'] != null && json['features'] is List && json['features'].isNotEmpty && json['features'][0] is Map 
          ? (json['features'] as List).map((e) => RoomAmenity.fromJson(e)).toList() : null,
      galleryImages: json['room_images'] != null ? (json['room_images'] as List).map((e) => RoomImageDetail.fromJson(e)).toList() : null,
      specifications: json['specifications'] != null ? (json['specifications'] as List).map((e) => RoomSpecification.fromJson(e)).toList() : null,
      displayOrder: json['display_order'],
    );
  }

  // Method to convert to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'short_description': shortDescription,
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'maxGuests': maxGuests,
      'size': size,
      'bed_type': bedType,
      'number_of_beds': numberOfBeds,
      'room_views': roomViews,
      'number_of_bathrooms': numberOfBathrooms,
      'number_of_persons': numberOfPersons,
      'is_available': isAvailable,
      'is_suit': isSuit,
      'includes_breakfast': includesBreakfast,
      'room_discount': roomDiscount,
      'virtual_tour_link': virtualTourLink,
      'display_order': displayOrder,
    };
  }
}

List<RoomModel> getPlazaRooms() {
  return [
    RoomModel(
      id: 'plaza_1',
      name: 'Standard Room',
      description: 'Comfortable and elegantly furnished room with modern amenities',
      imageUrl: 'standard room.jpg',
      price: 150,
      features: ['King Bed', 'City View', 'Mini Bar', 'Free WiFi'],
      maxGuests: 2,
      size: 25.0,
    ),
    RoomModel(
      id: 'plaza_2',
      name: 'Junior Room',
      description: 'Spacious room with premium furnishings and work area',
      imageUrl: 'junior room.jpg',
      price: 180,
      features: ['Queen Bed', 'Work Desk', 'City View', 'Free WiFi'],
      maxGuests: 2,
      size: 30.0,
    ),
    RoomModel(
      id: 'plaza_3',
      name: 'Junior Suite',
      description: 'Elegant suite with separate living area and premium amenities',
      imageUrl: 'junior suite.jpg',
      price: 220,
      features: ['King Bed', 'Living Area', 'Mini Bar', 'Free WiFi'],
      maxGuests: 3,
      size: 40.0,
    ),
    RoomModel(
      id: 'plaza_4',
      name: 'Executive Junior Suite',
      description: 'Luxurious suite with executive lounge access',
      imageUrl: 'excutive junior suite.jpg',
      price: 280,
      features: ['King Bed', 'Living Area', 'Executive Lounge', 'Free WiFi'],
      maxGuests: 3,
      size: 45.0,
    ),
    RoomModel(
      id: 'plaza_5',
      name: 'Deluxe Suite',
      description: 'Spacious deluxe suite with panoramic city views',
      imageUrl: 'deluxe suite.jpg',
      price: 350,
      features: ['King Bed', 'Living Area', 'Panoramic View', 'Mini Bar'],
      maxGuests: 4,
      size: 55.0,
    ),
    RoomModel(
      id: 'plaza_6',
      name: 'Executive Deluxe Suite',
      description: 'Premium suite with exclusive services and amenities',
      imageUrl: 'excutive deluxe suite.jpg',
      price: 420,
      features: ['King Bed', 'Living Area', 'Executive Services', 'Free WiFi'],
      maxGuests: 4,
      size: 60.0,
    ),
    RoomModel(
      id: 'plaza_7',
      name: 'Family Suite',
      description: 'Perfect suite for families with connecting rooms available',
      imageUrl: 'family suite.jpg',
      price: 380,
      features: ['King Bed', 'Sofa Bed', 'Living Area', 'Mini Bar'],
      maxGuests: 5,
      size: 65.0,
    ),
    RoomModel(
      id: 'plaza_8',
      name: 'Executive Family Suite',
      description: 'Ultimate family suite with premium services and space',
      imageUrl: 'excutive family suite.jpg',
      price: 450,
      features: ['King Bed', 'Sofa Bed', 'Living Area', 'Executive Services'],
      maxGuests: 6,
      size: 75.0,
    ),
  ];
}

List<RoomModel> getPlazaMeetingRooms() {
  return [
    RoomModel(
      id: 'meeting_4',
      name: 'Omar El Khayyam',
      description: 'Classic and elegant hall suitable for various social and business events.',
      imageUrl: 'Omar El khayyam.jpg',
      price: 700,
      features: ['Waitlist Available', 'AV Setup', 'Natural Light', 'Sound System'],
      maxGuests: 150,
      size: 180.0,
    ),
    RoomModel(
      id: 'meeting_5',
      name: 'Isis',
      description: 'Versatile space perfect for team meetings and presentations.',
      imageUrl: 'Isis.jpg',
      price: 400,
      features: ['WiFi', 'Air Conditioning', 'Boardroom Style', 'Whiteboard'],
      maxGuests: 40,
      size: 60.0,
    ),
    RoomModel(
      id: 'meeting_6',
      name: 'Aton',
      description: 'Professional conference space with modern amenities.',
      imageUrl: 'Aton.jpg',
      price: 450,
      features: ['Smart TV', 'HDMI Connection', 'Ergonomic Chairs', 'Tea/Coffee'],
      maxGuests: 30,
      size: 55.0,
    ),
    RoomModel(
      id: 'meeting_7',
      name: 'Ramses',
      description: 'A majestic hall for significant events and gatherings.',
      imageUrl: 'Ramses.jpg',
      price: 1200,
      features: ['300+ Guests', 'Luxury Seating', 'Stage', 'VIP Area'],
      maxGuests: 300,
      size: 400.0,
    ),
    RoomModel(
      id: 'meeting_8',
      name: 'Cleopatra',
      description: 'An elegant suite for exclusive and private meetings.',
      imageUrl: 'Cleopatra.jpg',
      price: 600,
      features: ['Private Lounge', 'Concierge', 'High-speed WiFi', 'Premium Catering'],
      maxGuests: 20,
      size: 80.0,
    ),
    RoomModel(
      id: 'meeting_9',
      name: 'Anni & Anni Annex',
      description: 'A modern annex for flexible event hosting.',
      imageUrl: 'Anni&Anni -anex.jpg',
      price: 350,
      features: ['Flexible Seating', 'Easy Access', 'Projector', 'WiFi'],
      maxGuests: 50,
      size: 70.0,
    ),
    RoomModel(
      id: 'meeting_10',
      name: 'Tut',
      description: 'Compact and functional room for small meetings.',
      imageUrl: 'Tut.jpg',
      price: 300,
      features: ['Private', 'Whiteboard', 'Climate Control', 'WiFi'],
      maxGuests: 12,
      size: 35.0,
    ),
  ];
}
