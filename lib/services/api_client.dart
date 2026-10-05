import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode)';
  }
}

class ApiClient {
  // Local development URL
  //static const String baseUrl = 'http://192.168.10.175:8000/api/v1';
   static const String baseUrl = 'https://triumphhotel.com/api/v1';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final lang = prefs.getString('selected_language') ?? 'en';
    
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Accept-Language': lang,
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Token $token';
    }

    return headers;
  }

  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();

    try {
      final response = await http.get(url, headers: headers);
      return _processResponse(response);
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Future<dynamic> patch(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();

    try {
      final response = await http.patch(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Future<dynamic> patchMultipart(String endpoint, {Map<String, String>? fields, String? fileField, String? filePath}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    
    var request = http.MultipartRequest('PATCH', url);
    request.headers.addAll(headers);
    // Multipart requests handle their own content type
    request.headers.remove('Content-Type');

    if (fields != null) {
      request.fields.addAll(fields);
    }
    
    if (fileField != null && filePath != null && filePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _processResponse(response);
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  // Hotels & Rooms
  Future<List<dynamic>> getHotelOffers(String hotelSlug) async {
    return await get('/hotels/$hotelSlug/offers/');
  }

  Future<List<dynamic>> getHotelRooms(String hotelSlug) async {
    return await get('/hotels/$hotelSlug/rooms/');
  }

  Future<dynamic> getRoomDetail(String hotelSlug, String roomSlug) async {
    return await get('/hotels/$hotelSlug/rooms/$roomSlug/');
  }

  Future<List<dynamic>> getHotelRestaurants(String hotelSlug) async {
    return await get('/hotels/$hotelSlug/restaurants/');
  }

  Future<dynamic> getRestaurantDetail(String hotelSlug, String restaurantSlug) async {
    return await get('/hotels/$hotelSlug/restaurants/$restaurantSlug/');
  }

  Future<List<dynamic>> getHotelMeetingRooms(String hotelSlug) async {
    return await get('/hotels/$hotelSlug/meeting-rooms/');
  }

  Future<dynamic> getMeetingRoomDetail(String hotelSlug, String meetingRoomSlug) async {
    return await get('/hotels/$hotelSlug/meeting-rooms/$meetingRoomSlug/');
  }

  Future<List<dynamic>> getHotelEvents(String hotelSlug) async {
    return await get('/hotels/$hotelSlug/events/');
  }

  Future<dynamic> getEventDetail(String hotelSlug, int eventId) async {
    return await get('/hotels/$hotelSlug/events/$eventId/');
  }


  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return null;
    } else {
      String errorMessage = 'Something went wrong';
      try {
        final errorData = jsonDecode(response.body);
        // Extract error message from Django REST style response
        if (errorData is Map) {
          if (errorData.containsKey('detail')) {
            errorMessage = errorData['detail'];
          } else if (errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          } else {
            // Get first value of validation errors
            errorMessage = errorData.values.first is List 
              ? errorData.values.first[0].toString() 
              : errorData.values.first.toString();
          }
        }
      } catch (_) {
        errorMessage = response.body;
      }
      throw ApiException(errorMessage, response.statusCode);
    }
  }
}
