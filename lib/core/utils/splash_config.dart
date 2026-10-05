import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:triumph_hotels/services/api_client.dart';

/// Represents the response from GET /api/v1/splash/
class SplashConfig {
  final bool isActive;
  final bool hasVideo;
  final String? videoUrl;
  final String? posterUrl;
  final String title;
  final String subtitle;
  final String primaryButtonText;
  final String secondaryButtonText;
  final String guestLinkText;
  final double overlayOpacity;
  final bool loop;
  final bool muted;
  final int version;
  final String updatedAt;

  const SplashConfig({
    required this.isActive,
    required this.hasVideo,
    this.videoUrl,
    this.posterUrl,
    required this.title,
    required this.subtitle,
    required this.primaryButtonText,
    required this.secondaryButtonText,
    required this.guestLinkText,
    required this.overlayOpacity,
    required this.loop,
    required this.muted,
    required this.version,
    required this.updatedAt,
  });

  factory SplashConfig.fromJson(Map<String, dynamic> json) {
    String? rawVideoUrl = json['video_url'] as String?;
    String? rawPosterUrl = json['poster_url'] as String?;
    
    String? cleanVideoUrl = rawVideoUrl != null ? Uri.encodeFull(rawVideoUrl) : null;
    String? cleanPosterUrl = rawPosterUrl != null ? Uri.encodeFull(rawPosterUrl) : null;

    return SplashConfig(
      isActive: json['is_active'] as bool? ?? false,
      hasVideo: json['has_video'] as bool? ?? (cleanVideoUrl != null && cleanVideoUrl.isNotEmpty),
      videoUrl: cleanVideoUrl,
      posterUrl: cleanPosterUrl,
      title: json['title'] as String? ?? 'Triumph Hotels',
      subtitle: json['subtitle'] as String? ?? 'Where Luxury Meets Comfort',
      primaryButtonText: json['primary_button_text'] as String? ?? 'Explore Hotels',
      secondaryButtonText: json['secondary_button_text'] as String? ?? 'Sign In',
      guestLinkText: json['guest_link_text'] as String? ?? 'Continue as a guest',
      overlayOpacity: (json['overlay_opacity'] as num?)?.toDouble() ?? 0.35,
      loop: json['loop'] as bool? ?? true,
      muted: json['muted'] as bool? ?? true,
      version: (json['version'] is int)
          ? json['version'] as int
          : int.tryParse(json['version']?.toString() ?? '') ?? 0,
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  static SplashConfig? _cached;
  static SplashConfig? get cached => _cached;

  /// Fetches the latest splash config from the API.
  /// Returns null on any network/parse failure so callers can use their fallback.
  static Future<SplashConfig?> fetch({bool forceRefresh = false}) async {
    if (!forceRefresh && _cached != null) return _cached;
    try {
      final url = Uri.parse('${ApiClient.baseUrl}/splash/');
      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final config = SplashConfig.fromJson(data);
        _cached = config;
        debugPrint(
            'SplashConfig: fetched isActive=${config.isActive} hasVideo=${config.hasVideo} version=${config.version} videoUrl=${config.videoUrl}');
        return config;
      } else {
        debugPrint('SplashConfig: fetch returned status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('SplashConfig: fetch failed – $e');
    }
    return _cached;
  }
}
