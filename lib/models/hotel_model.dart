import 'package:triumph_hotels/models/room_model.dart';
import 'package:triumph_hotels/models/restaurant_model.dart';
import 'package:triumph_hotels/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';

class SocialLink {
  final String platform;
  final String url;
  final String? icon;

  SocialLink({required this.platform, required this.url, this.icon});

  factory SocialLink.fromJson(Map<String, dynamic> json) {
    return SocialLink(
      platform: json['platform'] ?? json['name'] ?? json['title'] ?? json['label'] ?? '',
      url: json['url'] ?? json['link'] ?? json['value'] ?? '',
      icon: json['icon'] ?? json['logo'] ?? json['image'] ?? json['icon_url'] ?? json['logo_url'],
    );
  }

  /// Returns a clean, absolute URL for the contact logo/icon if available.
  String? get cleanIconUrl {
    if (icon == null || icon!.trim().isEmpty) return null;
    final trimmed = icon!.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('/')) {
      return 'https://www.triumphhotel.com$trimmed';
    }
    return 'https://www.triumphhotel.com/$trimmed';
  }

  Map<String, dynamic> toJson() => {
    'platform': platform,
    'url': url,
    'icon': icon,
  };
}

class HotelImage {
  final int id;
  final String image;
  final String? caption;

  HotelImage({required this.id, required this.image, this.caption});

