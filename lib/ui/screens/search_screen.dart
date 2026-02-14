import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/youtube_service.dart';
import '../../models/song_model.dart';
import '../../providers/audio_provider.dart';
import '../widgets/song_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final YouTubeService _youtubeService = YouTubeService();
  
  List<Song> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _searchController.dispose();
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
      final results = await _youtubeService.searchSongs(query, maxResults: 20);
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

  void _playSong(Song song, int index) {
    ref.read(audioProvider.notifier).playSong(
      song,
      queue: _searchResults,
      index: index,
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Lagu'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari lagu, artist...',
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
              color: Theme.of(context).colorScheme.error,
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
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Cari lagu favoritmu',
              style: Theme.of(context).textTheme.titleMedium,
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
        final isPlaying = audioState.currentSong?.id == song.id;
        
        return SongTile(
          song: song,
          isPlaying: isPlaying,
          onTap: () => _playSong(song, index),
        );
      },
    );
  }
}
