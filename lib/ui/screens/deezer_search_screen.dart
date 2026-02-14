import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/song_model.dart';
import '../../services/deezer_service.dart';
import '../../services/youtube_service.dart';
import '../../providers/audio_provider.dart';
import '../../providers/theme_provider.dart';

class DeezerSearchScreen extends ConsumerStatefulWidget {
  const DeezerSearchScreen({super.key});

  @override
  ConsumerState<DeezerSearchScreen> createState() => _DeezerSearchScreenState();
}

class _DeezerSearchScreenState extends ConsumerState<DeezerSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final YouTubeService _youtubeService = YouTubeService();
  
  late DeezerService _deezerService;
  List<Song> _searchResults = [];
  bool _isLoading = false;
  bool _isPlayingTrack = false;
  String _loadingTrackId = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Initialize DeezerService with SharedPreferences from provider
    final prefs = ref.read(sharedPrefsProvider);
    _deezerService = DeezerService(prefs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _youtubeService.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final results = await _deezerService.searchTracks(query, limit: 25);
      setState(() {
        _searchResults = results;
        _isLoading = false;
        if (results.isEmpty) {
          _errorMessage = 'Tidak ada hasil ditemukan';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _playDeezerTrack(Song deezerSong) async {
    // Prevent multiple simultaneous play attempts
    if (_isPlayingTrack) return;

    setState(() {
      _isPlayingTrack = true;
      _loadingTrackId = deezerSong.id;
    });

    try {
      // Extract Deezer ID (format: "deezer:12345")
      final deezerId = deezerSong.id;
      
      // Step 1: Check cache for YouTube video ID
      String? youtubeVideoId = _deezerService.getCachedYoutubeId(deezerId);
      
      if (youtubeVideoId != null) {
        // Try to play cached video
        final success = await _tryPlayYoutubeVideo(youtubeVideoId, deezerSong);
        
        if (success) {
          setState(() {
            _isPlayingTrack = false;
            _loadingTrackId = '';
          });
          return;
        }
        
        // If cached video failed, continue to search for new match
      }
      
      // Step 2: Search YouTube for best match
      youtubeVideoId = await _youtubeService.findBestMatch(
        deezerSong.title,
        deezerSong.artist,
        deezerSong.duration,
      );
      
      if (youtubeVideoId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak dapat menemukan video YouTube yang cocok'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        setState(() {
          _isPlayingTrack = false;
          _loadingTrackId = '';
        });
        return;
      }
      
      // Step 3: Cache the mapping
      await _deezerService.cacheYoutubeId(deezerId, youtubeVideoId);
      
      // Step 4: Play the track
      final success = await _tryPlayYoutubeVideo(youtubeVideoId, deezerSong);
      
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memutar audio'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() {
        _isPlayingTrack = false;
        _loadingTrackId = '';
      });
    }
  }

  Future<bool> _tryPlayYoutubeVideo(String youtubeVideoId, Song deezerSong) async {
    try {
      // Get audio stream URL
      final streamUrl = await _youtubeService.getAudioStreamUrl(youtubeVideoId);
      
      if (streamUrl == null) {
        return false;
      }
      
      // Create a Song object with YouTube video ID for playback
      final playableSong = deezerSong.copyWith(
        id: youtubeVideoId, // Use YouTube video ID for AudioPlayerService
      );
      
      // Play through existing audio provider
      await ref.read(audioProvider.notifier).playSong(
        playableSong,
        queue: _searchResults,
        index: _searchResults.indexOf(deezerSong),
      );
      
      return true;
    } catch (e) {
      debugPrint('Error playing YouTube video: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deezer Search'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari lagu dari Deezer...',
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
                fillColor: theme.colorScheme.surface,
              ),
              onSubmitted: _performSearch,
              onChanged: (value) {
                setState(() {}); // Update to show/hide clear button
              },
              textInputAction: TextInputAction.search,
            ),
          ),
          
          // Info banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Metadata dari Deezer, audio dari YouTube',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Results
          Expanded(
            child: _buildResults(audioState, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(AudioState audioState, ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(_errorMessage),
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
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Cari lagu dari Deezer',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Audio akan diputar dari YouTube',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
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
        final isLoading = _loadingTrackId == song.id;
        
        return _buildSongTile(song, isLoading, theme);
      },
    );
  }

  Widget _buildSongTile(Song song, bool isLoading, ThemeData theme) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: theme.colorScheme.primary.withOpacity(0.1),
        ),
        child: song.albumArt != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  song.albumArt!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholder(theme);
                  },
                ),
              )
            : _buildPlaceholder(theme),
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
            style: TextStyle(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          if (song.duration != null)
            Text(
              _formatDuration(song.duration!),
              style: TextStyle(
                fontSize: 12,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
        ],
      ),
      trailing: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : IconButton(
              icon: const Icon(Icons.play_circle_filled),
              iconSize: 32,
              color: theme.colorScheme.primary,
              onPressed: () => _playDeezerTrack(song),
            ),
      onTap: isLoading ? null : () => _playDeezerTrack(song),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Center(
      child: Icon(
        Icons.music_note,
        color: theme.colorScheme.primary,
        size: 24,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}
