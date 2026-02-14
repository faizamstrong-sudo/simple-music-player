import 'dart:convert';
import 'package:http/http.dart' as http;

class LyricsLine {
  final Duration timestamp;
  final String text;

  LyricsLine({required this.timestamp, required this.text});
}

class Lyrics {
  final String plainLyrics;
  final List<LyricsLine>? syncedLyrics;

  Lyrics({required this.plainLyrics, this.syncedLyrics});
}

class LyricsService {
  static const String _baseUrl = 'https://lrclib.net/api';

  // Fetch lyrics for a song
  Future<Lyrics?> getLyrics(String artist, String title) async {
    try {
      // Clean up artist and title
      final cleanArtist = _cleanSearchTerm(artist);
      final cleanTitle = _cleanSearchTerm(title);
      
      final url = Uri.parse('$_baseUrl/search?artist_name=$cleanArtist&track_name=$cleanTitle');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        
        if (results.isEmpty) {
          return null;
        }
        
        // Get the first result
        final data = results[0];
        
        final plainLyrics = data['plainLyrics'] as String? ?? '';
        final syncedLyrics = data['syncedLyrics'] as String?;
        
        List<LyricsLine>? parsedSyncedLyrics;
        if (syncedLyrics != null && syncedLyrics.isNotEmpty) {
          parsedSyncedLyrics = _parseLRC(syncedLyrics);
        }
        
        return Lyrics(
          plainLyrics: plainLyrics,
          syncedLyrics: parsedSyncedLyrics,
        );
      }
      
      return null;
    } catch (e) {
      print('Error fetching lyrics: $e');
      return null;
    }
  }

  // Parse LRC format
  List<LyricsLine> _parseLRC(String lrcContent) {
    final lines = <LyricsLine>[];
    final lrcPattern = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)');
    
    for (final line in lrcContent.split('\n')) {
      final match = lrcPattern.firstMatch(line);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final milliseconds = int.parse(match.group(3)!.padRight(3, '0'));
        final text = match.group(4)!.trim();
        
        final timestamp = Duration(
          minutes: minutes,
          seconds: seconds,
          milliseconds: milliseconds,
        );
        
        lines.add(LyricsLine(timestamp: timestamp, text: text));
      }
    }
    
    return lines;
  }

  // Clean search terms
  String _cleanSearchTerm(String term) {
    return Uri.encodeComponent(
      term
          .toLowerCase()
          .replaceAll(RegExp(r'\s*\([^)]*\)'), '') // Remove parentheses content
          .replaceAll(RegExp(r'\s*\[[^\]]*\]'), '') // Remove brackets content
          .replaceAll(RegExp(r'[^\w\s]'), '') // Remove special characters
          .trim(),
    );
  }
}
