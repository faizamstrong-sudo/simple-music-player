import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/song_model.dart';

class YouTubeService {
  final YoutubeExplode _yt = YoutubeExplode();

  // Search for songs
  Future<List<Song>> searchSongs(String query, {int maxResults = 10}) async {
    try {
      final searchResults = await _yt.search.search(query);
      final songs = <Song>[];

      for (var i = 0; i < searchResults.length && i < maxResults; i++) {
        final video = searchResults[i];
        songs.add(Song(
          id: video.id.value,
          title: video.title,
          artist: video.author,
          albumArt: video.thumbnails.mediumResUrl,
          youtubeUrl: 'https://youtube.com/watch?v=${video.id.value}',
          duration: video.duration,
        ));
      }

      return songs;
    } catch (e) {
      debugPrint('Error searching YouTube: $e');
      return [];
    }
  }

  // Get audio stream URL for a video
  Future<String?> getAudioStreamUrl(String videoId) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final audioStream = manifest.audioOnly.withHighestBitrate();
      return audioStream.url.toString();
    } catch (e) {
      debugPrint('Error getting audio stream: $e');
      return null;
    }
  }

  // Get video details
  Future<Song?> getVideoDetails(String videoId) async {
    try {
      final video = await _yt.videos.get(videoId);
      return Song(
        id: video.id.value,
        title: video.title,
        artist: video.author,
        albumArt: video.thumbnails.mediumResUrl,
        youtubeUrl: 'https://youtube.com/watch?v=${video.id.value}',
        duration: video.duration,
      );
    } catch (e) {
      debugPrint('Error getting video details: $e');
      return null;
    }
  }

  void dispose() {
    _yt.close();
  }
}
