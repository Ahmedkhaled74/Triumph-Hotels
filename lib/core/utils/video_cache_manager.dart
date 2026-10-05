import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Manages persistent on-device caching of video files.
///
/// Cache-invalidation is driven by the `version` field from the
/// `/api/v1/splash/` API.  When the version changes, the old file is
/// deleted and a fresh download starts in the background.  The next
/// app launch then plays the newly downloaded file.
class VideoCacheManager {
  // ── Preference keys ───────────────────────────────────────────────────────
  static const _kCachedVideoUrl     = 'vcm_cached_video_url';
  static const _kCachedVideoVersion = 'vcm_cached_video_version';

  // ── Fallback URL used when the API returns no video_url ───────────────────
  static const String homeVideoUrl =
      'https://triumphhotel.com/media/home_videos/15-7_trumph_reel_10.mp4';

  /// Minimum file size to be considered a complete download (100 KB).
  static const int minValidSizeBytes = 100 * 1024;

  static final Set<String> _activeDownloads = <String>{};

  // ── Directories ───────────────────────────────────────────────────────────

  /// Persistent directory that survives app restarts.
  static Future<Directory> _getCacheDirectory() async {
    try {
      return await getApplicationSupportDirectory();
    } catch (_) {
      try {
        return await getApplicationDocumentsDirectory();
      } catch (_) {
        return await getTemporaryDirectory();
      }
    }
  }

  /// Canonical File reference for a given URL.
  static Future<File> _getVideoFile(String url) async {
    final sanitized = url.replaceAll(RegExp(r'[^\w\s]+'), '_');
    final dir = await _getCacheDirectory();
    return File('${dir.path}/$sanitized.mp4');
  }

  // ── Version-based invalidation ────────────────────────────────────────────

