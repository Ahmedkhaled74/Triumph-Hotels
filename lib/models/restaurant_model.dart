class RestaurantModel {
  final String id;
  final String name;
  final String slug;
  final String? slogan;
  final String description;
  final String? shortDescription;
  final String imageCover;
  final String cuisine;
  final String openingHours;
  final String? breakfastHours;
  final String? lunchHours;
  final String? dinnerHours;
  final String? dressCode;
  final int? noOfSeats;
  final bool terrace;
  final List<String> features;
  final int displayOrder;
  final List<RestaurantGalleryImage> galleryImages;
  final List<MenuCategory>? menuCategories;
  final RestaurantMenu? menu;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.slug,
    this.slogan,
    required this.description,
    this.shortDescription,
    required this.imageCover,
    required this.cuisine,
    required this.openingHours,
    this.breakfastHours,
    this.lunchHours,
    this.dinnerHours,
    this.dressCode,
    this.noOfSeats,
    this.terrace = false,
    required this.features,
    required this.displayOrder,
    this.galleryImages = const [],
    this.menuCategories,
    this.menu,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      slogan: json['slogan'],
      description: json['description'] ?? '',
      shortDescription: json['short_description'],
      imageCover: json['image_cover'] ?? json['imageUrl'] ?? json['image_url'] ?? '',
      cuisine: json['cuisine'] ?? '',
      openingHours: json['opening_hours'] ?? json['openingHours'] ?? '',
      breakfastHours: json['breakfast_hours'],
      lunchHours: json['lunch_hours'],
      dinnerHours: json['dinner_hours'],
      dressCode: json['dress_code'],
      noOfSeats: json['no_of_seats'],
      terrace: json['terrace'] ?? false,
      features: List<String>.from(json['features'] ?? []),
      displayOrder: json['display_order'] ?? 0,
      galleryImages: (json['gallery_images'] as List?)
              ?.map((e) => RestaurantGalleryImage.fromJson(e))
              .toList() ??
          [],
      menuCategories: (json['menu_categories'] as List?)
          ?.map((e) => MenuCategory.fromJson(e))
          .toList(),
      menu: json['menu'] != null ? RestaurantMenu.fromJson(json['menu']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'slogan': slogan,
      'description': description,
      'short_description': shortDescription,
      'image_cover': imageCover,
      'cuisine': cuisine,
      'opening_hours': openingHours,
      'breakfast_hours': breakfastHours,
      'lunch_hours': lunchHours,
      'dinner_hours': dinnerHours,
      'dress_code': dressCode,
      'no_of_seats': noOfSeats,
      'terrace': terrace,
      'features': features,
      'display_order': displayOrder,
    };
  }
}

class RestaurantGalleryImage {
  final int id;
  final String image;
  final String? caption;

  RestaurantGalleryImage({
    required this.id,
    required this.image,
    this.caption,
  });

  factory RestaurantGalleryImage.fromJson(Map<String, dynamic> json) {
    return RestaurantGalleryImage(
      id: json['id'] ?? 0,
      image: json['image'] ?? '',
      caption: json['caption'],
    );
  }
}

class MenuCategory {
  final int id;
  final String name;
  final String? description;
  final List<MenuItem> menuItems;

  MenuCategory({
    required this.id,
    required this.name,
    this.description,
    required this.menuItems,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      menuItems: (json['menu_items'] as List?)
              ?.map((e) => MenuItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class MenuItem {
  final int id;
  final String name;
  final String? description;
  final String price;
  final String? image;

  MenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.image,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: json['price']?.toString() ?? '0.00',
      image: json['image'],
    );
  }
}

class RestaurantMenu {
  final int id;
  final String? generalPdf;
  final String? breakfastPdf;
  final String? lunchPdf;
  final String? dinnerPdf;
  final String? beveragePdf;
  final String? offersPdf;

  RestaurantMenu({
    required this.id,
    this.generalPdf,
    this.breakfastPdf,
    this.lunchPdf,
    this.dinnerPdf,
    this.beveragePdf,
    this.offersPdf,
  });

  factory RestaurantMenu.fromJson(Map<String, dynamic> json) {
    return RestaurantMenu(
      id: json['id'] ?? 0,
      generalPdf: json['general_pdf'],
      breakfastPdf: json['breakfast_pdf'],
      lunchPdf: json['lunch_pdf'],
      dinnerPdf: json['dinner_pdf'],
      beveragePdf: json['beverage_pdf'],
      offersPdf: json['offers_pdf'],
    );
  }
}
