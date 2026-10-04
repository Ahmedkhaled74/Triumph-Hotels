import 'package:flutter/material.dart';
import 'package:triumph_hotels/models/hotel_model.dart';
import 'package:triumph_hotels/models/restaurant_model.dart';
import 'package:triumph_hotels/models/meeting_room_model.dart';
import 'package:triumph_hotels/models/event_model.dart';
import 'package:triumph_hotels/services/hotel_service.dart';
import 'package:triumph_hotels/services/api_client.dart';

class HotelProvider extends ChangeNotifier {
  final HotelService _hotelService = HotelService();
  
  List<HotelModel> _hotels = [];
  bool _isLoading = false;
  String? _errorMessage;

  final Map<String, HotelModel> _detailedHotels = {};
  final Map<String, List<Offer>> _hotelOffers = {};
  final Map<String, List<RestaurantModel>> _hotelRestaurants = {};
  final Map<String, RestaurantModel> _detailedRestaurants = {};
  final Map<String, List<MeetingRoomModel>> _hotelMeetingRooms = {};
  final Map<String, MeetingRoomModel> _detailedMeetingRooms = {};
  final Map<String, List<EventModel>> _hotelEvents = {};
  final Map<int, EventModel> _detailedEvents = {};
  
  List<HotelModel> get hotels => _hotels;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  HotelModel? getDetailedHotel(String slug) => _detailedHotels[slug];
  List<Offer>? getOffersForHotel(String slug) => _hotelOffers[slug];
  List<RestaurantModel>? getRestaurantsForHotel(String slug) => _hotelRestaurants[slug];
  RestaurantModel? getDetailedRestaurant(String slug) => _detailedRestaurants[slug];
  List<MeetingRoomModel>? getMeetingRoomsForHotel(String slug) => _hotelMeetingRooms[slug];
  MeetingRoomModel? getDetailedMeetingRoom(String slug) => _detailedMeetingRooms[slug];
  List<EventModel>? getEventsForHotel(String slug) => _hotelEvents[slug];
  EventModel? getDetailedEvent(int id) => _detailedEvents[id];

  Future<void> fetchHotels() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _hotels = await _hotelService.getHotels();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred while fetching hotels.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHotelDetail(String slug) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final hotel = await _hotelService.getHotelDetail(slug);
      _detailedHotels[slug] = hotel;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred while fetching hotel details.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHotelOffers(String slug) async {
    try {
      final offers = await _hotelService.getHotelOffers(slug);
      _hotelOffers[slug] = offers;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching offers for $slug: $e');
    }
  }

  Future<void> fetchHotelRestaurants(String slug) async {
    try {
      final restaurants = await _hotelService.getHotelRestaurants(slug);
      _hotelRestaurants[slug] = restaurants;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching restaurants for $slug: $e');
    }
  }

  Future<void> fetchRestaurantDetail(String hotelSlug, String restaurantSlug) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final restaurant = await _hotelService.getRestaurantDetail(hotelSlug, restaurantSlug);
      _detailedRestaurants[restaurantSlug] = restaurant;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred while fetching restaurant details.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHotelMeetingRooms(String slug) async {
    try {
      final meetingRooms = await _hotelService.getHotelMeetingRooms(slug);
      _hotelMeetingRooms[slug] = meetingRooms;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching meeting rooms for $slug: $e');
    }
  }

  Future<void> fetchMeetingRoomDetail(String hotelSlug, String meetingRoomSlug) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final meetingRoom = await _hotelService.getMeetingRoomDetail(hotelSlug, meetingRoomSlug);
      _detailedMeetingRooms[meetingRoomSlug] = meetingRoom;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred while fetching meeting room details.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHotelEvents(String slug) async {
    try {
      final events = await _hotelService.getHotelEvents(slug);
      _hotelEvents[slug] = events;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching events for $slug: $e');
    }
  }

  Future<void> fetchEventDetail(String hotelSlug, int eventId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final event = await _hotelService.getEventDetail(hotelSlug, eventId);
      _detailedEvents[eventId] = event;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred while fetching event details.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
