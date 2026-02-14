import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/deezer_service.dart';
import '../../models/song_model.dart';
import '../../providers/audio_provider.dart';
import '../../providers/theme_provider.dart';

/// Screen for searching Deezer tracks and playing them via YouTube
class DeezerSearchScreen extends ConsumerStatefulWidget {
  const DeezerSearchScreen({super.key});

  @override
  ConsumerState<DeezerSearchScreen> createState() => _DeezerSearchScreenState();
}

class _DeezerSearchScreenState extends ConsumerState<DeezerSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  DeezerService? _deezerService;
  
  List<Song> _searchResults = [];
  bool _isLoading = false;
  bool _isPlaying = false;
  String? _playingSongId;

  /// Get or initialize the Deezer service
  DeezerService _getDeezerService() {
    if (_deezerService == null) {
      final prefs = ref.read(sharedPrefsProvider);
      _deezerService = DeezerService(prefs: prefs);
    }
    return _deezerService!;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _deezerService?.dispose();
    super.dispose();
  }

  /// Perform Deezer search
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _getDeezerService().searchTracks(query, maxResults: 30);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });

      if (results.isEmpty) {
        _showSnackBar('Tidak ada hasil ditemukan', isError: false);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error mencari lagu: $e', isError: true);
    }
  }

  /// Play a Deezer track by finding its YouTube match
  Future<void> _playDeezerTrack(Song deezerSong) async {
    setState(() {
      _isPlaying = true;
      _playingSongId = deezerSong.id;
    });

    try {
      // Find YouTube match (checks cache first, then searches)
      final youtubeMatch = await _getDeezerService().findYoutubeMatch(deezerSong);
      
      if (youtubeMatch == null) {
        _showSnackBar('Tidak dapat menemukan lagu di YouTube', isError: true);
        setState(() {
          _isPlaying = false;
          _playingSongId = null;
        });
        return;
      }

      // Play the song via audio provider
      await ref.read(audioProvider.notifier).playSong(
        youtubeMatch,
        queue: _searchResults,
        index: _searchResults.indexOf(deezerSong),
      );

      setState(() {
        _isPlaying = false;
        _playingSongId = null;
      });
      
      _showSnackBar('Memutar: ${deezerSong.title}', isError: false);
    } catch (e) {
      setState(() {
        _isPlaying = false;
        _playingSongId = null;
      });
      _showSnackBar('Error memutar lagu: $e', isError: true);
    }
  }

  /// Show snackbar for user feedback
  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError 
            ? Theme.of(context).colorScheme.error 
            : Theme.of(context).colorScheme.primary,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari di Deezer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari lagu di Deezer...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onSubmitted: _performSearch,
              onChanged: (value) {
                setState(() {}); // Update UI for clear button
              },
              textInputAction: TextInputAction.search,
            ),
          ),
          
          // Results
          Expanded(
            child: _buildResults(audioState),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(AudioState audioState) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Mencari lagu di Deezer...'),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Cari lagu di Deezer',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Lagu akan diputar melalui YouTube',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final song = _searchResults[index];
        final isCurrentSong = audioState.currentSong?.id == song.id;
        final isLoadingThisSong = _isPlaying && _playingSongId == song.id;
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: song.albumArt != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      song.albumArt!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 50,
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: const Icon(Icons.music_note),
                        );
                      },
                    ),
                  )
                : Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.music_note),
                  ),
            title: Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.music_video,
                      size: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Deezer',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: isLoadingThisSong
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: Icon(
                      isCurrentSong && audioState.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                    ),
                    iconSize: 40,
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      if (isCurrentSong && audioState.isPlaying) {
                        ref.read(audioProvider.notifier).togglePlayPause();
                      } else {
                        _playDeezerTrack(song);
                      }
                    },
                  ),
            onTap: () => _playDeezerTrack(song),
          ),
        );
      },
    );
  }
}
