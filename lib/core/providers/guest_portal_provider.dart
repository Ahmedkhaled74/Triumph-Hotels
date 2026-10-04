import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triumph_hotels/app.dart';
import 'package:triumph_hotels/features/auth/guest_portal_login_screen.dart';
import 'package:triumph_hotels/services/guest_portal_service.dart';
import 'package:triumph_hotels/services/api_client.dart';
import 'package:triumph_hotels/services/fcm_service.dart';
import 'package:triumph_hotels/models/request_template.dart';

class GuestPortalProvider extends ChangeNotifier with WidgetsBindingObserver {
  final GuestPortalService _service = GuestPortalService();

  String? _sessionId;
  Map<String, dynamic>? _guestInfo;
  List<dynamic> _requests = [];
  List<dynamic> _foodOrders = [];
  List<dynamic> _laundryCategories = [];
  List<dynamic> _laundryServices = [];
  List<dynamic> _laundryOrders = [];
  List<dynamic> _localRecommendations = [];
  List<dynamic> _placeCategories = [];
  final Map<String, List<dynamic>> _placeSubCategories = {};
  List<dynamic> _transportCars = [];
  List<Map<String, dynamic>> _venues = [];
  final Map<String, List<dynamic>> _menus = {};
  final Map<String, List<dynamic>> _venueCategories = {};
  bool _isLoading = false;
  bool _isRestoringSession = true;
  String? _errorMessage;
  StreamSubscription<Map<String, dynamic>>? _sseSubscription;

  String? _chatConversationId;
  List<Map<String, dynamic>> _chatMessages = [];
  bool _isChatLoading = false;
  
  int _unreadNotificationsCount = 0;
  List<Map<String, dynamic>> _notificationsList = [];

  String? get sessionId => _sessionId;
  Map<String, dynamic>? get guestInfo => _guestInfo;
  
  List<RequestTemplate> _requestTemplates = [];
  List<RequestTemplate> get requestTemplates => _requestTemplates;
  bool _isLoadingTemplates = false;
  bool get isLoadingTemplates => _isLoadingTemplates;

  List<Map<String, dynamic>> _guestServices = [];
  List<Map<String, dynamic>> get guestServices => _guestServices;

  String _currentLanguage = 'en';
  String get currentLanguage => _currentLanguage;

  List<dynamic> get requests => _requests;
  List<dynamic> get foodOrders => _foodOrders;
  List<dynamic> get laundryCategories => _laundryCategories;
  List<dynamic> get laundryServices => _laundryServices;
  List<dynamic> get laundryOrders => _laundryOrders;
  List<dynamic> get localRecommendations => _localRecommendations;
  List<dynamic> get placeCategories => _placeCategories;
  Map<String, List<dynamic>> get placeSubCategories => _placeSubCategories;
  List<dynamic> get transportCars => _transportCars;
  List<Map<String, dynamic>> get venues => _venues;
  Map<String, List<dynamic>> get menus => _menus;
  Map<String, List<dynamic>> get venueCategories => _venueCategories;
  bool get isLoggedIn => _sessionId != null && _sessionId!.isNotEmpty;
  bool get isLoading => _isLoading;
  bool get isRestoringSession => _isRestoringSession;
  String? get errorMessage => _errorMessage;

  String? get chatConversationId => _chatConversationId;
  List<Map<String, dynamic>> get chatMessages => _chatMessages;
  bool get isChatLoading => _isChatLoading;
  
  DateTime? _lastSeenChatTime;

  int get unreadChatCount {
    final staffMsgs = _chatMessages.where((m) => m['sender_type'] != 'guest');
    if (_lastSeenChatTime == null) return staffMsgs.length;
    
    return staffMsgs.where((m) {
      final dateStr = m['created_at']?.toString() ?? '';
      final date = DateTime.tryParse(dateStr) ?? DateTime.fromMillisecondsSinceEpoch(0);
      return date.isAfter(_lastSeenChatTime!);
    }).length;
  }

  int get unreadNotificationsCount => _unreadNotificationsCount;
  List<Map<String, dynamic>> get notificationsList => _notificationsList;