  /// Saves the cached video URL and its version tag to SharedPreferences.
  static Future<void> _saveVersionMeta(String url, int version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCachedVideoUrl, url);
    await prefs.setInt(_kCachedVideoVersion, version);
    debugPrint('VideoCacheManager: saved meta – version=$version url=$url');
  }

  /// Returns the version tag that was last recorded when we cached the video.
  static Future<int?> _getSavedVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_kCachedVideoVersion)
        ? prefs.getInt(_kCachedVideoVersion)
        : null;
  }

  /// Returns the URL of the video that is currently cached on disk.
  static Future<String?> _getSavedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kCachedVideoUrl);
  }

  /// Invalidates (deletes) the cached video for [url].
  static Future<void> invalidateCache(String url) async {
    debugPrint('VideoCacheManager: invalidating cache for $url');
    try {
      final file = await _getVideoFile(url);
      if (await file.exists()) {
        await file.delete();
        debugPrint('VideoCacheManager: deleted old cache file');
      }
      // Also clear version meta so we don't accidentally reuse stale info
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kCachedVideoUrl);
      await prefs.remove(_kCachedVideoVersion);
    } catch (e) {
      debugPrint('VideoCacheManager: error during invalidation – $e');
    }
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Checks whether the locally cached video is still current for [newVersion].
  ///
  /// Returns `true`  → cache is valid, play the existing file.
  /// Returns `false` → video was updated; existing cache has been invalidated.
  static Future<bool> isCacheValid(String videoUrl, int newVersion) async {
    final savedVersion = await _getSavedVersion();
    final savedUrl     = await _getSavedUrl();

    if (savedVersion == null) {
      // First run with version tracking (upgrade from old code).
      // Don't delete anything — check if a valid file already exists on disk.
      // If it does, adopt it with the current version so we don't re-download.
      final existing = await getExistingCachedVideo(videoUrl);
      if (existing != null) {
        debugPrint('VideoCacheManager: adopting existing cache, recording version=$newVersion');
        await _saveVersionMeta(videoUrl, newVersion);
        return true; // treat as valid so we play it immediately
      }
      debugPrint('VideoCacheManager: no saved version and no cached file – treating as stale');
      return false;
    }

    if (savedUrl != null && savedUrl != videoUrl) {
      // Check if we can adopt an existing cached video for the new URL first
      final existing = await getExistingCachedVideo(videoUrl);
      if (existing != null) {
        debugPrint(
            'VideoCacheManager: adopting existing cached video for new URL, version=$newVersion');
        await _saveVersionMeta(videoUrl, newVersion);
        return true;
      }
      debugPrint('VideoCacheManager: video URL changed – invalidating old cache');
      await invalidateCache(savedUrl);
      return false;
    }

    if (savedVersion != newVersion) {
      debugPrint(
          'VideoCacheManager: version changed ($savedVersion → $newVersion) – invalidating');
      await invalidateCache(videoUrl);
      return false;
    }

    debugPrint('VideoCacheManager: cache is current (version=$newVersion)');
    return true;
  }

  /// Looks for a valid cached video file on the device across all likely directories.
  ///
  /// Returns the [File] if found and large enough, otherwise `null`.
  static Future<File?> getExistingCachedVideo(String url) async {
    try {
      final sanitized = url.replaceAll(RegExp(r'[^\w\s]+'), '_');
      // Also accept files cached under the www. variant (legacy)
      final altUrl = url.contains('www.')
          ? url.replaceFirst('www.', '')
          : url.replaceFirst('https://', 'https://www.');
      final altSanitized = altUrl.replaceAll(RegExp(r'[^\w\s]+'), '_');

      // Extract filename from URL (e.g. 15-7_trumph_reel_10.mp4)
      final uri = Uri.tryParse(url);
      final filename = uri != null && uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
      final sanitizedFilename = filename.replaceAll(RegExp(r'[^\w\s]+'), '_');

      final dirs = <Directory>[];
      try { dirs.add(await getApplicationSupportDirectory()); } catch (_) {}
      try { dirs.add(await getApplicationDocumentsDirectory()); } catch (_) {}
      try { dirs.add(await getTemporaryDirectory()); } catch (_) {}

      for (final dir in dirs) {
        for (final name in ['$sanitized.mp4', '$altSanitized.mp4']) {
          final file = File('${dir.path}/$name');
          if (await file.exists()) {
            final length = await file.length();
            if (length >= minValidSizeBytes) {
              debugPrint(
                  'VideoCacheManager: found valid cached video '
                  '(${(length / (1024 * 1024)).toStringAsFixed(1)} MB) '
                  'at ${file.path}');
              return file;
            } else {
              debugPrint(
                  'VideoCacheManager: purging incomplete cache ($length bytes)');
              await file.delete().catchError((_) => file);
            }
          }
        }

        // Secondary check: look for any valid .mp4 in cache matching the video filename
        if (sanitizedFilename.isNotEmpty && await dir.exists()) {
          try {
            final entities = await dir.list().toList();
            for (final entity in entities) {
              if (entity is File &&
                  entity.path.endsWith('.mp4') &&
                  !entity.path.endsWith('.part')) {
                if (entity.path.contains(sanitizedFilename)) {
                  final length = await entity.length();
                  if (length >= minValidSizeBytes) {
                    debugPrint(
                        'VideoCacheManager: found matching cached video by filename '
                        '(${(length / (1024 * 1024)).toStringAsFixed(1)} MB) '
                        'at ${entity.path}');
                    final targetFile = File('${dir.path}/$sanitized.mp4');
                    if (!await targetFile.exists()) {
                      try {
                        await entity.copy(targetFile.path);
                        return targetFile;
                      } catch (_) {
                        return entity;
                      }
                    }
                    return targetFile;
                  }
                }
              }
            }
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('VideoCacheManager: error checking cached video – $e');
    }
    return null;
  }

  /// Downloads [url] in the background and saves it to persistent storage.
  ///
  /// Optionally records [version] in SharedPreferences once the download
  /// completes so future launches know the cache is current.
  static void cacheVideoInBackground(String url, {int? version}) async {
    if (_activeDownloads.contains(url)) {
      debugPrint('VideoCacheManager: download already in progress for $url');
      return;
    }
    _activeDownloads.add(url);

    try {
      final file     = await _getVideoFile(url);
      final partFile = File('${file.path}.part');

      // Skip if a complete file already exists on disk
      if (await file.exists()) {
        final length = await file.length();
        if (length >= minValidSizeBytes) {
          // Already complete — just make sure the version meta is saved
          if (version != null) {
            final savedVer = await _getSavedVersion();
            if (savedVer != version) await _saveVersionMeta(url, version);
          }
          debugPrint('VideoCacheManager: skipping download – file already cached');
          _activeDownloads.remove(url);
          return;
        }
      }

      debugPrint('VideoCacheManager: starting background download of $url');
      final client   = http.Client();
      final request  = http.Request('GET', Uri.parse(url));
      final response = await client.send(request);

      if (response.statusCode == 200) {
        if (await partFile.exists()) {
          await partFile.delete().catchError((_) => partFile);
        }
        final sink = partFile.openWrite();
        await response.stream.pipe(sink);
        await sink.close();

        final downloadedLength = await partFile.length();
        if (downloadedLength >= minValidSizeBytes) {
          if (await file.exists()) {
            await file.delete().catchError((_) => file);
          }
          await partFile.rename(file.path);
          // Record the version so next launch knows this cache is fresh
          if (version != null) {
            await _saveVersionMeta(url, version);
          }
          debugPrint(
              'VideoCacheManager: cached ${(downloadedLength / (1024 * 1024)).toStringAsFixed(1)} MB');
        } else {
          debugPrint('VideoCacheManager: download too small – discarding');
          await partFile.delete().catchError((_) => partFile);
        }
      }
    } catch (e) {
      debugPrint('VideoCacheManager: background download error – $e');
    } finally {
      _activeDownloads.remove(url);
    }
  }
}