  factory HotelImage.fromJson(Map<String, dynamic> json) {
    return HotelImage(
      id: json['id'] ?? 0,
      image: json['image'] ?? '',
      caption: json['caption'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'image': image,
    'caption': caption,
  };
}

class Review {
  final int id;
  final String name;
  final String? profilePicture;
  final int rating;
  final String comment;
  final String? viewLink;
  final String? createdAt;

  Review({
    required this.id,
    required this.name,
    this.profilePicture,
    required this.rating,
    required this.comment,
    this.viewLink,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      profilePicture: json['profile_picture'],
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      viewLink: json['view_link'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'profile_picture': profilePicture,
    'rating': rating,
    'comment': comment,
    'view_link': viewLink,
    'created_at': createdAt,
  };
}

class Offer {
  final int id;
  final String title;
  final String description;
  final String? imageCover;
  final String? imageCard;
  final String? discountPercentage;
  final String? validityPeriod;
  final String? offerCode;
  final String? startDate;
  final String? endDate;
  final String? bookingLink;
  final bool isFeatured;
  final bool isActive;

  Offer({
    required this.id,
    required this.title,
    required this.description,
    this.imageCover,
    this.imageCard,
    this.discountPercentage,
    this.validityPeriod,
    this.offerCode,
    this.startDate,
    this.endDate,
    this.bookingLink,
    this.isFeatured = false,
    this.isActive = true,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageCover: json['image_cover'],
      imageCard: json['image_card'],
      discountPercentage: json['discount_percentage']?.toString(),
      validityPeriod: json['validity_period'],
      offerCode: json['offer_code'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      bookingLink: json['booking_link'],
      isFeatured: json['is_featured'] ?? false,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'image_cover': imageCover,
    'image_card': imageCard,
    'discount_percentage': discountPercentage,
    'validity_period': validityPeriod,
    'offer_code': offerCode,
    'start_date': startDate,
    'end_date': endDate,
    'booking_link': bookingLink,
    'is_featured': isFeatured,
    'is_active': isActive,
  };
}

class HotelServiceItem {
  final int id;
  final String title;
  final String description;
  final String? icon;
  final String? image;
  final String? price;
  final String? pricingType;
  final String? priceCurrency;
  final bool featured;
  final bool isActive;

  HotelServiceItem({
    required this.id,
    required this.title,
    required this.description,
    this.icon,
    this.image,
    this.price,
    this.pricingType,
    this.priceCurrency,
    this.featured = false,
    this.isActive = true,
  });

  factory HotelServiceItem.fromJson(Map<String, dynamic> json) {
    return HotelServiceItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'],
      image: json['image'],
      price: json['price']?.toString(),
      pricingType: json['pricing_type'],
      priceCurrency: json['price_currency'],
      featured: json['featured'] ?? false,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'icon': icon,
    'image': image,
    'price': price,
    'pricing_type': pricingType,
    'price_currency': priceCurrency,
    'featured': featured,
    'is_active': isActive,
  };
}

class Facility {
  final int id;
  final String? type;
  final String name;
  final String? title;
  final String description;
  final String? shortNote1;
  final String? shortNote2;
  final String? shortNote3;
  final String? image;
  final String? icon;
  final bool isFeatured;
  final bool isActive;
  final List<HotelImage>? images;

  Facility({
    required this.id,
    this.type,
    required this.name,
    this.title,
    required this.description,
    this.shortNote1,
    this.shortNote2,
    this.shortNote3,
    this.image,
    this.icon,
    this.isFeatured = false,
    this.isActive = true,
    this.images,
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      id: json['id'] ?? 0,
      type: json['type'],
      name: json['name'] ?? '',
      title: json['title'],
      description: json['description'] ?? '',
      shortNote1: json['short_note_1'],
      shortNote2: json['short_note_2'],
      shortNote3: json['short_note_3'],
      image: json['image'],
      icon: json['icon'],
      isFeatured: json['is_featured'] ?? false,
      isActive: json['is_active'] ?? true,
      images: json['images'] != null ? 
        (json['images'] as List).map((e) => HotelImage.fromJson(e)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'name': name,
    'title': title,
    'description': description,
    'short_note_1': shortNote1,
    'short_note_2': shortNote2,
    'short_note_3': shortNote3,
    'image': image,
    'icon': icon,
    'is_featured': isFeatured,
    'is_active': isActive,
    'images': images?.map((e) => e.toJson()).toList(),
  };
}

class GalleryItem {
  final int id;
  final String title;
  final String galleryType;
  final String? image;
  final String? videoUrl;
  final String? videoFile;
  final String? youtubeThumbnailUrl;
  final String? embedVideoUrl;
  final String? createdAt;
  final String? category;

  GalleryItem({
    required this.id,
    required this.title,
    required this.galleryType,
    this.image,
    this.videoUrl,
    this.videoFile,
    this.youtubeThumbnailUrl,
    this.embedVideoUrl,
    this.createdAt,
    this.category,
  });

  factory GalleryItem.fromJson(Map<String, dynamic> json) {
    return GalleryItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      galleryType: json['gallery_type'] ?? 'image',
      image: json['image'],
      videoUrl: json['video_url'],
      videoFile: json['video_file'],
      youtubeThumbnailUrl: json['youtube_thumbnail_url'],
      embedVideoUrl: json['embed_video_url'],
      createdAt: json['created_at'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'gallery_type': galleryType,
    'image': image,
    'video_url': videoUrl,
    'video_file': videoFile,
    'youtube_thumbnail_url': youtubeThumbnailUrl,
    'embed_video_url': embedVideoUrl,
    'created_at': createdAt,
    'category': category,
  };
}

class WelcomeMessage {
  final int id;
  final String title;
  final String description;
  final String? image;
  final String? message;
  final String? locationInfo;

  WelcomeMessage({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    this.message,
    this.locationInfo,
  });

  factory WelcomeMessage.fromJson(Map<String, dynamic> json) {
    return WelcomeMessage(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'],
      message: json['message'],
      locationInfo: json['location_info'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'image': image,
    'message': message,
    'location_info': locationInfo,
  };
}

class Banner {
  final int id;
  final String page;
  final String image;
  final String? title;
  final String? subtitle;

  Banner({
    required this.id,
    required this.page,
    required this.image,
    this.title,
    this.subtitle,
  });

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      id: json['id'] ?? 0,
      page: json['page'] ?? '',
      image: json['image'] ?? '',
      title: json['title'],
      subtitle: json['subtitle'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'page': page,
    'image': image,
    'title': title,
    'subtitle': subtitle,
  };
}

class HotelModel {
  final String id;
  final String name; // API data (English fallback)
  final String? nameAr; // API data (Arabic)
  final String brief; // API data (English fallback)
  final String? briefAr; // API data (Arabic)
  final String description; // API data (English fallback)
  final String? descriptionAr; // API data (Arabic)
  final String address; // API data (English fallback)
  final String? addressAr; // API data (Arabic)
  final String imageUrl;
  final String logoUrl;
  final String? slug;
  final String? slogan;
  final int? starRating;
  final String? city;
  final String? country;
  final String? phone;
  final String? whats;
  final String? email;
  final String? location;
  final String? mapEmbedUrl;
  final String? factSheet;
  final List<SocialLink>? socialLinks;
  final List<HotelImage>? hotelImages;
  final List<Review>? reviews;
  final List<Offer>? offers;
  final List<HotelServiceItem>? hotelServices;
  final List<Facility>? facilities;
  final List<GalleryItem>? galleryItems;
  final List<WelcomeMessage>? welcomeMessages;
  final List<Banner>? banners;
  final List<String> services;
  final List<String> gallery;
  final List<RoomModel>? rooms;
  final List<RoomModel>? meetingRooms;
  final List<RestaurantModel>? restaurants;

  HotelModel({
    required this.id,
    required this.name,
    this.nameAr,
    required this.brief,
    this.briefAr,
    required this.description,
    this.descriptionAr,
    required this.address,
    this.addressAr,
    required this.imageUrl,
    required this.logoUrl,
    this.slug,
    this.slogan,
    this.starRating,
    this.city,
    this.country,
    this.phone,
    this.whats,
    this.email,
    this.location,
    this.mapEmbedUrl,
    this.factSheet,
    this.socialLinks,
    this.hotelImages,
    this.reviews,
    this.offers,
    this.hotelServices,
    this.facilities,
    this.galleryItems,
    this.welcomeMessages,
    this.banners,
    required this.services,
    required this.gallery,
    this.rooms,
    this.meetingRooms,
    this.restaurants,
  });

  // Smart localization methods
  String getLocalizedName(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    
    // Priority 1: Use API data if available
    if (locale == 'ar' && nameAr != null && nameAr!.isNotEmpty) return nameAr!;
    
    // Priority 2: Fallback to localization keys
    final fallback = _getLocalizationFallback(context, 'name');
    if (fallback.isNotEmpty) return fallback;
    
    // Priority 3: Use default API data
    return name;
  }

  String getLocalizedBrief(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    
    // Priority 1: Use API data if available
    if (locale == 'ar' && briefAr != null && briefAr!.isNotEmpty) return briefAr!;
    
    // Priority 2: Fallback to localization keys
    final fallback = _getLocalizationFallback(context, 'brief');
    if (fallback.isNotEmpty) return fallback;
    
    // Priority 3: Use default API data
    return brief;
  }

  String getLocalizedDescription(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    
    // Priority 1: Use API data if available
    if (locale == 'ar' && descriptionAr != null && descriptionAr!.isNotEmpty) return descriptionAr!;
    
    // Priority 2: Fallback to localization keys
    final fallback = _getLocalizationFallback(context, 'description');
    if (fallback.isNotEmpty) return fallback;
    
    // Priority 3: Use default API data
    return description;
  }

  String getLocalizedAddress(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    
    // Priority 1: Use API data if available
    if (locale == 'ar' && addressAr != null && addressAr!.isNotEmpty) return addressAr!;
    
    // Priority 2: Fallback to localization keys
    final fallback = _getLocalizationFallback(context, 'address');
    if (fallback.isNotEmpty) return fallback;
    
    // Priority 3: Use default API data
    return address;
  }

  /// Finds a banner by page name or matching a list of candidate names.
  Banner? getBanner(dynamic pageOrPages) {
    if (banners == null || banners!.isEmpty) return null;
    if (pageOrPages is String) {
      final target = pageOrPages.toLowerCase().trim();
      for (final b in banners!) {
        if (b.page.toLowerCase().trim() == target) return b;
      }
    } else if (pageOrPages is Iterable<String>) {
      final targets = pageOrPages.map((p) => p.toLowerCase().trim()).toSet();
      for (final b in banners!) {
        if (targets.contains(b.page.toLowerCase().trim())) return b;
      }
    }
    return null;
  }

  /// Gets the clean banner image URL by page candidate names.
  String? getBannerImage(dynamic pageOrPages) {
    final banner = getBanner(pageOrPages);
    if (banner == null || banner.image.trim().isEmpty) return null;
    String cleanUrl = banner.image.trim();
    if (cleanUrl.startsWith('/')) {
      cleanUrl = 'https://www.triumphhotel.com$cleanUrl';
    }
    return cleanUrl;
  }

  /// Extracts latitude and longitude as (lat, lng) from mapEmbedUrl,
  /// or known hotel fallback, or from location string.
  (double, double) get coordinates {
    // 1. Priority: Extract exact coordinates from mapEmbedUrl
    if (mapEmbedUrl != null && mapEmbedUrl!.isNotEmpty) {
      // Look for Google Maps protobuf format !3d<lat> and !2d<lng>
      final latMatch = RegExp(r'!3d(-?\d+(?:\.\d+)?)').firstMatch(mapEmbedUrl!);
      final lngMatch = RegExp(r'!2d(-?\d+(?:\.\d+)?)').firstMatch(mapEmbedUrl!);
      if (latMatch != null && lngMatch != null) {
        final lat = double.tryParse(latMatch.group(1)!);
        final lng = double.tryParse(lngMatch.group(1)!);
        if (lat != null && lng != null && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
          return (lat, lng);
        }
      }

      // Look for query parameters: ?q=lat,lng or &ll=lat,lng or center=lat,lng
      final queryMatch = RegExp(r'[?&](?:q|ll|center)=(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)').firstMatch(mapEmbedUrl!);
      if (queryMatch != null) {
        final lat = double.tryParse(queryMatch.group(1)!);
        final lng = double.tryParse(queryMatch.group(2)!);
        if (lat != null && lng != null && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
          return (lat, lng);
        }
      }
    }

    // 2. Known hotel identifiers (slug, id, name)
    // Note: The backend CMS sometimes duplicates the New Cairo location string
    // across all hotels. We match known hotels first to avoid attributing New Cairo
    // coordinates to Plaza or White Sands.
    final lowerSlug = (slug ?? '').toLowerCase();
    final lowerName = name.toLowerCase();

    // Triumph Plaza Hotel (Heliopolis, Cairo)
    if (id == '1' || id == '15' || lowerSlug.contains('plaza') || lowerName.contains('plaza')) {
      return (30.0862166, 31.3032458);
    }

    // Triumph White Sands (El Gharam Beach, Marsa Matrouh)
    if (id == '3' || id == '16' || lowerSlug.contains('white') || lowerSlug.contains('sand') ||
        lowerSlug.contains('matrouh') || lowerName.contains('white') || lowerName.contains('sand')) {
      return (31.3626605, 27.2185502);
    }

    // Triumph Luxury Hotel (Fifth Settlement, New Cairo)
    if (id == '2' || id == '14' || lowerSlug.contains('luxury') || lowerName.contains('luxury')) {
      return (30.0033427, 31.3986397);
    }

    // 3. Extract from location string if it didn't match known hotels
    if (location != null && location!.isNotEmpty) {
      final latMatch = RegExp(r'Latitude[:\s]+(-?\d+(?:\.\d+)?)', caseSensitive: false).firstMatch(location!);
      final lngMatch = RegExp(r'Longitude[:\s]+(-?\d+(?:\.\d+)?)', caseSensitive: false).firstMatch(location!);
      if (latMatch != null && lngMatch != null) {
        final lat = double.tryParse(latMatch.group(1)!);
        final lng = double.tryParse(lngMatch.group(1)!);
        if (lat != null && lng != null && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
          return (lat, lng);
        }
      }

      final commaMatch = RegExp(r'(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)').firstMatch(location!);
      if (commaMatch != null) {
        final lat = double.tryParse(commaMatch.group(1)!);
        final lng = double.tryParse(commaMatch.group(2)!);
        if (lat != null && lng != null && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
          return (lat, lng);
        }
      }
    }

    // 4. Default fallback to Triumph Luxury Hotel
    return (30.0033427, 31.3986397);
  }

  double get latitude => coordinates.$1;
  double get longitude => coordinates.$2;

  // Helper method for localization fallbacks
  String _getLocalizationFallback(BuildContext context, String fieldType) {
    final localizations = AppLocalizations.of(context)!;
    
    switch (id) {
      case '1':
      case '15': // Triumph Plaza
        switch (fieldType) {
          case 'name': return localizations.triumphPlazaHotel;
          case 'brief': return localizations.plazaBrief;
          case 'description': return localizations.triumphPlazaDescription;
          case 'address': return localizations.plazaAddress;
          default: return '';
        }
      case '2':
      case '14': // Triumph Luxury
        switch (fieldType) {
          case 'name': return localizations.triumphLuxuryHotel;
          case 'brief': return localizations.luxuryBrief;
          case 'description': return localizations.triumphLuxuryDescription;
          case 'address': return localizations.luxuryAddress;
          default: return '';
        }
      case '3':
      case '16': // Triumph White Sands
        switch (fieldType) {
          case 'name': return localizations.triumphWhiteSands;
          case 'brief': return localizations.whiteSandsBrief;
          case 'description': return localizations.triumphWhiteSandsDescription;
          case 'address': return localizations.whiteSandsAddress;
          default: return '';
        }
      default:
        return '';
    }
  }

  // Factory method for creating from API response
  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['name_en'] ?? json['title'] ?? '',
      nameAr: json['name_ar'],
      brief: json['brief'] ?? json['brief_en'] ?? json['slogan'] ?? '',
      briefAr: json['brief_ar'],
      description: json['description'] ?? json['description_en'] ?? '',
      descriptionAr: json['description_ar'],
      address: json['address'] ?? json['address_en'] ?? 
               (json['city'] != null && json['country'] != null ? "${json['city']}, ${json['country']}" : ''),
      addressAr: json['address_ar'],
      imageUrl: json['image_cover'] ?? json['imageUrl'] ?? json['image_url'] ?? '',
      logoUrl: json['logo'] ?? json['logoUrl'] ?? json['logo_url'] ?? '',
      slug: json['slug'],
      slogan: json['slogan'],
      starRating: json['star_rating'] ?? json['starRating'],
      city: json['city'],
      country: json['country'],
      phone: json['phone'],
      whats: json['whats'],
      email: json['email'],
      location: json['location'],
      mapEmbedUrl: json['map_embed_url'],
      factSheet: json['fact_sheet'],
      socialLinks: (json['social_links'] ?? json['socials'] ?? json['contacts'] ?? json['social_media']) != null ? 
        ((json['social_links'] ?? json['socials'] ?? json['contacts'] ?? json['social_media']) as List).map((e) => SocialLink.fromJson(e)).toList() : null,
      hotelImages: json['hotel_images'] != null ? 
        (json['hotel_images'] as List).map((e) => HotelImage.fromJson(e)).toList() : null,
      reviews: json['reviews'] != null ? 
        (json['reviews'] as List).map((e) => Review.fromJson(e)).toList() : null,
      hotelServices: json['hotel_services'] != null ? 
        (json['hotel_services'] as List).map((e) => HotelServiceItem.fromJson(e)).toList() : null,
      facilities: json['facilities'] != null ? 
        (json['facilities'] as List).map((e) => Facility.fromJson(e)).toList() : null,
      galleryItems: json['gallery_items'] != null ? 
        (json['gallery_items'] as List).map((e) => GalleryItem.fromJson(e)).toList() : null,
      welcomeMessages: json['welcome_messages'] != null ? 
        (json['welcome_messages'] as List).map((e) => WelcomeMessage.fromJson(e)).toList() : null,
      banners: json['banners'] != null ? 
        (json['banners'] as List).map((e) => Banner.fromJson(e)).toList() : null,
      services: List<String>.from(json['services'] ?? []),
      gallery: List<String>.from(json['gallery'] ?? []),
      rooms: json['rooms'] != null ? 
        (json['rooms'] as List).map((e) => RoomModel.fromJson(e)).toList() : null,
      meetingRooms: json['meetingRooms'] != null ? 
        (json['meetingRooms'] as List).map((e) => RoomModel.fromJson(e)).toList() : null,
      restaurants: json['restaurants'] != null ? 
        (json['restaurants'] as List).map((e) => RestaurantModel.fromJson(e)).toList() : null,
    );
  }

  // Method to convert to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'brief': brief,
      'brief_ar': briefAr,
      'description': description,
      'description_ar': descriptionAr,
      'address': address,
      'address_ar': addressAr,
      'imageUrl': imageUrl,
      'logoUrl': logoUrl,
      'slug': slug,
      'slogan': slogan,
      'star_rating': starRating,
      'city': city,
      'country': country,
      'phone': phone,
      'whats': whats,
      'email': email,
      'location': location,
      'map_embed_url': mapEmbedUrl,
      'fact_sheet': factSheet,
      'social_links': socialLinks?.map((e) => e.toJson()).toList(),
      'hotel_images': hotelImages?.map((e) => e.toJson()).toList(),
      'reviews': reviews?.map((e) => e.toJson()).toList(),
      'offers': offers?.map((e) => e.toJson()).toList(),
      'hotel_services': hotelServices?.map((e) => e.toJson()).toList(),
      'facilities': facilities?.map((e) => e.toJson()).toList(),
      'gallery_items': galleryItems?.map((e) => e.toJson()).toList(),
      'welcome_messages': welcomeMessages?.map((e) => e.toJson()).toList(),
      'banners': banners?.map((e) => e.toJson()).toList(),
      'services': services,
      'gallery': gallery,
      'rooms': rooms?.map((e) => e.toJson()).toList(),
      'meetingRooms': meetingRooms?.map((e) => e.toJson()).toList(),
      'restaurants': restaurants?.map((e) => e.toJson()).toList(),
    };
  }
}
