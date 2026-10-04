import 'package:triumph_hotels/models/hotel_model.dart';
import 'package:triumph_hotels/models/restaurant_model.dart';
import 'package:triumph_hotels/models/meeting_room_model.dart';
import 'package:triumph_hotels/models/event_model.dart';
import 'package:triumph_hotels/services/api_client.dart';

class HotelService {
  final ApiClient _apiClient = ApiClient();

  Future<List<HotelModel>> getHotels() async {
    final response = await _apiClient.get('/hotels/');
    
    if (response is List) {
      return response.map((json) => HotelModel.fromJson(json)).toList();
    } else {
      throw ApiException('Unexpected response format for hotels list');
    }
  }

  Future<HotelModel> getHotelDetail(String slug) async {
    final response = await _apiClient.get('/hotels/$slug/');
    
    if (response is Map<String, dynamic>) {
      return HotelModel.fromJson(response);
    } else {
      throw ApiException('Unexpected response format for hotel detail');
    }
  }

  Future<List<Offer>> getHotelOffers(String slug) async {
    final response = await _apiClient.get('/hotels/$slug/offers/');
    
    if (response is List) {
      return response.map((json) => Offer.fromJson(json)).toList();
    } else {
      throw ApiException('Unexpected response format for hotel offers');
    }
  }

  Future<List<RestaurantModel>> getHotelRestaurants(String slug) async {
    final response = await _apiClient.get('/hotels/$slug/restaurants/');
    
    if (response is List) {
      return response.map((json) => RestaurantModel.fromJson(json)).toList();
    } else {
      throw ApiException('Unexpected response format for hotel restaurants');
    }
  }

  Future<RestaurantModel> getRestaurantDetail(String hotelSlug, String restaurantSlug) async {
    final response = await _apiClient.get('/hotels/$hotelSlug/restaurants/$restaurantSlug/');
    
    if (response is Map<String, dynamic>) {
      return RestaurantModel.fromJson(response);
    } else {
      throw ApiException('Unexpected response format for restaurant detail');
    }
  }

  Future<List<MeetingRoomModel>> getHotelMeetingRooms(String slug) async {
    final response = await _apiClient.getHotelMeetingRooms(slug);
    return response.map((json) => MeetingRoomModel.fromJson(json)).toList();
  }

  Future<MeetingRoomModel> getMeetingRoomDetail(String hotelSlug, String meetingRoomSlug) async {
    final response = await _apiClient.getMeetingRoomDetail(hotelSlug, meetingRoomSlug);
    
    if (response is Map<String, dynamic>) {
      return MeetingRoomModel.fromJson(response);
    } else {
      throw ApiException('Unexpected response format for meeting room detail');
    }
  }

  Future<List<EventModel>> getHotelEvents(String slug) async {
    final response = await _apiClient.getHotelEvents(slug);
    return response.map((json) => EventModel.fromJson(json)).toList();
  }

  Future<EventModel> getEventDetail(String hotelSlug, int eventId) async {
    final data = await _apiClient.getEventDetail(hotelSlug, eventId);
    return EventModel.fromJson(data);
  }
}
