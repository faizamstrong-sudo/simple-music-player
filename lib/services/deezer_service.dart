import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song_model.dart';
import 'youtube_service.dart';

/// Service for interacting with Deezer API and managing YouTube ID caching
class DeezerService {
  static const String _baseUrl = 'https://api.deezer.com';
  static const String _cachePrefix = 'deezer_youtube_';
  
  final SharedPreferences _prefs;
  final YouTubeService _youtubeService;
  final bool _ownsYoutubeService;
  
  DeezerService({
    required SharedPreferences prefs,
    YouTubeService? youtubeService,
  })  : _prefs = prefs,
        _youtubeService = youtubeService ?? YouTubeService(),
        _ownsYoutubeService = youtubeService == null;

  /// Search for tracks on Deezer
  /// Returns a list of songs with Deezer metadata
  Future<List<Song>> searchTracks(String query, {int maxResults = 20}) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse('$_baseUrl/search?q=$encodedQuery&limit=$maxResults');
      
      debugPrint('🔍 [Deezer] Searching for: $query');
      
      final response = await http.get(url);
      
      if (response.statusCode != 200) {
        debugPrint('❌ [Deezer] API error: ${response.statusCode}');
        throw Exception('Deezer API returned status ${response.statusCode}');
      }
      
      final data = json.decode(response.body);
      final tracks = data['data'] as List<dynamic>?;
      
      if (tracks == null || tracks.isEmpty) {
        debugPrint('⚠️ [Deezer] No results found');
        return [];
      }
      
      final songs = <Song>[];
      for (var track in tracks) {
        try {
          // Create a unique ID combining Deezer track ID with artist
          final deezerId = track['id'].toString();
          final title = track['title'] as String? ?? 'Unknown Title';
          final artist = track['artist']?['name'] as String? ?? 'Unknown Artist';
          final albumArt = track['album']?['cover_medium'] as String?;
          final durationSeconds = track['duration'] as int? ?? 0;
          
          songs.add(Song(
            id: 'deezer_$deezerId',
            title: title,
            artist: artist,
            albumArt: albumArt,
            duration: Duration(seconds: durationSeconds),
          ));
        } catch (e) {
          debugPrint('⚠️ [Deezer] Error parsing track: $e');
          continue;
        }
      }
      
      debugPrint('✅ [Deezer] Found ${songs.length} tracks');
      return songs;
    } catch (e) {
      debugPrint('❌ [Deezer] Search error: $e');
      rethrow;
    }
  }

  /// Get cached YouTube ID for a Deezer track
  /// Returns null if not cached
  Future<String?> getCachedYoutubeId(String deezerTrackId) async {
    try {
      final cacheKey = '$_cachePrefix$deezerTrackId';
      final cachedId = _prefs.getString(cacheKey);
      
      if (cachedId != null) {
        debugPrint('📦 [Deezer] Cache hit for $deezerTrackId -> $cachedId');
      } else {
        debugPrint('❌ [Deezer] Cache miss for $deezerTrackId');
      }
      
      return cachedId;
    } catch (e) {
      debugPrint('❌ [Deezer] Error reading cache: $e');
      return null;
    }
  }

  /// Cache YouTube ID for a Deezer track
  Future<void> cacheYoutubeId(String deezerTrackId, String youtubeId) async {
    try {
      final cacheKey = '$_cachePrefix$deezerTrackId';
      await _prefs.setString(cacheKey, youtubeId);
      debugPrint('💾 [Deezer] Cached $deezerTrackId -> $youtubeId');
    } catch (e) {
      debugPrint('❌ [Deezer] Error writing cache: $e');
    }
  }

  /// Find YouTube match for a Deezer track
  /// First checks cache, then falls back to YouTube search
  /// Returns a Song with YouTube URL populated
  Future<Song?> findYoutubeMatch(Song deezerSong) async {
    try {
      // Check cache first
      final cachedYoutubeId = await getCachedYoutubeId(deezerSong.id);
      
      if (cachedYoutubeId != null) {
        debugPrint('✅ [Deezer] Using cached YouTube ID: $cachedYoutubeId');
        return deezerSong.copyWith(
          id: cachedYoutubeId,
          youtubeUrl: 'https://youtube.com/watch?v=$cachedYoutubeId',
        );
      }
      
      // Cache miss - search YouTube
      debugPrint('🔍 [Deezer] Searching YouTube for: ${deezerSong.artist} - ${deezerSong.title}');
      final searchQuery = '${deezerSong.artist} ${deezerSong.title}';
      final youtubeResults = await _youtubeService.searchSongs(searchQuery, maxResults: 1);
      
      if (youtubeResults.isEmpty) {
        debugPrint('❌ [Deezer] No YouTube match found');
        return null;
      }
      
      final youtubeMatch = youtubeResults.first;
      
      // Cache the mapping
      await cacheYoutubeId(deezerSong.id, youtubeMatch.id);
      
      // Return combined song with YouTube details
      return deezerSong.copyWith(
        id: youtubeMatch.id,
        youtubeUrl: youtubeMatch.youtubeUrl,
        duration: youtubeMatch.duration ?? deezerSong.duration,
      );
    } catch (e) {
      debugPrint('❌ [Deezer] Error finding YouTube match: $e');
      return null;
    }
  }

  void dispose() {
    // Only dispose the YouTube service if we created it
    if (_ownsYoutubeService) {
      _youtubeService.dispose();
    }
  }
}
