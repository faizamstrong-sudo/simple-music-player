import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';
import 'theme_provider.dart';

// Playlist state
class PlaylistState {
  final List<Playlist> userPlaylists;
  final List<Playlist> recommendedPlaylists;

  PlaylistState({
    this.userPlaylists = const [],
    this.recommendedPlaylists = const [],
  });

  PlaylistState copyWith({
    List<Playlist>? userPlaylists,
    List<Playlist>? recommendedPlaylists,
  }) {
    return PlaylistState(
      userPlaylists: userPlaylists ?? this.userPlaylists,
      recommendedPlaylists: recommendedPlaylists ?? this.recommendedPlaylists,
    );
  }
}

// Playlist provider
class PlaylistNotifier extends StateNotifier<PlaylistState> {
  final SharedPreferences _prefs;
  
  PlaylistNotifier(this._prefs) : super(PlaylistState()) {
    _loadPlaylists();
    _initRecommendedPlaylists();
  }

  // Load user playlists from storage
  Future<void> _loadPlaylists() async {
    try {
      final String? playlistsJson = _prefs.getString('user_playlists');
      if (playlistsJson != null) {
        final List<dynamic> decoded = json.decode(playlistsJson);
        final playlists = decoded
            .map((json) => Playlist.fromJson(json as Map<String, dynamic>))
            .toList();
        state = state.copyWith(userPlaylists: playlists);
      }
    } catch (e) {
      debugPrint('Error loading playlists: $e');
    }
  }

  // Save user playlists to storage
  Future<void> _savePlaylists() async {
    try {
      final playlistsJson = json.encode(
        state.userPlaylists.map((p) => p.toJson()).toList(),
      );
      await _prefs.setString('user_playlists', playlistsJson);
    } catch (e) {
      debugPrint('Error saving playlists: $e');
    }
  }

  // Initialize recommended playlists
  void _initRecommendedPlaylists() {
    final recommended = [
      Playlist(
        id: 'indo_hits_2024',
        name: 'Indo Hits 2024',
        description: 'Lagu Indonesia terpopuler 2024',
        isRecommended: true,
        songs: [
          Song(id: '1', title: 'Tak Segampang Itu', artist: 'Anggi Marito'),
          Song(id: '2', title: 'Lathi', artist: 'Weird Genius ft. Sara Fajira'),
          Song(id: '3', title: 'Hanya Satu Persinggahan', artist: 'Tulus'),
          Song(id: '4', title: 'Pilu Membiru', artist: 'Kunto Aji'),
          Song(id: '5', title: 'Untuk Perempuan Yang Sedang Dalam Pelukan', artist: 'Payung Teduh'),
        ],
      ),
      Playlist(
        id: 'galau_time',
        name: 'Galau Time',
        description: 'Soundtrack patah hati',
        isRecommended: true,
        songs: [
          Song(id: '6', title: 'Tak Segampang Itu', artist: 'Anggi Marito'),
          Song(id: '7', title: 'Konselatif', artist: 'Nadin Amizah'),
          Song(id: '8', title: 'Mantan Kekasih', artist: 'Tiara Andini'),
          Song(id: '9', title: 'Pagi', artist: 'Sal Priadi'),
          Song(id: '10', title: 'Bitterlove', artist: 'Ardhito Pramono'),
        ],
      ),
      Playlist(
        id: 'semangat_pagi',
        name: 'Semangat Pagi',
        description: 'Mulai hari dengan energi positif',
        isRecommended: true,
        songs: [
          Song(id: '11', title: 'Cerita Tentang Gunung Dan Laut', artist: 'Juicy Luicy'),
          Song(id: '12', title: 'Halu', artist: 'Feby Putri'),
          Song(id: '13', title: 'Segitiga', artist: 'Pamungkas'),
          Song(id: '14', title: 'Berlari Tanpa Kaki', artist: 'Hindia'),
          Song(id: '15', title: 'Nadir', artist: 'Juicy Luicy'),
        ],
      ),
      Playlist(
        id: 'western_pop_hits',
        name: 'Western Pop Hits',
        description: 'Chart toppers from around the world',
        isRecommended: true,
        songs: [
          Song(id: '16', title: 'Anti-Hero', artist: 'Taylor Swift'),
          Song(id: '17', title: 'Blinding Lights', artist: 'The Weeknd'),
          Song(id: '18', title: 'Levitating', artist: 'Dua Lipa'),
          Song(id: '19', title: 'Shape of You', artist: 'Ed Sheeran'),
          Song(id: '20', title: 'Die With A Smile', artist: 'Lady Gaga, Bruno Mars'),
        ],
      ),
      Playlist(
        id: 'lofi_chill',
        name: 'Lo-Fi Chill',
        description: 'Santai dengan vibes lo-fi',
        isRecommended: true,
        songs: [
          Song(id: '21', title: 'Resonance', artist: 'Home'),
          Song(id: '22', title: 'We Think Too Much', artist: 'Forrest'),
          Song(id: '23', title: 'I Miss You', artist: 'Blink-182'),
          Song(id: '24', title: 'Lofi Hip Hop Mix', artist: 'ChilledCow'),
          Song(id: '25', title: 'Coffee', artist: 'Beabadoobee'),
        ],
      ),
    ];

    state = state.copyWith(recommendedPlaylists: recommended);
  }

  // Create a new playlist
  Future<void> createPlaylist(String name, String? description) async {
    final newPlaylist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      songs: [],
    );

    state = state.copyWith(
      userPlaylists: [...state.userPlaylists, newPlaylist],
    );

    await _savePlaylists();
  }

  // Delete a playlist
  Future<void> deletePlaylist(String playlistId) async {
    state = state.copyWith(
      userPlaylists: state.userPlaylists
          .where((p) => p.id != playlistId)
          .toList(),
    );

    await _savePlaylists();
  }

  // Add song to playlist
  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    final playlists = state.userPlaylists.map((p) {
      if (p.id == playlistId) {
        return p.copyWith(songs: [...p.songs, song]);
      }
      return p;
    }).toList();

    state = state.copyWith(userPlaylists: playlists);
    await _savePlaylists();
  }

  // Remove song from playlist
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final playlists = state.userPlaylists.map((p) {
      if (p.id == playlistId) {
        return p.copyWith(
          songs: p.songs.where((s) => s.id != songId).toList(),
        );
      }
      return p;
    }).toList();

    state = state.copyWith(userPlaylists: playlists);
    await _savePlaylists();
  }
}

// Provider instance
final playlistProvider = StateNotifierProvider<PlaylistNotifier, PlaylistState>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return PlaylistNotifier(prefs);
});
