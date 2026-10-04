import 'package:flutter/material.dart';

class ServiceModel {
  final String name;
  final String description;
  final IconData icon;

  ServiceModel({
    required this.name,
    required this.description,
    required this.icon,
  });
}

// Predefined services with descriptions
List<ServiceModel> getAllServices() {
  return [
    ServiceModel(
      name: 'Free WiFi',
      description: 'High-speed wireless internet available throughout the hotel',
      icon: Icons.wifi,
    ),
    ServiceModel(
      name: 'Airport Shuttle',
      description: 'Complimentary airport transfer service available',
      icon: Icons.flight_land,
    ),
    ServiceModel(
      name: '24/7 Room Service',
      description: 'Round-the-clock dining and concierge services',
      icon: Icons.room_service,
    ),
    ServiceModel(
      name: 'Valet Parking',
      description: 'Secure valet parking for all guests',
      icon: Icons.local_parking,
    ),
    ServiceModel(
      name: 'Laundry Service',
      description: 'Professional laundry and dry cleaning services',
      icon: Icons.local_laundry_service,
    ),
    ServiceModel(
      name: 'Swimming Pool',
      description: 'Outdoor heated pool with poolside bar',
      icon: Icons.pool,
    ),
    ServiceModel(
      name: 'Fitness Center',
      description: 'State-of-the-art gym equipment available 24/7',
      icon: Icons.fitness_center,
    ),
    ServiceModel(
      name: 'Spa & Wellness',
      description: 'Full-service spa with massage and wellness treatments',
      icon: Icons.spa,
    ),
    ServiceModel(
      name: 'Fine Dining Restaurant',
      description: 'Award-winning restaurant serving international cuisine',
      icon: Icons.restaurant,
    ),
    ServiceModel(
      name: 'Lounge Bar',
      description: 'Elegant bar with premium cocktails and live music',
      icon: Icons.local_bar,
    ),
    ServiceModel(
      name: 'Pet Friendly',
      description: 'Welcome facilities for your furry companions',
      icon: Icons.pets,
    ),
    ServiceModel(
      name: 'Business Center',
      description: 'Fully equipped business center with meeting rooms',
      icon: Icons.business_center,
    ),
    ServiceModel(
      name: 'ATM On-site',
      description: '24-hour ATM available in the lobby',
      icon: Icons.atm,
    ),
    ServiceModel(
      name: 'Concierge Service',
      description: 'Professional concierge for tours and reservations',
      icon: Icons.room_service,
    ),
    ServiceModel(
      name: 'Complimentary Breakfast',
      description: 'Buffet breakfast included with room rate',
      icon: Icons.free_breakfast,
    ),
    ServiceModel(
      name: 'Room Service',
      description: '24-hour in-room dining and beverage service',
      icon: Icons.room_service,
    ),
    ServiceModel(
      name: 'Limousine Service',
      description: 'Premium luxury transportation with professional chauffeur',
      icon: Icons.airport_shuttle,
    ),
    ServiceModel(
      name: 'Wheelchair Friendly',
      description: 'Full accessibility features and wheelchair access',
      icon: Icons.accessible,
    ),
    ServiceModel(
      name: 'Bazaar',
      description: 'Traditional market with local crafts and souvenirs',
      icon: Icons.store,
    ),
  ];
}
