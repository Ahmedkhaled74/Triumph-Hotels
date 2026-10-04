import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:triumph_hotels/app.dart';
import 'package:triumph_hotels/firebase_options.dart';
import 'package:triumph_hotels/services/fcm_service.dart';
import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  // Initialize Firebase with explicit platform options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Register the background message handler — must be done before runApp
    FCMService.registerBackgroundHandler();
  } catch (e) {
    print('Firebase init failed: $e');
  }

  runApp(const TriumphApp());
}
