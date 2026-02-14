import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';
import 'youtube_service.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  final YouTubeService _youtubeService = YouTubeService();
  
  Song? _currentSong;
  List<Song> _queue = [];
  int _currentIndex = 0;

  AudioPlayer get player => _player;
  Song? get currentSong => _currentSong;
  List<Song> get queue => _queue;
  int get currentIndex => _currentIndex;

  // Stream getters
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<bool> get playingStream => _player.playingStream;

  // Play a song
  Future<void> playSong(Song song) async {
    try {
      _currentSong = song;
      
      // Get audio stream URL from YouTube
      final streamUrl = await _youtubeService.getAudioStreamUrl(song.id);
      if (streamUrl == null) {
        throw Exception('Could not get audio stream');
      }

      // Load and play
      await _player.setUrl(streamUrl);
      await _player.play();
    } catch (e) {
      debugPrint('Error playing song: $e');
      rethrow;
    }
  }

  // Play/pause toggle
  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  // Pause
  Future<void> pause() async {
    await _player.pause();
  }

  // Resume/Play
  Future<void> play() async {
    await _player.play();
  }

  // Seek to position
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  // Set queue
  void setQueue(List<Song> songs, int startIndex) {
    _queue = songs;
    _currentIndex = startIndex;
  }

  // Play next song
  Future<void> playNext() async {
    if (_queue.isEmpty) return;
    
    _currentIndex = (_currentIndex + 1) % _queue.length;
    await playSong(_queue[_currentIndex]);
  }

  // Play previous song
  Future<void> playPrevious() async {
    if (_queue.isEmpty) return;
    
    _currentIndex = (_currentIndex - 1 + _queue.length) % _queue.length;
    await playSong(_queue[_currentIndex]);
  }

  // Stop playback
  Future<void> stop() async {
    await _player.stop();
    _currentSong = null;
  }

  // Dispose
  void dispose() {
    _player.dispose();
    _youtubeService.dispose();
  }
}
