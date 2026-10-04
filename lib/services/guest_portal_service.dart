import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triumph_hotels/services/api_client.dart';

class GuestPortalService {
  // --- Session Expiration Callback ---
  static void Function(String url)? onSessionExpired;

  static const String _baseUrl = 'https://ticketx.triumphhotel.com';
  static const String _sessionKey = 'guest_session_id';
  static const String _accessTokenKey = 'guest_access_token';
  static const String _guestInfoKey = 'guest_info';
  static const String _languageKey = 'guest_language';

  String _language = 'en';

  // ─── Session Helpers ────────────────────────────────────────────────────────

  Future<String?> getSavedSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    // Fall back to accessToken if sessionId is missing — both are valid session identifiers
    return prefs.getString(_sessionKey) ?? prefs.getString(_accessTokenKey);
  }

  Future<String?> getSavedAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<Map<String, dynamic>?> getSavedGuestInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_guestInfoKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveSession(
    String sessionId,
    Map<String, dynamic> guestInfo, {
    String? accessToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, sessionId);
    await prefs.setString(_guestInfoKey, jsonEncode(guestInfo));
    // Save accessToken separately — used for Bearer auth on all API calls
    final tokenToSave = accessToken ?? sessionId;
    await prefs.setString(_accessTokenKey, tokenToSave);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_guestInfoKey);
  }

  // ─── Language Helpers ───────────────────────────────────────────────────────

  Future<String> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _language = prefs.getString(_languageKey) ?? 'en';
    return _language;
  }

  Future<void> saveLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, lang);
  }

  Future<bool> updateGuestLanguage(String language) async {
    final sessionId = await getSavedSessionId();
    if (sessionId == null) return false;
    try {
      final response = await post('/api/guest/language', body: {
        'sessionId': sessionId,
        'language': language,
      });
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // ─── Response Processor ─────────────────────────────────────────────────────

  dynamic _process(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        try {
          return jsonDecode(response.body);
        } catch (_) {
          return {'data': response.body}; // Handle plain text success
        }
      }
      return null;
    }
    if (response.statusCode == 401 || response.statusCode == 403) {
      final urlStr = response.request?.url.toString() ?? 'unknown';
      // Ignore 401s on laundry endpoints because the backend might be broken for them
      if (!urlStr.contains('/laundry/')) {
        if (onSessionExpired != null) {
          onSessionExpired!(urlStr);
        }
      }
    }

    String msg = 'Something went wrong (${response.statusCode})';
    try {
      final err = jsonDecode(response.body);
      if (err is Map) {
        if (err.containsKey('message')) {
          msg = err['message'].toString();
        } else if (err.containsKey('error')) {
          msg = err['error'].toString();
        } else if (err.containsKey('detail')) {
          msg = err['detail'].toString();
        } else if (err.containsKey('non_field_errors')) {
          msg = (err['non_field_errors'] as List).first.toString();
        } else {
          msg = err.values.first?.toString() ?? msg;
        }
      }
    } catch (_) {
      if (response.body.isNotEmpty && !response.body.contains('<html')) {
        msg = response.body;
      }
    }
    throw ApiException(msg, response.statusCode);
  }

  // ─── Base headers for all requests ──────────────────────────────────────────

  Future<Map<String, String>> _headers({String? sessionId, bool includeAuth = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('selected_language') ?? 'en';
    
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Accept-Language': lang,
      'X-Requested-With': 'XMLHttpRequest',
    };
    if (includeAuth) {
      // Use sessionId as the Bearer credential per backend expectations.
      // accessToken is only used as a query parameter for verifySession.
      final sid = sessionId ?? await getSavedSessionId();
      if (sid != null && sid.isNotEmpty) {
        headers['Authorization'] = 'Bearer $sid';
      }
    }
    return headers;
  }

  // ─── API 1.2 Login by Room (Recommended) ────────────────────────────────────
  //
  // POST /api/guest/login-by-room
  // Body: { roomNumber, resvNameId, hotelId? }
  // Response: { sessionId, accessToken, guestInfo: { name, room, email, phone, checkIn, checkOut } }

  Future<Map<String, dynamic>> loginByRoom({
    required String roomNumber,
    required String resvNameId,
    String? hotelId,
  }) async {
    final url = Uri.parse('$_baseUrl/api/guest/login-by-room');

    final body = <String, dynamic>{
      'roomNumber': roomNumber,
      'resvNameId': resvNameId,
    };
    if (hotelId != null) body['hotelId'] = hotelId;

    // Use a persistent client so cookies (including csrftoken) are carried
    // across the redirect chain if Django uses one.
    final client = _CsrfAwareClient();
    try {
      final response = await client.post(
        url,
        headers: await _headers(includeAuth: false),
        body: jsonEncode(body),
      );

      print('=== LOGIN RESPONSE ===');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      print('======================');

      final data = _process(response) as Map<String, dynamic>;

      print('=== LOGIN RAW DATA KEYS: ${data.keys.toList()} ===');

      // sessionId is the session reference; accessToken is the Bearer auth credential
      final sessionId = data['sessionId']?.toString();
      final accessToken = data['accessToken']?.toString();

      // At least one must be present
      if ((sessionId == null || sessionId.isEmpty) && (accessToken == null || accessToken.isEmpty)) {
        throw ApiException('No session ID or access token returned from server');
      }

      final effectiveSessionId = sessionId ?? accessToken!;
      final effectiveToken = accessToken ?? sessionId!;

      // Save ALL returned data as guestInfo so no fields are lost
      final guestInfo = <String, dynamic>{};
      if (data['guestInfo'] is Map) {
        guestInfo.addAll(data['guestInfo'] as Map<String, dynamic>);
      }
      // Also save top-level fields that might carry guest details
      for (final key in ['name', 'guest_name', 'guestName', 'room', 'room_number', 'roomNumber',
       'checkIn', 'check_in', 'checkOut', 'check_out', 'email', 'phone']) {
        if (data.containsKey(key)) guestInfo[key] = data[key];
      }

      await _saveSession(effectiveSessionId, guestInfo, accessToken: effectiveToken);
      return data;
    } finally {
      client.close();
    }
  }

  // ─── API 1.3 Verify Session ──────────────────────────────────────────────────
  //
  // GET /api/guest/verify/:sessionId
  // Response: { valid: true, session: { room_number, guest_name, hotel_id } }

  Future<bool> verifySession(String sessionId) async {
    try {
      // Per API docs: GET /api/guest/verify/:sessionId?token={accessToken}
      final accessToken = await getSavedAccessToken();
      final queryToken = accessToken ?? sessionId;
      final url = Uri.parse('$_baseUrl/api/guest/verify/$sessionId?token=$queryToken');
      final headers = await _headers(includeAuth: false);
      final response = await http.get(url, headers: headers);
      final data = _process(response);
      return data != null && data['valid'] == true;
    } catch (_) {
      return false;
    }
  }

  // ─── API 2.2 Submit a Text-Only Request ────────────────────────────────────
  //
  // POST /api/guest/request
  // Body: { sessionId, category, title, priority }

  Future<Map<String, dynamic>> submitRequest({
    required String category,
    required String title,
    String priority = 'normal', // Valid TicketX values: normal
  }) async {
    final sessionId = await getSavedSessionId();
    if (sessionId == null) throw ApiException('No active session');

    final body = {
      'sessionId': sessionId,
      'category': category,
      'title': title,
      'description': title, // Prevent backend undefined error
      'text': title,        // Prevent backend undefined error
      'priority': priority,
    };

    // Make raw HTTP call so we can log the exact response including error body
    final url = Uri.parse('$_baseUrl/api/guest/request');
    final headers = await _headers(sessionId: sessionId);
    final client = http.Client();

    try {
      print('=== SUBMIT REQUEST ===');
      print('URL: $url');
      print('Body: ${jsonEncode(body)}');

      http.Response rawResponse;
      try {
        rawResponse = await client.post(url, headers: headers, body: jsonEncode(body));
      } catch (e, stack) {
        print('HTTP CLIENT ERROR: $e');
        print(stack);
        rethrow;
      }

      print('Status: ${rawResponse.statusCode}');
      print('Response Body: ${rawResponse.body}');
      print('======================');

      // If success, return parsed response
      if (rawResponse.statusCode >= 200 && rawResponse.statusCode < 300) {
        if (rawResponse.body.isNotEmpty) {
          try { return jsonDecode(rawResponse.body) as Map<String, dynamic>; }
          catch (_) { return {'success': true}; }
        }
        return {'success': true};
      }

      // For any error, throw with the real message from server
      String errMsg = 'Server error (${rawResponse.statusCode})';
      try {
        final err = jsonDecode(rawResponse.body);
        if (err is Map) {
          errMsg = (err['message'] ?? err['error'] ?? err['detail'] ?? errMsg).toString();
        }
      } catch (_) {
        if (rawResponse.body.isNotEmpty && !rawResponse.body.contains('<html')) {
          errMsg = rawResponse.body;
        }
      }
      throw ApiException(errMsg, rawResponse.statusCode);
    } finally {
      client.close();
    }
  }

  // ─── API 2.3 Submit a Smart Request (Multimedia) ───────────────────────────
  //
  // POST /api/guest/smart-request
  // Content-Type: multipart/form-data
  // Fields: sessionId, category, text (optional)
  // Files: photos (max 5), voice

  Future<Map<String, dynamic>> submitSmartRequest({
    required String category,
    String? text,
    List<String>? imagePaths,
    String? voicePath,
  }) async {
    final sessionId = await getSavedSessionId();
    if (sessionId == null) throw ApiException('No active session');

    final url = Uri.parse('$_baseUrl/api/guest/smart-request');
    final request = http.MultipartRequest('POST', url);

    // Standard headers
    final headers = await _headers(sessionId: sessionId);
    // Remove content-type so http.MultipartRequest can set it properly with boundary
    headers.remove('Content-Type'); 
    request.headers.addAll(headers);

    // Form Fields
    request.fields['sessionId'] = sessionId;
    request.fields['category'] = category;
    if (text != null && text.isNotEmpty) {
      request.fields['text'] = text;
      request.fields['title'] = text; // Some backends use 'title' field
      request.fields['description'] = text; // Prevent backend undefined error
    }

    // Attach Images
    if (imagePaths != null && imagePaths.isNotEmpty) {
      for (final path in imagePaths) {
        request.files.add(await http.MultipartFile.fromPath(
          'photos', 
          path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }
    }

    // Attach Voice
    if (voicePath != null && voicePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
        'voice', 
        voicePath,
        contentType: MediaType('audio', 'mp4'), // Using mp4 for m4a audio
      ));
    }

    print('=== SUBMIT SMART REQUEST ===');
    print('URL: $url');
    print('Fields: ${request.fields}');
    print('Files count: ${request.files.length}');

    final client = http.Client();
    try {
      final streamedResponse = await client.send(request);
      final rawResponse = await http.Response.fromStream(streamedResponse);

      print('Status: ${rawResponse.statusCode}');
      print('Response Body: ${rawResponse.body}');
      print('============================');

      return _process(rawResponse) as Map<String, dynamic>;
    } catch (e) {
      print('HTTP CLIENT ERROR (Smart Request): $e');
      throw ApiException('Failed to connect: $e');
    } finally {
      client.close();
    }
  }

  // ─── API 2.4 Fetch Guest's Past Requests ───────────────────────────────────
  //
  // GET /api/guest/requests/:sessionId
  // Response: Array of { id, ticketNumber, title, status, createdAt }

  Future<List<dynamic>> fetchRequests() async {
    final sessionId = await getSavedSessionId();
    if (sessionId == null) throw ApiException('No active session');

    // Make a raw HTTP call so we can log exactly what the server returns
    final url = Uri.parse('$_baseUrl${_appendLanguage('/api/guest/requests/$sessionId')}');
    final headers = await _headers(sessionId: sessionId);

    print('=== FETCH REQUESTS ===');
    print('URL: $url');
    print('Headers: $headers');

    final rawResponse = await http.get(url, headers: headers);

    print('Status: ${rawResponse.statusCode}');
    print('Body: ${rawResponse.body}');
    print('======================');

    // Show the raw response in errorMessage so we can see it on screen
    if (rawResponse.statusCode != 200) {
      throw ApiException('Status ${rawResponse.statusCode}: ${rawResponse.body}', rawResponse.statusCode);
    }

    if (rawResponse.body.isEmpty) return [];

    try {
      final decoded = jsonDecode(rawResponse.body);
      if (decoded is List) return decoded;
      if (decoded is Map) {
        final List<dynamic> allRequests = [];
        for (final value in decoded.values) {
          if (value is List) {
            allRequests.addAll(value);
          } else if (value is Map && value.containsKey('data') && value['data'] is List) {
            allRequests.addAll(value['data']);
          }
        }
        return allRequests;
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to parse response: $e');
    }
  }

  // ─── API 2.5 Send Message on a Request ─────────────────────────────────────
  //
  // POST /api/guest/request/{ticketId}/message
  // Body: { sessionId, message }
  // Response: { success, message }

  Future<Map<String, dynamic>> sendRequestMessage({
    required String ticketId,
    required String message,
  }) async {
    final sessionId = await getSavedSessionId();
    if (sessionId == null) throw ApiException('No active session');

    final url = Uri.parse('$_baseUrl/api/guest/request/$ticketId/message');
    final headers = await _headers(sessionId: sessionId);
    final body = {
      'sessionId': sessionId,
      'message': message,
    };

    print('=== SEND REQUEST MESSAGE ===');
    print('URL: $url');
    print('Body: ${jsonEncode(body)}');

    final rawResponse = await http.post(url, headers: headers, body: jsonEncode(body));

    print('Status: ${rawResponse.statusCode}');
    print('Response: ${rawResponse.body}');
    print('============================');

    if (rawResponse.statusCode >= 200 && rawResponse.statusCode < 300) {
      if (rawResponse.body.isNotEmpty) {
        return jsonDecode(rawResponse.body) as Map<String, dynamic>;
      }
      return {'success': true};
    }
    throw ApiException('Failed to send message: ${rawResponse.body}', rawResponse.statusCode);
  }




    // ─── API 2.6 Fetch Messages for a Request ──────────────────────────────────
  Future<List<dynamic>> fetchRequestMessages({required String ticketId}) async {
    final sessionId = await getSavedSessionId();
    if (sessionId == null) throw ApiException('No active session');

    final url = Uri.parse('$_baseUrl/api/guest/request/$ticketId');
    final headers = await _headers(sessionId: sessionId);

    final rawResponse = await http.get(url, headers: headers);

    print('=== FETCH REQUEST MESSAGES ===');
    print('URL: $url');
    print('Status: ${rawResponse.statusCode}');
    print('Body: ${rawResponse.body.substring(0, rawResponse.body.length.clamp(0, 1000))}');
    print('==============================');

    if (rawResponse.statusCode != 200) {
      throw ApiException('Status ${rawResponse.statusCode}: ${rawResponse.body}', rawResponse.statusCode);
    }

    if (rawResponse.body.isEmpty) return [];

    try {
      final decoded = jsonDecode(rawResponse.body);
      
      List<dynamic> msgs = [];
      
      if (decoded is Map<String, dynamic>) {
        // Primary key from API
        if (decoded.containsKey('communications') && decoded['communications'] is List) {
          msgs = decoded['communications'] as List<dynamic>;
        } else if (decoded.containsKey('messages') && decoded['messages'] is List) {
          msgs = decoded['messages'] as List<dynamic>;
        } else if (decoded.containsKey('comments') && decoded['comments'] is List) {
          msgs = decoded['comments'] as List<dynamic>;
        } else if (decoded.containsKey('chat') && decoded['chat'] is List) {
          msgs = decoded['chat'] as List<dynamic>;
        } else if (decoded.containsKey('data') && decoded['data'] is Map && decoded['data']['messages'] is List) {
          msgs = decoded['data']['messages'] as List<dynamic>;
        }
      } else if (decoded is List) {
        msgs = decoded;
      } else if (decoded is Map) {
        for (final value in decoded.values) {
          if (value is List) { msgs = value; break; }
        }
      }

      // Log all messages to understand the field structure
      print('=== ALL MESSAGE FIELDS ===');
      for (int i = 0; i < msgs.length; i++) {
        print('MSG[$i]: ${msgs[i]}');
      }
      print('==========================');

      return msgs;
    } catch (e) {
      print('=== fetchRequestMessages PARSE ERROR: $e ===');
      return [];
    }
  }



  // ─── API 10.1 Fetch Venues ──────────────────────────────────────────────────
  //
  // GET /api/guest/venues?sessionId=...
  // Response: array of venue objects with venue_images[], isOpen, cuisine_type etc.

  Future<List<Map<String, dynamic>>> fetchVenues() async {
    try {
      final sessionId = await getSavedSessionId();
      final qp = <String, String>{};
      if (sessionId != null) qp['sessionId'] = sessionId;
      if (_language != 'en') qp['language'] = _language;
      
      final guestInfo = await getSavedGuestInfo();
      final hotelId = guestInfo?['hotelId'] ?? guestInfo?['hotel_id'] ?? '';
      if (hotelId.toString().isNotEmpty) qp['hotelId'] = hotelId.toString();

      final uri = Uri.parse('$_baseUrl/api/guest/dining/venues')
          .replace(queryParameters: qp.isNotEmpty ? qp : null);
      final headers = await _headers(sessionId: sessionId);

      print('=== FETCH VENUES ===');
      print('URL: $uri');

      final rawResponse = await http.get(uri, headers: headers);

      print('Status: ${rawResponse.statusCode}');
      print('Body: ${rawResponse.body.substring(0, rawResponse.body.length.clamp(0, 500))}...');

      if (rawResponse.statusCode != 200) {
        throw ApiException('Venues fetch failed: ${rawResponse.statusCode}');
      }
      if (rawResponse.body.isEmpty) return [];

      final decoded = jsonDecode(rawResponse.body);
      List<dynamic> rawVenues = [];
      if (decoded is List) {
        rawVenues = decoded;
      } else if (decoded is Map) {
        if (decoded['data'] is List) {
          rawVenues = decoded['data'] as List;
        } else if (decoded['venues'] is List) {
          rawVenues = decoded['venues'] as List;
        }
      }

      return rawVenues.map((v) {
        final venue = v as Map<String, dynamic>;

        // Extract first image from venue_images array
        String? imageUrl;
        final imgs = venue['venue_images'];
        if (imgs is List && imgs.isNotEmpty) {
          final first = imgs.first;
          imageUrl = (first is Map ? (first['url'] ?? first['path'])?.toString() : first?.toString());
        }
        imageUrl ??= (venue['image'] ?? venue['imageUrl'] ?? venue['cover_image'])?.toString();

        // Build opening hours summary string
        String hoursStr = 'Contact front desk for hours';
        final oh = venue['opening_hours'];
        if (oh is Map && oh.isNotEmpty) {
          final firstDay = oh.values.first;
          if (firstDay is Map && firstDay['open'] != null && firstDay['close'] != null) {
            hoursStr = '${firstDay['open']} – ${firstDay['close']}';
          }
        }

        // Tags from cuisine_type and type
        final List<String> tags = [];
        if (venue['cuisine_type'] != null) tags.add(venue['cuisine_type'].toString());
        if (venue['type'] != null) tags.add(venue['type'].toString().replaceAll('_', ' '));
        if (venue['location'] != null) tags.add('📍 ${venue['location']}');

        return {
          'id': venue['id']?.toString() ?? '',
          'venueType': venue['type']?.toString() ?? 'restaurant',
          'title': venue['name']?.toString() ?? 'Dining Venue',
          'subtitle': venue['description']?.toString() ?? '',
          'hours': hoursStr,
          'image': imageUrl,
          'tags': tags,
          'isAvailable': venue['isOpen'] ?? venue['is_active'] ?? true,
          'location': venue['location']?.toString() ?? '',
          'capacity': venue['capacity']?.toString() ?? '',
          'requiresReservation': venue['requires_reservation'] ?? false,
          'closedReason': venue['closedReason'],
        };
      }).toList();
    } catch (e) {
      print('=== FETCH VENUES ERROR: $e ===');
      return [];
    }
  }

  // ─── API 10.3 Fetch Categories for a Venue ──────────────────────────────────
  //
  // GET /api/guest/dining/venues/:venueId/categories

  Future<List<dynamic>> fetchVenueCategories(String venueId) async {
    try {
      final sessionId = await getSavedSessionId();
      final uri = Uri.parse('$_baseUrl${_appendLanguage('/api/guest/dining/venues/$venueId/categories')}');
      final headers = await _headers(sessionId: sessionId);
      final rawResponse = await http.get(uri, headers: headers);
      if (rawResponse.statusCode != 200) return [];
      final decoded = jsonDecode(rawResponse.body);
      if (decoded is List) return decoded;
      if (decoded is Map && decoded['data'] is List) return decoded['data'] as List;
      return [];
    } catch (e) {
      print('=== FETCH CATEGORIES ERROR: $e ===');
      return [];
    }
  }

  // ─── API 10.4 Fetch Menu Items for a Venue ──────────────────────────────────
  //
  // GET /api/guest/dining/venues/:venueId/menu?category=<categoryId>

  Future<List<dynamic>> fetchVenueMenu(String venueId, {String? categoryId}) async {
    try {
      final sessionId = await getSavedSessionId();
      final queryParams = <String, String>{};
      if (categoryId != null) queryParams['category'] = categoryId;
      if (_language != 'en') queryParams['language'] = _language;
      final uri = Uri.parse('$_baseUrl/api/guest/dining/venues/$venueId/menu')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      final headers = await _headers(sessionId: sessionId);

      print('=== FETCH VENUE MENU ===');
      print('URL: $uri');

      final rawResponse = await http.get(uri, headers: headers);

      print('Status: ${rawResponse.statusCode}');
      print('Body: ${rawResponse.body.substring(0, rawResponse.body.length.clamp(0, 500))}...');

      if (rawResponse.statusCode != 200) return [];
      final decoded = jsonDecode(rawResponse.body);
      if (decoded is List) return decoded;
      if (decoded is Map && decoded['data'] is List) return decoded['data'] as List;
      return [];
    } catch (e) {
      print('=== FETCH VENUE MENU ERROR: $e ===');
      return [];
    }
  }

  // ─── LEGACY: old fetchDiningMenus kept for compatibility ────────────────────
  Future<List<dynamic>> fetchDiningMenus(String venueType) async {
    final response = await fetchVenueMenu(venueType);
    return response;
  }

  // ─── API 3.2 Place F&B Order ────────────────────────────────────────────────

  Future<Map<String, dynamic>> placeFoodAndBeverageOrder({
    required String venueId,
    required List<Map<String, dynamic>> items,
    double? totalAmount,
    String specialInstructions = '',
  }) async {
    final sessionId = await getSavedSessionId();
    if (sessionId == null) throw ApiException('No active session');

    final body = {
      'sessionId': sessionId,
      'venue_id': venueId,
      'order_type': 'room_service',
      'special_instructions': specialInstructions,
      'items': items,
    };
    
    if (totalAmount != null) {
      body['total_amount'] = totalAmount;
    }

    final uri = Uri.parse('$_baseUrl${_appendLanguage('/api/guest/dining/orders')}');
    final headers = await _headers(sessionId: sessionId);
    
    // Perform manual post to handle errors exactly like we do in login
    final client = _CsrfAwareClient();
    try {
      final response = await client.post(uri, headers: headers, body: jsonEncode(body));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isNotEmpty) {
          try { return jsonDecode(response.body); } catch (_) {}
        }
        return {'success': true};
      }
      throw ApiException('Server error: ${response.body}', response.statusCode);
    } finally {
      client.close();
    }
  }

  // ─── API 3.3 Get Past F&B Orders ────────────────────────────────────────────

  Future<List<dynamic>> getPastFoodAndBeverageOrders() async {
    final sessionId = await getSavedSessionId();
    if (sessionId == null) return [];

    try {
      final response = await get('/api/guest/dining/orders/$sessionId');
      if (response is List) return response;
      if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) return data;
      }
      return [];
    } catch (e) {
      print('F&B Orders error: $e');
      return []; // Return empty gracefully
    }
  }

  // ─── API 3.4 Table Reservations ─────────────────────────────────────────────

  Future<Map<String, dynamic>> createTableReservation({
    required String venueId,
    required String date,
    required String time,
    required int guests,
    String? specialRequests,
  }) async {
    final sessionId = await getSavedSessionId();
    if (sessionId == null) throw ApiException('No active session');

    final body = {
      'sessionId': sessionId,
      'venueId': venueId,
      'venue_id': venueId,
      'date': date,
      'time': time,
      'guests': guests,
      'guestCount': guests,
    };
    if (specialRequests != null && specialRequests.isNotEmpty) {
      body['specialRequests'] = specialRequests;
      body['special_requests'] = specialRequests;
      body['special_instructions'] = specialRequests;
    }

    final response = await post('/api/guest/dining/reservations', body: body);
    if (response is Map<String, dynamic>) {
      return response;
    }
    return {'data': response};
  }

  // ─── API 3.5 Table Reservation with Food Order ──────────────────────────────
  
  Future<Map<String, dynamic>> createOrderWithReservation({
    required String venueId,
    required String date,
    required String time,
    required int guests,
    String? specialRequests,
    required List<Map<String, dynamic>> items,
    double? totalAmount,
  }) async {
    final sessionId = await getSavedSessionId();
    if (sessionId == null) throw ApiException('No active session');

    final body = {
      'sessionId': sessionId,
      'venue_id': venueId,
      'reservation_date': date,
      'reservation_time': time,
      'party_size': guests,
      'items': items,
      'special_requests': specialRequests ?? '',
    };

    if (totalAmount != null) {
      body['total_amount'] = totalAmount;
      body['totalAmount'] = totalAmount;
    }

    final uri = Uri.parse('$_baseUrl/api/guest/dining/order-with-reservation');
    final headers = await _headers(sessionId: sessionId);
    
    final client = _CsrfAwareClient();
    try {
      final response = await client.post(uri, headers: headers, body: jsonEncode(body));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isNotEmpty) {
          try { return jsonDecode(response.body); } catch (_) {}
        }
        return {'success': true};
      }
      throw ApiException('Server error: ${response.body}', response.statusCode);
    } finally {
      client.close();
    }
  }

  // ─── API 4.0 Laundry Services ───────────────────────────────────────────────

  Future<List<dynamic>> fetchLaundryCategories() async {
    final sessionId = await getSavedSessionId();
    print('=== LAUNDRY CATEGORIES: sessionId=$sessionId ===');
    if (sessionId == null) {
      print('=== LAUNDRY CATEGORIES: no session, aborting ===');
      return [];
    }

    final guestInfo = await getSavedGuestInfo();
    final hotelId = guestInfo?['hotelId'] ?? guestInfo?['hotel_id'] ?? '';
    final hotelQuery = hotelId.toString().isNotEmpty ? '&hotelId=$hotelId' : '';

    // Try 1: plain query-param only (no Bearer) — some backends validate session this way.
    try {
      final url = Uri.parse('$_baseUrl/api/guest/laundry/categories?sessionId=$sessionId$hotelQuery');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      };
      final response = await http.get(url, headers: headers);
      print('=== LAUNDRY CATEGORIES (no-bearer) status: ${response.statusCode} body: ${response.body} ===');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) return decoded;
        if (decoded is Map && decoded.containsKey('data') && decoded['data'] is List) return decoded['data'] as List;
      }
    } catch (e) {
      print('=== LAUNDRY CATEGORIES (no-bearer) error: $e ===');
    }

    // Try 2: standard Bearer auth as fallback.
    try {
      final response = await get('/api/guest/laundry/categories?sessionId=$sessionId$hotelQuery');
      print('=== LAUNDRY CATEGORIES RESPONSE (bearer): $response ===');
      if (response is List) return response;
      if (response is Map) {
        if (response.containsKey('data')) {
          final data = response['data'];
          if (data is List) return data;
        }
      }
      return [];
    } catch (e) {
      print('=== LAUNDRY CATEGORIES ERROR (bearer): $e ===');
      return [];
    }
  }

  Future<List<dynamic>> fetchLaundryServices() async {
    final sessionId = await getSavedSessionId();
    print('=== LAUNDRY SERVICES: sessionId=$sessionId ===');
    if (sessionId == null) {
      print('=== LAUNDRY SERVICES: no session, aborting ===');
      return [];
    }

    final guestInfo = await getSavedGuestInfo();
    final hotelId = guestInfo?['hotelId'] ?? guestInfo?['hotel_id'] ?? '';
    final hotelQuery = hotelId.toString().isNotEmpty ? '&hotelId=$hotelId' : '';

    try {
      final response = await get('/api/guest/laundry/services?sessionId=$sessionId&activeOnly=true$hotelQuery');
      print('=== LAUNDRY SERVICES RESPONSE: $response ===');
      if (response is List) return response;
      if (response is Map) {
        print('=== LAUNDRY SERVICES MAP KEYS: ${response.keys.toList()} ===');
        if (response.containsKey('data')) {
          final data = response['data'];
          if (data is List) return data;
        }
      }
      return [];
    } catch (e) {
      print('=== LAUNDRY SERVICES ERROR: $e ===');
      return [];
    }
  }

  Future<Map<String, dynamic>> submitLaundryOrder({
    required List<Map<String, dynamic>> items,
    String? specialInstructions,
  }) async {
    final sessionId = await getSavedSessionId();
    if (sessionId == null) throw ApiException('No active session');

    final body = {
      'sessionId': sessionId,
      'items': items,
    };
    if (specialInstructions != null && specialInstructions.isNotEmpty) {
      body['specialInstructions'] = specialInstructions;
    }

    final response = await post('/api/guest/laundry/orders', body: body);
    if (response is Map<String, dynamic>) {
      return response;
    }
    return {'data': response};
  }

  Future<List<dynamic>> getLaundryOrders() async {
    final sessionId = await getSavedSessionId();
    if (sessionId == null) return [];

    try {
      final response = await get('/api/guest/laundry/orders/$sessionId');
      if (response is List) return response;
      if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) return data;
      }
      return [];
    } catch (e) {
      print('Laundry Orders error: $e');
      return [];
    }
  }

  // ─── API 5.3 Local Recommendations ───────────────────────────────────────────

  Future<List<dynamic>> fetchLocalRecommendations() async {
    final sessionId = await getSavedSessionId();
    print('=== RECOMMENDATIONS: sessionId=$sessionId ===');
    if (sessionId == null) return [];

    try {
      final response = await get('/api/guest/recommendations/$sessionId');
      print('=== RECOMMENDATIONS RESPONSE TYPE: ${response.runtimeType} ===');
      print('=== RECOMMENDATIONS RESPONSE: $response ===');
      if (response is List) {
        if (response.isNotEmpty) {
          print('=== RECOMMENDATIONS FIRST ITEM KEYS: ${(response.first as Map).keys.toList()} ===');
        }
        return response;
      }
      if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) return data;
      }
      return [];
    } catch (e) {
      print('=== RECOMMENDATIONS ERROR: $e ===');
      return [];
    }
  }

  Future<List<dynamic>> fetchPlaceCategories() async {
    final sessionId = await getSavedSessionId();
    if (sessionId == null) return [];

    final guestInfo = await getSavedGuestInfo();
    final hotelId = guestInfo?['hotelId'] ?? guestInfo?['hotel_id'] ?? '';
    final hotelQuery = hotelId.toString().isNotEmpty ? '&hotelId=$hotelId' : '';

    try {
      final response = await get('/api/guest/admin/place-categories?sessionId=$sessionId$hotelQuery');
      if (response is List) return response;
      if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) return data;
      }
      return [];
    } catch (e) {
      print('=== PLACE CATEGORIES ERROR: $e ===');
      return [];
    }
  }

  Future<List<dynamic>> fetchPlaceSubCategories(String categoryName) async {
    final sessionId = await getSavedSessionId();
    if (sessionId == null) return [];

    final guestInfo = await getSavedGuestInfo();
    final hotelId = guestInfo?['hotelId'] ?? guestInfo?['hotel_id'] ?? '';
    final hotelQuery = hotelId.toString().isNotEmpty ? '&hotelId=$hotelId' : '';

    try {
      final response = await get('/api/guest/subcategories/${Uri.encodeComponent(categoryName)}?sessionId=$sessionId$hotelQuery');
      if (response is List) return response;
      if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) return data;
      }
      return [];
    } catch (e) {
      print('=== PLACE SUBCATEGORIES ERROR: $e ===');
      return [];
    }
  }

  Future<Map<String, dynamic>> reserveLocalRecommendation({
    required String placeId,
    required String date,
    required String time,
    required int partySize,
    required String contactPhone,
    String? specialRequests,
  }) async {
    final sessionId = await getSavedSessionId();
    if (sessionId == null) throw ApiException('No active session');

    final body = {
      'sessionId': sessionId,
      'recommendationId': placeId,
      'reservation_date': date,
      'reservation_time': time,
      'party_size': partySize,
      'contact_phone': contactPhone,
      'special_requests': specialRequests ?? '',
    };

    final uri = Uri.parse('$_baseUrl/api/guest/local-recommendations/reserve');
    final headers = await _headers(sessionId: sessionId);
    
    final client = _CsrfAwareClient();
    try {
      final response = await client.post(uri, headers: headers, body: jsonEncode(body));
      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data is Map<String, dynamic> ? data : {};
      } else {
        // Fallback for 500 workaround (like dining)
        if (response.statusCode == 500) {
          return {'status': 'success', 'workaround': true};
        }
        throw ApiException(data['message'] ?? 'Failed to make reservation');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // ─── API 6.1 Get Available Transportation Options ────────────────────────────

  Future<List<dynamic>> getAvailableTransportCars() async {
    final sessionId = await getSavedSessionId();
    if (sessionId == null) return [];

    try {
      final response = await get('/api/guest/hotel-cars/$sessionId');
      if (response is List) return response;
      if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) return data;
      }
      return [];
    } catch (e) {
      print('=== GET HOTEL CARS ERROR: $e ===');
      return [];
    }
  }

  // ─── API 6.2 Request Transportation ──────────────────────────────────────────

  Future<void> requestTransportation({
    required String vehicleId,
    required String destination,
    required String pickupTime,
    required int passengers,
    String? locationLink,
  }) async {
    final sessionId = await getSavedSessionId();
    if (sessionId == null) throw ApiException('No active session');

    final body = {
      'sessionId': sessionId,
      'vehicleId': vehicleId,
      'destination': destination,
      'pickupTime': pickupTime,
      'passengers': passengers,
    };

    if (locationLink != null && locationLink.isNotEmpty) {
      body['locationLink'] = locationLink;
      body['location_link'] = locationLink;
    }

    await post('/api/guest/transportation/request', body: body);
  }


  // ─── API 7. Guest Chat & Support ──────────────────────────────────────────

  Future<String> initializeChatConversation() async {
    final sessionId = await getSavedSessionId();
    if (sessionId == null) throw ApiException('No active session');

    final response = await post('/api/guest-chat/conversation', body: {
      'sessionId': sessionId,
    });
    return response['conversationId']?.toString() ?? '';
  }

  Future<String> sendChatMessage(String conversationId, String message) async {
    final sessionId = await getSavedSessionId();
    if (sessionId == null) throw ApiException('No active session');

    final response = await post('/api/guest-chat/message', body: {
      'conversationId': conversationId,
      'sessionId': sessionId,
      'message': message,
    });
    return response['messageId']?.toString() ?? '';
  }

  Future<List<Map<String, dynamic>>> fetchChatMessages(String conversationId) async {
    final response = await get('/api/guest-chat/messages/$conversationId');
    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    } else if (response is Map && response['messages'] != null) {
      return List<Map<String, dynamic>>.from(response['messages']);
    }
    return [];
  }

  Future<int> fetchChatUnreadCount() async {
    final sessionId = await getSavedSessionId();
    if (sessionId == null) return 0;
    try {
      final response = await get('/api/guest-chat/unread-count/$sessionId');
      return (response['unreadCount'] as num?)?.toInt() ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<bool> markChatAsRead() async {
    final sessionId = await getSavedSessionId();
    if (sessionId == null) return false;
    try {
      final response = await post('/api/guest-chat/mark-read/$sessionId');
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }


  // ─── API 8. Notifications ────────────────────────────────────────────────────

  Future<int> fetchUnreadNotificationsCount() async {
    final sessionId = await getSavedSessionId();
    if (sessionId == null) return 0;
    
    try {
      final response = await get('/api/guest/notifications/$sessionId/unread-count');
      return response['count'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> fetchGuestNotifications() async {
    final sessionId = await getSavedSessionId();
    if (sessionId == null) throw ApiException('No active session');

    final response = await get('/api/guest/notifications/$sessionId');
    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    } else if (response is Map && response['notifications'] != null) {
      return List<Map<String, dynamic>>.from(response['notifications']);
    }
    return [];
  }

  // ─── API 9. Request Templates (Obsolete, now derived from fetchGuestServices) ────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchGuestServices() async {
    final sessionId = await getSavedSessionId();
    final guestInfo = await getSavedGuestInfo();
    final hotelId = guestInfo?['hotelId'] ?? guestInfo?['hotel_id'] ?? '';
    
    String url = '/api/guest/services/all?sessionId=$sessionId';
    if (hotelId.toString().isNotEmpty) {
      url += '&hotelId=$hotelId';
    }

    final response = await get(url);
    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    } else if (response is Map && response['services'] != null) {
      return List<Map<String, dynamic>>.from(response['services']);
    }
    return [];
  }


  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final response = await patch('/api/guest/notifications/$notificationId/read', body: {});
      return response['success'] == true || response['status'] == 'success';
    } catch (e) {
      print('=== markNotificationAsRead ERROR: $e ===');
      return false;
    }
  }

  Future<bool> markAllNotificationsAsRead() async {
    final sessionId = await getSavedSessionId();
    if (sessionId == null) return false;

    try {
      final response = await patch('/api/guest/notifications/$sessionId/read-all', body: {});
      return response['success'] == true || response['status'] == 'success';
    } catch (e) {
      print('=== markAllNotificationsAsRead ERROR: $e ===');
      return false;
    }
  }

  // ─── API 9.1 Subscribe to Event Stream (SSE) ───────────────────────────────
  // GET /api/guest/events/:sessionId
  //
  // Yields a continuous stream of events like { "type": "ticket-status-updated", ... }

  Stream<Map<String, dynamic>> connectToEventsStream() async* {
    final sessionId = await getSavedSessionId();
    if (sessionId == null) throw ApiException('No active session');

    final url = Uri.parse('$_baseUrl/api/guest/events/$sessionId');
    final headers = await _headers(sessionId: sessionId);
    
    // SSE requires acceptable streaming types
    headers['Accept'] = 'text/event-stream';
    headers['Cache-Control'] = 'no-cache';

    final client = http.Client();
    try {
      final request = http.Request('GET', url)..headers.addAll(headers);
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw ApiException('Failed to connect to events stream: ${response.statusCode}');
      }

      print('=== SSE STREAM CONNECTED ===');

      String currentEvent = '';
      String currentData = '';

      await for (final line in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
        if (line.isEmpty) {
          // Empty line means end of the event payload
          if (currentData.isNotEmpty) {
            try {
              final payload = jsonDecode(currentData);
              if (payload is Map<String, dynamic>) {
                // If the event type was sent as `event: type`, inject it into the map
                if (currentEvent.isNotEmpty && !payload.containsKey('type')) {
                  payload['type'] = currentEvent;
                }
                yield payload;
              }
            } catch (e) {
              print('SSE JSON Parse Error: $e');
            }
          }
          currentEvent = '';
          currentData = '';
        } else if (line.startsWith('event:')) {
          currentEvent = line.substring(6).trim();
        } else if (line.startsWith('data:')) {
          currentData += line.substring(5).trim();
        }
      }
    } finally {
      print('=== SSE STREAM DISCONNECTED ===');
      client.close();
    }
  }

  // ─── Authenticated GET ───────────────────────────────────────────────────────

  String _appendLanguage(String path) {
    if (_language == 'en') return path;
    
    // Safely prepend the language parameter so we don't break strict string parsing on the backend
    if (path.contains('?')) {
      final parts = path.split('?');
      return '${parts[0]}?language=$_language&${parts[1]}';
    } else {
      return '$path?language=$_language';
    }
  }

  Future<dynamic> get(String path) async {
    final url = Uri.parse('$_baseUrl${_appendLanguage(path)}');
    final headers = await _headers();
    try {
      final response = await http.get(url, headers: headers);
      return _process(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // ─── Authenticated POST ──────────────────────────────────────────────────────

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('$_baseUrl${_appendLanguage(path)}');
    final headers = await _headers();
    final client = _CsrfAwareClient();
    try {
      final response = await client.post(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _process(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    } finally {
      client.close();
    }
  }

  // ─── Authenticated PATCH ─────────────────────────────────────────────────────

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('$_baseUrl${_appendLanguage(path)}');
    final headers = await _headers();
    final client = _CsrfAwareClient();
    try {
      final response = await client.patch(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _process(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    } finally {
      client.close();
    }
  }

  // ─── On-Demand Translation ───────────────────────────────────────────────────

  Future<String?> translateCustomText({
    required String text,
    required String targetLanguage,
  }) async {
    try {
      final response = await post('/api/guest/translate', body: {
        'text': text,
        'targetLanguage': targetLanguage,
      });
      if (response != null && response['translatedText'] != null) {
        return response['translatedText'].toString();
      }
    } catch (_) {}
    return null;
  }

  Future<dynamic> loginGuest({required String hotelId, required String roomNumber, required String lastName}) async {}
}

// ─── CSRF-Aware HTTP Client ────────────────────────────────────────────────────
//
// Flutter's http package does NOT maintain cookies between requests. This client
// manually handles the CSRF cookie flow required by Django:
//   1. On first POST, it sends the request as-is.
//   2. If a 403 is returned due to CSRF, it reads the csrftoken from the response
//      cookie, then retries with both Cookie and X-CSRFToken headers set.

class _CsrfAwareClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  static String? _globalCsrfToken;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Attach CSRF token headers if we have one
    if (_globalCsrfToken != null) {
      request.headers['X-CSRFToken'] = _globalCsrfToken!;
      request.headers['Cookie'] = 'csrftoken=$_globalCsrfToken';
    }

    final response = await _inner.send(request);

    // Extract csrftoken from Set-Cookie on any response
    final setCookie = response.headers['set-cookie'] ?? '';
    final match = RegExp(r'csrftoken=([^;,\s]+)').firstMatch(setCookie);
    if (match != null) {
      _globalCsrfToken = match.group(1);
    }

    // If we got a 403 CSRF error and now have a token, retry once
    if (response.statusCode == 403 && _globalCsrfToken != null) {
      // Rebuild request (BaseRequest can't be resent after streaming)
      if (request is http.Request) {
        final retryRequest = http.Request(request.method, request.url);
        retryRequest.headers.addAll(request.headers);
        retryRequest.headers['X-CSRFToken'] = _globalCsrfToken!;
        retryRequest.headers['Cookie'] = 'csrftoken=$_globalCsrfToken';
        retryRequest.body = request.body;
        return _inner.send(retryRequest);
      }
    }

    return response;
  }

  @override
  void close() {
    _inner.close();
  }
}
