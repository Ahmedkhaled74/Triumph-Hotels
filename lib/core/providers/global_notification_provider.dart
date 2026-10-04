import 'package:flutter/material.dart';
import 'package:triumph_hotels/models/global_notification.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalNotificationProvider extends ChangeNotifier {
  
  List<GlobalNotification> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastSeenTime;

  List<GlobalNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  int get unreadCount {
    if (_lastSeenTime == null) return _notifications.length;
    return _notifications.where((n) => n.createdAt.isAfter(_lastSeenTime!)).length;
  }

  GlobalNotificationProvider() {
    _loadLastSeenTime().then((_) {
      fetchNotifications();
    });
  }

  Future<void> _loadLastSeenTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeStr = prefs.getString('last_seen_global_notification_time');
    if (timeStr != null) {
      _lastSeenTime = DateTime.parse(timeStr);
    }
  }

  Future<void> markAllAsRead() async {
    if (_notifications.isEmpty) return;
    
    // Set to the most recent notification's time (which is the first one since it's sorted)
    _lastSeenTime = _notifications.first.createdAt;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_seen_global_notification_time', _lastSeenTime!.toIso8601String());
    
    notifyListeners();
  }

  Future<void> fetchNotifications({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }
    
    _errorMessage = null;

    try {
      final url = Uri.parse('https://triumphhotel.com/api/notifications/');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['notifications'] is List) {
          final List<dynamic> data = responseData['notifications'];
          _notifications = data.map((json) => GlobalNotification.fromJson(json)).toList();
          
          // Sort by date descending
          _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }
      } else {
        _errorMessage = 'Failed to load notifications. Server returned ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Failed to load notifications: $e';
      print('Error fetching global notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
