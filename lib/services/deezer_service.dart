import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song_model.dart';

/// Service for searching music metadata from Deezer and managing YouTube video ID cache
class DeezerService {
  static const String _baseUrl = 'https://api.deezer.com';
  static const String _cachePrefix = 'deezer_youtube_cache_';

  final SharedPreferences _prefs;

  DeezerService(this._prefs);

  /// Search for tracks on Deezer
  /// Returns a list of Song objects with Deezer metadata
  Future<List<Song>> searchTracks(String query, {int limit = 25}) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse('$_baseUrl/search?q=$encodedQuery&limit=$limit');
      
      final response = await http.get(url);
      
      if (response.statusCode != 200) {
        debugPrint('Deezer API error: ${response.statusCode}');
        return [];
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final results = data['data'] as List<dynamic>?;
      
      if (results == null || results.isEmpty) {
        return [];
      }

      final songs = <Song>[];
      for (final item in results) {
        try {
          final track = item as Map<String, dynamic>;
          final artist = track['artist'] as Map<String, dynamic>?;
          final album = track['album'] as Map<String, dynamic>?;
          
          songs.add(Song(
            id: 'deezer:${track['id']}',
            title: track['title'] as String? ?? 'Unknown',
            artist: artist?['name'] as String? ?? 'Unknown Artist',
            albumArt: album?['cover_medium'] as String?,
            duration: Duration(seconds: track['duration'] as int? ?? 0),
          ));
        } catch (e) {
          debugPrint('Error parsing Deezer track: $e');
          continue;
        }
      }

      return songs;
    } catch (e) {
      debugPrint('Error searching Deezer: $e');
      return [];
    }
  }

  /// Get cached YouTube video ID for a Deezer track ID
  /// Returns null if not found in cache
  String? getCachedYoutubeId(String deezerId) {
    try {
      final cacheKey = _cachePrefix + deezerId;
      return _prefs.getString(cacheKey);
    } catch (e) {
      debugPrint('Error reading cache: $e');
      return null;
    }
  }

  /// Cache a YouTube video ID for a Deezer track ID
  /// This speeds up subsequent plays of the same track
  Future<void> cacheYoutubeId(String deezerId, String youtubeId) async {
    try {
      final cacheKey = _cachePrefix + deezerId;
      await _prefs.setString(cacheKey, youtubeId);
    } catch (e) {
      debugPrint('Error writing cache: $e');
    }
  }

  /// Clear all cached Deezer-YouTube mappings
  Future<void> clearCache() async {
    try {
      final keys = _prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_cachePrefix)) {
          await _prefs.remove(key);
        }
      }
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }
}