  // Convenience getters from guestInfo — map multiple possible API key formats
  String get guestName {
    if (_guestInfo == null) return '';
    return (_guestInfo!['name'] ?? _guestInfo!['guest_name'] ?? _guestInfo!['guestName'] ?? 
            _guestInfo!['fullName'] ?? _guestInfo!['full_name'] ?? _guestInfo!['firstName'] ?? '').toString();
  }
  String get roomNumber {
    if (_guestInfo == null) return '';
    return (_guestInfo!['room'] ?? _guestInfo!['room_number'] ?? _guestInfo!['roomNumber'] ?? 
            _guestInfo!['room_no'] ?? '').toString();
  }
  String get checkIn {
    if (_guestInfo == null) return '';
    return (_guestInfo!['checkIn'] ?? _guestInfo!['check_in'] ?? _guestInfo!['checkInDate'] ?? 
            _guestInfo!['arrival'] ?? _guestInfo!['arrivalDate'] ?? '').toString();
  }
  String get checkOut {
    if (_guestInfo == null) return '';
    return (_guestInfo!['checkOut'] ?? _guestInfo!['check_out'] ?? _guestInfo!['checkOutDate'] ?? 
            _guestInfo!['departure'] ?? _guestInfo!['departureDate'] ?? '').toString();
  }

