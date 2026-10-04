import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ─── Top-level background handler (must be outside any class) ───────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase MUST be initialized before any Firebase calls in background isolates
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  
  // If the backend sent a "data-only" payload, Firebase won't show a banner automatically.
  // We must intercept it and show it manually.
  if (message.notification == null) {
    final title = message.data['title'] ?? 'TicketX Update';
    final body = message.data['body'] ?? message.data['message'] ?? 'You have a new notification.';
    
    final plugin = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    await plugin.initialize(const InitializationSettings(android: androidSettings));
    
    await plugin.show(
      message.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
      ),
    );
  }
}

// ─── FCM Service ─────────────────────────────────────────────────────────────
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  static const String _baseUrl = 'https://ticketx.triumphhotel.com';
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  static void registerBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  bool _isForegroundListenerSetup = false;

  void _setupForegroundListener() {
    if (_isForegroundListenerSetup) return;
    _isForegroundListenerSetup = true;

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/launcher_icon',
            ),
          ),
        );
      } else if (notification == null) {
        // Foreground data-only fallback
        final title = message.data['title'] ?? 'TicketX Update';
        final body = message.data['body'] ?? message.data['message'] ?? 'You have a new notification.';
        flutterLocalNotificationsPlugin.show(
          message.hashCode,
          title,
          body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/launcher_icon',
            ),
          ),
        );
      }
    });
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void setupPushNotifications(String sessionId) {
    _doSetup(sessionId);
  }

  Future<void> initializeGlobalPush() async {
    try {
      await _initializeLocalNotifications();
      final messaging = FirebaseMessaging.instance;

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final token = await messaging.getToken();
        
        if (token != null) {
          await _registerGlobalTokenWithBackend(token);
        }

        // We already listen for token refresh in GuestPortalProvider's setup
        // But doing it here globally ensures we catch it for anonymous users too
        messaging.onTokenRefresh.listen((newToken) {
          _registerGlobalTokenWithBackend(newToken);
        });

        _setupForegroundListener();
      }
    } catch (e) {
      print('FCM: Error initializing global push notifications: $e');
    }
  }

  Future<void> _doSetup(String sessionId) async {
    try {
      await _initializeLocalNotifications();
      final messaging = FirebaseMessaging.instance;

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final token = await messaging.getToken();
        
        if (token != null) {
          await _registerTokenWithBackend(sessionId: sessionId, token: token);
        }

        messaging.onTokenRefresh.listen((newToken) {
          _registerTokenWithBackend(sessionId: sessionId, token: newToken);
        });

        _setupForegroundListener();
      }
    } catch (e) {
      print('FCM: Error setting up push notifications: $e');
    }
  }

  Future<void> _registerTokenWithBackend({
    required String sessionId,
    required String token,
  }) async {
    try {
      print('\n=========================================');
      print('FCM: Registering token with backend...');
      print('URL: POST $_baseUrl/api/guest/fcm/register');
      print('FULL PAYLOAD SENT TO BACKEND:');
      print(jsonEncode({
        'sessionId': sessionId,
        'fcmToken': token,
        'token': token,
        'fcm_token': token,
        'pushToken': token,
      }));
      print('=========================================');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/guest/fcm/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sessionId': sessionId,
          'fcmToken': token,
          'token': token,
          'fcm_token': token,
          'pushToken': token,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ FCM: Token registered! Response: ${response.body}');
      } else {
        print('❌ FCM: Registration failed. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('❌ FCM: Failed to register token: $e');
    }
  }

  Future<void> _registerGlobalTokenWithBackend(String token) async {
    try {
      print('\n=========================================');
      print('FCM: Registering global push token...');
      print('=========================================');
      
      await http.post(
        Uri.parse('https://triumphhotel.com/api/push-subscribe/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );
      print('✅ FCM: Global token registered successfully.');
    } catch (e) {
      print('❌ FCM: Failed to register global token: $e');
    }
  }

  Future<void> unregisterToken(String sessionId) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/api/guest/push/unregister-fcm'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId}),
      );
    } catch (e) {
      print('FCM: Network error while unregistering token: $e');
    }
  }

  void setupNotificationRouting({
    required Function(String url) onNavigate,
  }) {
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null && message.data.containsKey('url')) {
        onNavigate(message.data['url'] as String);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data.containsKey('url')) {
        onNavigate(message.data['url'] as String);
      }
    });
  }
}
