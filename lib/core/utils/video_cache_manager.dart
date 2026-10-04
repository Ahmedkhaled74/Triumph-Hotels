import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class VideoCacheManager {
  static Future<File?> getExistingCachedVideo(String url) async {
    try {
      final sanitized = url.replaceAll(RegExp(r'[^\w\s]+'), '_');
      final fileName = '$sanitized.mp4';
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');

      if (await file.exists()) {
        final length = await file.length();
        if (length > 0) {
          return file;
        }
      }
    } catch (e) {
      debugPrint('Error checking cached video: $e');
    }
    return null;
  }

  static void cacheVideoInBackground(String url) async {
    try {
      final sanitized = url.replaceAll(RegExp(r'[^\w\s]+'), '_');
      final fileName = '$sanitized.mp4';
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');

      if (await file.exists()) {
        final length = await file.length();
        if (length > 0) return; // Already cached
      }

      final request = http.Request('GET', Uri.parse(url));
      final response = await http.Client().send(request);
      
      if (response.statusCode == 200) {
        final sink = file.openWrite();
        await response.stream.pipe(sink);
        await sink.close();
        debugPrint('Background caching complete.');
      }
    } catch (e) {
      debugPrint('Error in background caching: $e');
    }
  }

  static Future<File?> getCachedVideo(String url) async {
    try {
      final sanitized = url.replaceAll(RegExp(r'[^\w\s]+'), '_');
      final fileName = '$sanitized.mp4';
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');

      if (await file.exists()) {
        final length = await file.length();
        if (length > 0) {
          debugPrint('Playing cached video from: ${file.path}');
          return file;
        }
      }

      debugPrint('Downloading video to cache...');
      final request = http.Request('GET', Uri.parse(url));
      final response = await http.Client().send(request).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final sink = file.openWrite();
        await response.stream.pipe(sink);
        await sink.close();
        debugPrint('Video cached successfully.');
        return file;
      }
    } catch (e) {
      debugPrint('Error caching video: $e');
    }
    return null;
  }
}