  GuestPortalProvider() {
    WidgetsBinding.instance.addObserver(this);
    GuestPortalService.onSessionExpired = (String url) {
      Future.microtask(() => logout(reason: '401 on: $url'));
    };
    restoreSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sseSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _sessionId != null) {
      _checkIfSessionExpiredLocally().then((expired) {
        if (!expired) {
          fetchNotifications(silent: true);
          fetchChatUnreadCount();
          _startListeningToEvents();
        }
      });
    }
  }

  Future<bool> _checkIfSessionExpiredLocally() async {
    final checkoutDateStr = checkOut;
    if (checkoutDateStr.isEmpty) return false;
    
    try {
      final checkoutDate = DateTime.parse(checkoutDateStr);
      final now = DateTime.now();
      // Give access until the end of the checkout day (11:59:59 PM)
      final endOfCheckoutDay = DateTime(checkoutDate.year, checkoutDate.month, checkoutDate.day, 23, 59, 59);
      
      if (now.isAfter(endOfCheckoutDay)) {
        await logout(reason: 'Checkout date ($checkoutDateStr) has passed.');
        return true;
      }
    } catch (_) {}
    return false;
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  // ─── Restore from SharedPreferences on app start ─────────────────────────

  Future<void> restoreSession() async {
    _isRestoringSession = true;
    notifyListeners();

    try {
      final savedSessionId = await _service.getSavedSessionId();
      if (savedSessionId == null || savedSessionId.isEmpty) return;

      // Don't overwrite an already-active session (e.g. just logged in)
      if (_sessionId != null && _sessionId!.isNotEmpty) return;

      _sessionId = savedSessionId;
      _guestInfo = await _service.getSavedGuestInfo();
      _currentLanguage = await _service.getSavedLanguage();
      
      if (await _checkIfSessionExpiredLocally()) {
        _isRestoringSession = false;
        notifyListeners();
        return; // Session expired locally based on checkout date
      }
      
      final prefs = await SharedPreferences.getInstance();
      final timeStr = prefs.getString('last_seen_chat_time');
      if (timeStr != null) {
        _lastSeenChatTime = DateTime.parse(timeStr);
      }

      _startListeningToEvents();
      fetchNotifications(silent: true);
      
      if (_chatConversationId == null || _chatConversationId!.isEmpty) {
        try {
          _chatConversationId = await _service.initializeChatConversation();
        } catch (_) {}
      }
      await refreshChatMessages(silent: true);

      notifyListeners();

      FCMService().setupPushNotifications(savedSessionId);

      await fetchGuestServices();
      fetchRequests();
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        await logout(reason: 'Session invalid on restore: ${e.message}');
      } else {
        debugPrint('Error during restoration: $e');
      }
    } catch (e) {
      debugPrint('Error during restoration: $e');
    } finally {
      _isRestoringSession = false;
      notifyListeners();
    }
  }

  // ─── Login by Room Number + Confirmation Number ───────────────────────────

  Future<bool> loginByRoom({
    required String roomNumber,
    required String resvNameId,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final data = await _service.loginByRoom(
        roomNumber: roomNumber,
        resvNameId: resvNameId,
      );

      print('=== LOGIN RESPONSE DATA ===');
      print(data);
      print('==========================');

      final sessionId = data['sessionId']?.toString();
      final accessToken = data['accessToken']?.toString();
      // Set in-memory state immediately — do not wait for anything else
      _sessionId = sessionId ?? accessToken;
      _currentLanguage = await _service.getSavedLanguage();

      final nested = data['guestInfo'];
      if (nested is Map) {
        _guestInfo = Map<String, dynamic>.from(nested);
        for (final key in ['name', 'guest_name', 'guestName', 'fullName', 'full_name',
          'room', 'room_number', 'roomNumber', 'room_no',
          'checkIn', 'check_in', 'checkOut', 'check_out',
          'arrival', 'departure', 'email', 'phone']) {
          if (data.containsKey(key) && !_guestInfo!.containsKey(key)) {
            _guestInfo![key] = data[key];
          }
        }
      } else {
        _guestInfo = {
          'name': data['guestName'] ?? data['name'] ?? data['guest_name'] ?? data['fullName'] ?? '',
          'room': data['roomNumber'] ?? data['room'] ?? data['room_number'] ?? data['room_no'] ?? roomNumber,
          'checkIn': data['checkIn'] ?? data['check_in'] ?? data['arrival'] ?? '',
          'checkOut': data['checkOut'] ?? data['check_out'] ?? data['departure'] ?? '',
        };
      }

      // Notify UI immediately with the session data we already have
      notifyListeners();

      _startListeningToEvents();
      fetchNotifications(silent: true);
      
      if (_chatConversationId == null || _chatConversationId!.isEmpty) {
        try {
          _chatConversationId = await _service.initializeChatConversation();
        } catch (_) {}
      }
      await refreshChatMessages(silent: true);
      
      await fetchGuestServices();
      fetchLocalRecommendations();
      fetchVenues();

      if (_sessionId != null) FCMService().setupPushNotifications(_sessionId!);

      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e, stack) {
      debugPrint('Error in loginByRoom: $e\n$stack');
      _setError('Unexpected error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Fetch Methods ─────────────────────────────────────────────────────────

  Future<void> fetchGuestServices() async {
    if (_sessionId == null) return;
    _isLoadingTemplates = true;
    notifyListeners();
    try {
      _guestServices = await _service.fetchGuestServices();
      
      // Derive request templates (featured services) from the master list
      final featuredServices = _guestServices.where((s) => s['isFeatured'] == true || s['is_featured'] == true).toList();
      _requestTemplates = featuredServices.map((json) => RequestTemplate(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        category: json['category']?.toString() ?? 'General',
        iconStr: json['icon']?.toString(),
        colorStr: json['color']?.toString(),
      )).toList();
    } catch (e) {
      debugPrint('Error fetching guest services: $e');
    } finally {
      _isLoadingTemplates = false;
      notifyListeners();
    }
  }

  // ─── Change Language ────────────────────────────────────────────────────────
  
  Future<void> changeLanguage(String langCode) async {
    if (_currentLanguage == langCode) return;
    
    _setLoading(true);
    try {
      _currentLanguage = langCode;
      notifyListeners(); // Immediate UI update for local components
      
      await _service.saveLanguage(langCode);
      await _service.updateGuestLanguage(langCode);
      
      // Clear caches so they are re-fetched in the new language
      _menus.clear();
      _venueCategories.clear();
      
      // Refresh all text-heavy data to get translations
      await fetchGuestServices();
      fetchRequests();
      fetchNotifications(silent: true);
      
      // Some methods might not exist safely, so we do a silent check.
      // E.g., if local recommendations or venues need refresh:
      try { fetchLocalRecommendations(); } catch (_) {}
      try { fetchVenues(forceRefresh: true); } catch (_) {}
      
    } finally {
      _setLoading(false);
    }
  }

  // ─── Submit a Smart Request ──────────────────────────────────────────────────

  Future<bool> submitSmartRequest({
    required String category,
    String? text,
    List<String>? imagePaths,
    String? voicePath,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _service.submitSmartRequest(
        category: category,
        text: text,
        imagePaths: imagePaths,
        voicePath: voicePath,
      );
      await fetchRequests();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Submit a Request ─────────────────────────────────────────────────────

  Future<bool> submitRequest({
    required String category,
    required String title,
    String priority = 'normal',
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _service.submitRequest(
        category: category,
        title: title,
        priority: priority,
      );
      // Refresh requests list after successful submit
      await fetchRequests();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Request-Specific Chat Methods ────────────────────────────────────────

  Future<List<dynamic>> fetchRequestMessages(String ticketId) async {
    return await _service.fetchRequestMessages(ticketId: ticketId);
  }

  Future<Map<String, dynamic>> sendRequestMessage(String ticketId, String message) async {
    return await _service.sendRequestMessage(ticketId: ticketId, message: message);
  }


  // ─── API 6 Transportation ───────────────────────────────────────────────────

  Future<void> fetchTransportCars({bool silent = false}) async {
    if (!silent) _setLoading(true);
    _setError(null);
    try {
      final cars = await _service.getAvailableTransportCars();
      _transportCars = cars;
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch hotel cars: $e');
    } finally {
      if (!silent) _setLoading(false);
    }
  }

  Future<void> requestTransportation({
    required String vehicleId,
    required String destination,
    required String pickupTime,
    required int passengers,
    String? locationLink,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _service.requestTransportation(
        vehicleId: vehicleId,
        destination: destination,
        pickupTime: pickupTime,
        passengers: passengers,
        locationLink: locationLink,
      );
      // Wait a moment then fetch requests
      await fetchRequests();
    } on ApiException catch (e) {
      if (e.statusCode == 500) {
        // WORKAROUND: TicketX backend saves the ticket but crashes and returns 500.
        await fetchRequests();
        return;
      }
      _setError('Failed to request transportation: $e');
      rethrow;
    } catch (e) {
      _setError('Failed to request transportation: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Fetch Past Requests ──────────────────────────────────────────────────

  Future<void> fetchRequests() async {
    if (await _checkIfSessionExpiredLocally()) return;
    _setLoading(true);
    _setError(null);
    try {
      _requests = await _service.fetchRequests();
      // Also fetch F&B orders when we fetch requests to keep them in sync
      await fetchFoodOrders(silent: true);
      notifyListeners();
    } on ApiException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to load requests.');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout({String? reason}) async {
    _setLoading(true);
    try {
      _stopListeningToEvents();
      // Unregister FCM token so guest stops receiving notifications after logout
      if (_sessionId != null) {
        await FCMService().unregisterToken(_sessionId!);
      }
      await _service.clearSession();
    } finally {
      _sessionId = null;
      _guestInfo = null;
      _requests = [];
      _foodOrders = [];
      _laundryOrders = [];
      _notificationsList = [];
      _unreadNotificationsCount = 0;
      _chatMessages = [];
      _lastSeenChatTime = null;
      _isLoadingTemplates = false;
      _isLoading = false;
      notifyListeners();
      
      // Force redirect to login screen
      final navState = navigatorKey.currentState;
      if (navState != null && navState.mounted) {
        if (reason != null) {
          ScaffoldMessenger.of(navState.context).showSnackBar(
            SnackBar(content: Text('Logged out: $reason'), duration: const Duration(seconds: 4)),
          );
        }
        navState.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const GuestPortalLoginScreen()),
          (route) => route.isFirst,
        );
      }
    }
  }

  // ─── Real-Time Events (SSE) ─────────────────────────────────────────────────

  void _startListeningToEvents() {
    _stopListeningToEvents();
    if (_sessionId == null) return;

    print('Starting SSE Event Listener for session: $_sessionId');
    _sseSubscription = _service.connectToEventsStream().listen(
      (event) {
        print('🔔 Received SSE Event: $event');
        final type = event['type'];
        
        // Ignore background heartbeats
        if (type == 'heartbeat') return;
        
        // A relevant event occurred (ticket updated, message received, etc.)
        // Instead of hardcoding exact event names, just silently refresh 
        // the user's data to guarantee the UI is always perfectly synced.
        print('Live update received via SSE. Refreshing data...');
        fetchRequests();
        refreshChatMessages(silent: true);
        fetchNotifications(silent: true);
      },
      onError: (e) {
        print('SSE Stream Error: $e');
        // Auto-reconnect logic could be added here if needed, 
        // e.g., Future.delayed(5s).then((_) => _startListeningToEvents())
      },
      cancelOnError: false,
    );
  }

  void _stopListeningToEvents() {
    _sseSubscription?.cancel();
    _sseSubscription = null;
  }

  // ─── F&B Methods ─────────────────────────────────────────────────────────────

  Future<void> fetchDiningMenu(String venueId) async {
    // Basic caching to avoid re-fetching on every open
    if (_menus.containsKey(venueId) && _menus[venueId]!.isNotEmpty) return;

    _setLoading(true);
    _setError(null);
    try {
      final items = await _service.fetchVenueMenu(venueId);
      _menus[venueId] = items;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load menu. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchVenueCategories(String venueId) async {
    if (_venueCategories.containsKey(venueId) && _venueCategories[venueId]!.isNotEmpty) return;
    try {
      final cats = await _service.fetchVenueCategories(venueId);
      _venueCategories[venueId] = cats;
      notifyListeners();
    } catch (e) {
      print('fetchVenueCategories error: $e');
    }
  }

  Future<void> fetchVenues({bool forceRefresh = false}) async {
    if (!forceRefresh && _venues.isNotEmpty) return; // use cache
    _setLoading(true);
    _setError(null);
    try {
      _venues = await _service.fetchVenues();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load venues.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchFoodOrders({bool silent = false}) async {
    if (!silent) {
      _setLoading(true);
      _setError(null);
    }
    try {
      _foodOrders = await _service.getPastFoodAndBeverageOrders();
      notifyListeners();
    } catch (e) {
      if (!silent) _setError('Failed to load F&B orders.');
    } finally {
      if (!silent) _setLoading(false);
    }
  }

  Future<bool> placeFoodOrder(String venueId, List<Map<String, dynamic>> items, [double? totalAmount, String specialInstructions = '']) async {
    _setLoading(true);
    _setError(null);
    try {
      await _service.placeFoodAndBeverageOrder(
        venueId: venueId, 
        items: items, 
        totalAmount: totalAmount,
        specialInstructions: specialInstructions
      );
      await fetchFoodOrders(silent: true);
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to place order.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createTableReservation(String venueId, String date, String time, int guests, String? specialRequests) async {
    _setLoading(true);
    _setError(null);
    try {
      await _service.createTableReservation(
        venueId: venueId,
        date: date,
        time: time,
        guests: guests,
        specialRequests: specialRequests,
      );
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to reserve table.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createOrderWithReservation(String venueId, String date, String time, int guests, String? specialRequests, List<Map<String, dynamic>> items, [double? totalAmount]) async {
    _setLoading(true);
    _setError(null);
    try {
      await _service.createOrderWithReservation(
        venueId: venueId,
        date: date,
        time: time,
        guests: guests,
        specialRequests: specialRequests,
        items: items,
        totalAmount: totalAmount,
      );
      await fetchFoodOrders(silent: true);
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 500) {
        await fetchFoodOrders(silent: true);
        return true;
      }
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to reserve table and order.');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  // ─── Laundry Operations ─────────────────────────────────────────────────────

  Future<void> fetchLaundryData({bool silent = false}) async {
    if (!silent) _setLoading(true);
    _setError(null);
    try {
      final results = await Future.wait([
        _service.fetchLaundryCategories(),
        _service.fetchLaundryServices(),
      ]);

      final fetchedCategories = results[0];
      final fetchedServices   = results[1];

      print('=== LAUNDRY DATA: ${fetchedCategories.length} categories, ${fetchedServices.length} services ===');
      print('=== LAUNDRY CATEGORIES RAW: $fetchedCategories ===');

      // Build a merged, de-duplicated category list.
      // Start with whatever the categories API returned.
      final Map<String, Map<String, dynamic>> categoryMap = {};
      for (final c in fetchedCategories) {
        final name = (c['name']?.toString() ?? '').toLowerCase();
        if (name.isNotEmpty) {
          categoryMap[name] = Map<String, dynamic>.from(c as Map);
        }
      }

      // Then add any categories that appear in services but are missing from the API response.
      for (final s in fetchedServices) {
        final name = (s['category']?.toString() ?? '').toLowerCase();
        if (name.isNotEmpty && !categoryMap.containsKey(name)) {
          categoryMap[name] = {
            'id': name,
            'name': name[0].toUpperCase() + name.substring(1), // capitalize
            'description': '',
            'color': '',
            'displayOrder': 999,
          };
        }
      }

      // Sort by displayOrder so the API-supplied order is respected.
      final mergedCategories = categoryMap.values.toList()
        ..sort((a, b) => ((a['displayOrder'] ?? 999) as int).compareTo((b['displayOrder'] ?? 999) as int));

      print('=== LAUNDRY MERGED CATEGORIES: ${mergedCategories.map((c) => c['name']).toList()} ===');

      _laundryCategories = mergedCategories;
      _laundryServices = fetchedServices;
      notifyListeners();
    } catch (e) {
      print('=== fetchLaundryData ERROR: $e ===');
      if (!silent) _setError('Failed to load laundry data.');
    } finally {
      if (!silent) _setLoading(false);
    }
  }

  Future<bool> placeLaundryOrder(List<Map<String, dynamic>> items, String specialInstructions) async {
    _setLoading(true);
    _setError(null);
    try {
      await _service.submitLaundryOrder(items: items, specialInstructions: specialInstructions);
      await fetchLaundryOrders(silent: true);
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 500) {
        await fetchLaundryOrders(silent: true);
        return true;
      }
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to place laundry order.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchLaundryOrders({bool silent = false}) async {
    try {
      _laundryOrders = await _service.getLaundryOrders();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchLocalRecommendations({bool silent = false}) async {
    if (!silent) _setLoading(true);
    _setError(null);
    try {
      final results = await Future.wait([
        _service.fetchLocalRecommendations(),
        _service.fetchPlaceCategories(),
      ]);
      _localRecommendations = results[0];
      _placeCategories = results[1];
      notifyListeners();
    } catch (e) {
      if (!silent) _setError('Failed to fetch recommendations');
    } finally {
      if (!silent) _setLoading(false);
    }
  }

  Future<void> fetchPlaceSubCategories(String categoryName) async {
    if (_placeSubCategories.containsKey(categoryName)) return; // Already fetched
    
    try {
      final subCats = await _service.fetchPlaceSubCategories(categoryName);
      _placeSubCategories[categoryName] = subCats;
      notifyListeners();
    } catch (e) {
      print('Failed to fetch subcategories for $categoryName: $e');
    }
  }

  Future<void> reserveLocalRecommendation({
    required String placeId,
    required String date,
    required String time,
    required int partySize,
    required String contactPhone,
    String? specialRequests,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _service.reserveLocalRecommendation(
        placeId: placeId,
        date: date,
        time: time,
        partySize: partySize,
        contactPhone: contactPhone,
        specialRequests: specialRequests,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Transport APIs ──────────────────────────────────────────────────────────────────

  Future<void> startChat() async {
    _isChatLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _chatConversationId = await _service.initializeChatConversation();
      if (_chatConversationId != null && _chatConversationId!.isNotEmpty) {
        await refreshChatMessages(silent: true);
        await markChatAsRead(); // Mark as read when opening chat
      }
    } catch (e) {
      _errorMessage = 'Failed to initialize chat: $e';
    } finally {
      _isChatLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshChatMessages({bool silent = false}) async {
    if (_chatConversationId == null || _chatConversationId!.isEmpty) return;
    if (!silent) {
      _isChatLoading = true;
      notifyListeners();
    }
    try {
      final msgs = await _service.fetchChatMessages(_chatConversationId!);
      // Sort messages by created_at ascending
      msgs.sort((a, b) {
        final dateA = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateA.compareTo(dateB);
      });
      _chatMessages = msgs;
    } catch (e) {
      print('Failed to fetch chat messages: $e');
    } finally {
      if (!silent) _isChatLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendChatMessage(String message) async {
    if (_chatConversationId == null || _chatConversationId!.isEmpty) return;
    
    // Optimistic UI update
    final tempMsg = {
      'id': 'temp-${DateTime.now().millisecondsSinceEpoch}',
      'conversation_id': _chatConversationId,
      'sender_type': 'guest',
      'message': message,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };
    _chatMessages.add(tempMsg);
    notifyListeners();

    try {
      await _service.sendChatMessage(_chatConversationId!, message);
      await refreshChatMessages(silent: true);
    } on ApiException catch (e) {
      if (e.statusCode == 500) {
        await refreshChatMessages(silent: true);
        return;
      }
      print('Failed to send message: $e');
      _chatMessages.remove(tempMsg);
      _errorMessage = 'Failed to send message: $e';
      notifyListeners();
    } catch (e) {
      print('Failed to send message: $e');
      _chatMessages.remove(tempMsg);
      _errorMessage = 'Failed to send message: $e';
      notifyListeners();
    }
  }

  Future<void> fetchChatUnreadCount() async {
    // Disabled in favor of local chat message parsing
  }

  Future<void> markChatAsRead() async {
    if (_chatMessages.isEmpty) return;
    
    // Sort just to be sure we have the latest at the end
    final sortedMsgs = List<Map<String, dynamic>>.from(_chatMessages);
    sortedMsgs.sort((a, b) {
      final dateA = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dateB = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return dateA.compareTo(dateB);
    });

    final latestMsg = sortedMsgs.last;
    final latestDateStr = latestMsg['created_at']?.toString() ?? '';
    final latestDate = DateTime.tryParse(latestDateStr);

    if (latestDate != null) {
      _lastSeenChatTime = latestDate;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_seen_chat_time', latestDate.toIso8601String());
      notifyListeners();
    }

    try {
      await _service.markChatAsRead(); // Still tell backend, but don't rely on it
    } catch (e) {
      print('Failed to notify backend of read: $e');
    }
  }

  // ─── Notifications ───────────────────────────────────────────────────────────

  Future<void> fetchNotifications({bool silent = false}) async {
    if (!isLoggedIn) return;
    
    try {
      _unreadNotificationsCount = await _service.fetchUnreadNotificationsCount();
      _notificationsList = await _service.fetchGuestNotifications();
      
      // Sort notifications by createdAt descending (newest first)
      _notificationsList.sort((a, b) {
        final dateA = DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = DateTime.tryParse(b['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA);
      });
    } on ApiException catch (e) {
      print('Failed to fetch notifications: $e');
    } catch (e) {
      print('Failed to fetch notifications: $e');
    } finally {
      if (!silent) notifyListeners();
    }
  }

  Future<void> markNotificationAsRead(String id) async {
    // Optimistic UI update
    final index = _notificationsList.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      final notif = _notificationsList[index];
      final isRead = notif['read'] == true || notif['read'] == 'true' || notif['is_read'] == true || notif['is_read'] == 'true';
      if (!isRead) {
        _notificationsList[index] = Map<String, dynamic>.from(notif)
          ..['read'] = true
          ..['is_read'] = true;
        if (_unreadNotificationsCount > 0) _unreadNotificationsCount--;
        notifyListeners();
      }
    }

    final success = await _service.markNotificationAsRead(id);
    if (!success) {
      // Revert if failed
      await fetchNotifications();
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    // Optimistic UI update
    for (var i = 0; i < _notificationsList.length; i++) {
      _notificationsList[i] = Map<String, dynamic>.from(_notificationsList[i])
        ..['read'] = true
        ..['is_read'] = true;
    }
    _unreadNotificationsCount = 0;
    notifyListeners();

    final success = await _service.markAllNotificationsAsRead();
    if (!success) {
      // Revert if failed
      await fetchNotifications();
    }
  }
}
