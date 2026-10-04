import 'package:triumph_hotels/core/constants/app_strings.dart';
import 'package:triumph_hotels/models/hotel_model.dart';
import 'package:triumph_hotels/models/room_model.dart';
import 'package:triumph_hotels/core/constants/app_images.dart';

import '../models/restaurant_model.dart';

List<HotelModel> getMockHotels() {
  return [
    HotelModel(
      id: '1',
      name: AppStrings.triumphPlaza,
      brief: 'Experience luxury in the heart of the city.',
      description: 'Located in the historic suburb of Heliopolis, Triumph Plaza Hotel offers an upscale hospitality experience focused on comfort, elegance, and memorable stays. Guests can enjoy fine dining, glamour, and a relaxing atmosphere designed for true comfort and perfection.',
      address: 'Heliopolis, Cairo, Egypt',
      imageUrl: AppImages.placeholderHotel1, // Replace with actual asset later
      logoUrl: AppImages.plazaLogo,
      services: [
        AppStrings.airportPickUp,
        AppStrings.freeWifi,
        AppStrings.atmCenter,
        AppStrings.concierge,
        AppStrings.parkingSpace,
        AppStrings.laundry,
        AppStrings.gym,
        AppStrings.spa,
        AppStrings.roomService,
        AppStrings.limousineService,
        AppStrings.wheelchairFriendly,
        AppStrings.bazaar,
      ],
      gallery: [
        'assets/images/plaza/img1.jpg',
        'assets/images/plaza/img2.jpg',
        'assets/images/plaza/img3.jpg',
        'assets/images/plaza/img4.jpg',
        'assets/images/plaza/img5.jpg',
        'assets/images/plaza/img6.jpg',
        'assets/images/plaza/img7.jpg',
        'assets/images/plaza/img8.jpg',
        'assets/images/plaza/img9.jpg',
        'assets/images/plaza/img10.jpg',
        'assets/images/plaza/img11.jpg',
        'assets/images/plaza/img12.jpg',
        'assets/images/plaza/img13.jpg',
        'assets/images/plaza/img14.jpg',
        'assets/images/plaza/img15.jpg',
        'assets/images/plaza/img16.jpg',
        'assets/images/plaza/img17.jpg',
        'assets/images/plaza/img18.jpg',
        'assets/images/plaza/img19.jpg',
        'assets/images/plaza/img20.jpg',
      ],
      rooms: getPlazaRooms(),
      meetingRooms: getPlazaMeetingRooms(),
      restaurants: getPlazaRestaurants(),
    ),
    HotelModel(
      id: '2',
      name: AppStrings.triumphLuxury,
      brief: 'A sanctuary of elegance and sophistication.',
      description: 'Indulge in the ultimate luxury experience at Triumph Luxury Hotel. Featuring exquisite design, gourmet dining, and a serene spa.',
      address: 'New Cairo, Egypt',
      imageUrl: AppImages.placeholderHotel2, // Replace with actual asset later
      logoUrl: AppImages.luxuryLogo,
      services: [
        AppStrings.airportPickUp,
        AppStrings.freeWifi,
        AppStrings.atmCenter,
        AppStrings.concierge,
        AppStrings.parkingSpace,
        AppStrings.laundry,
        AppStrings.gym,
        AppStrings.spa,
      ],
      gallery: [
        AppImages.placeholderHotel2,
        AppImages.placeholderHotel1,
        AppImages.placeholderHotel3,
      ],
      rooms: getLuxuryRooms(),
      meetingRooms: getLuxuryMeetingRooms(),
      restaurants: getLuxuryRestaurants(),
    ),
    HotelModel(
      id: '3',
      name: AppStrings.triumphWhiteSands,
      brief: 'Your perfect coastal getaway.',
      description: 'Relax by the sea at Triumph White Sands Hotel. Enjoy pristine beaches, crystal-clear waters, and luxurious accommodations.',
      address: 'North Coast, Egypt',
      imageUrl: AppImages.placeholderHotel3, // Replace with actual asset later
      logoUrl: AppImages.whiteSandsLogo,
      services: [
        AppStrings.airportPickUp,
        AppStrings.freeWifi,
        AppStrings.atmCenter,
        AppStrings.concierge,
        AppStrings.parkingSpace,
        AppStrings.laundry,
      ],
      gallery: [
        AppImages.placeholderHotel3,
        AppImages.placeholderHotel2,
      ],
      rooms: getWhiteSandsRooms(),
      meetingRooms: getWhiteSandsMeetingRooms(),
      restaurants: getWhiteSandsRestaurants(),
    ),
  ];
}

List<HotelModel> mockHotels = getMockHotels();

// Helper functions for room and restaurant data
List<RoomModel> getPlazaRooms() {
  // Return plaza rooms - implementation needed
  return [];
}

List<RoomModel> getPlazaMeetingRooms() {
  // Return plaza meeting rooms - implementation needed  
  return [];
}

List<RoomModel> getLuxuryRooms() {
  // Return luxury rooms - implementation needed
  return [];
}

List<RoomModel> getLuxuryMeetingRooms() {
  // Return luxury meeting rooms - implementation needed
  return [];
}

List<RoomModel> getWhiteSandsRooms() {
  // Return white sands rooms - implementation needed
  return [];
}

List<RoomModel> getWhiteSandsMeetingRooms() {
  // Return white sands meeting rooms - implementation needed
  return [];
}

List<RestaurantModel> getPlazaRestaurants() {
  // Return plaza restaurants - implementation needed
  return [];
}

List<RestaurantModel> getLuxuryRestaurants() {
  // Return luxury restaurants - implementation needed
  return [];
}

List<RestaurantModel> getWhiteSandsRestaurants() {
  // Return white sands restaurants - implementation needed
  return [];
}
