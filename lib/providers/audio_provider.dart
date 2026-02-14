import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';
import '../services/audio_service.dart';

// Audio state class
class AudioState {
  final Song? currentSong;
  final List<Song> queue;
  final int currentIndex;
  final bool isPlaying;
  final Duration position;
  final Duration? duration;

  AudioState({
    this.currentSong,
    this.queue = const [],
    this.currentIndex = 0,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration,
  });

  AudioState copyWith({
    Song? currentSong,
    List<Song>? queue,
    int? currentIndex,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
  }) {
    return AudioState(
      currentSong: currentSong ?? this.currentSong,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

// Audio provider
class AudioNotifier extends StateNotifier<AudioState> {
  final AudioPlayerService _audioService = AudioPlayerService();
  
  AudioNotifier() : super(AudioState()) {
    _init();
  }

  void _init() {
    // Listen to player state changes
    _audioService.playingStream.listen((playing) {
      state = state.copyWith(isPlaying: playing);
    });

    // Listen to position changes
    _audioService.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });

    // Listen to duration changes
    _audioService.durationStream.listen((duration) {
      state = state.copyWith(duration: duration);
    });
  }

  // Play a song
  Future<void> playSong(Song song, {List<Song>? queue, int? index}) async {
    try {
      if (queue != null) {
        _audioService.setQueue(queue, index ?? 0);
        state = state.copyWith(
          queue: queue,
          currentIndex: index ?? 0,
        );
      }
      
      await _audioService.playSong(song);
      state = state.copyWith(currentSong: song);
    } catch (e) {
      debugPrint('Error playing song: $e');
    }
  }

  // Toggle play/pause
  Future<void> togglePlayPause() async {
    await _audioService.togglePlayPause();
  }

  // Play next
  Future<void> playNext() async {
    await _audioService.playNext();
    state = state.copyWith(
      currentSong: _audioService.currentSong,
      currentIndex: _audioService.currentIndex,
    );
  }

  // Play previous
  Future<void> playPrevious() async {
    await _audioService.playPrevious();
    state = state.copyWith(
      currentSong: _audioService.currentSong,
      currentIndex: _audioService.currentIndex,
    );
  }

  // Seek
  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
  }

  // Stop
  Future<void> stop() async {
    await _audioService.stop();
    state = AudioState();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}

// Provider instance
final audioProvider = StateNotifierProvider<AudioNotifier, AudioState>((ref) {
  return AudioNotifier();
});
