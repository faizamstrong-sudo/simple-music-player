import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/audio_provider.dart';
import '../../services/lyrics_service.dart';
import '../widgets/batik_painter.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  final LyricsService _lyricsService = LyricsService();
  Lyrics? _lyrics;
  bool _isLoadingLyrics = false;
  final ScrollController _lyricsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadLyrics();
  }

  @override
  void dispose() {
    _lyricsScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLyrics() async {
    final audioState = ref.read(audioProvider);
    if (audioState.currentSong == null) return;

    setState(() {
      _isLoadingLyrics = true;
    });

    try {
      final lyrics = await _lyricsService.getLyrics(
        audioState.currentSong!.artist,
        audioState.currentSong!.title,
      );
      
      if (mounted) {
        setState(() {
          _lyrics = lyrics;
          _isLoadingLyrics = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLyrics = false;
        });
      }
    }
  }

  int _getCurrentLyricIndex(Duration position) {
    if (_lyrics?.syncedLyrics == null) return -1;

    for (int i = _lyrics!.syncedLyrics!.length - 1; i >= 0; i--) {
      if (position >= _lyrics!.syncedLyrics![i].timestamp) {
        return i;
      }
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioProvider);
    final audioNotifier = ref.read(audioProvider.notifier);
    final song = audioState.currentSong;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (song == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Player')),
        body: const Center(
          child: Text('Tidak ada lagu yang sedang diputar'),
        ),
      );
    }

    final currentLyricIndex = _getCurrentLyricIndex(audioState.position);

    return Scaffold(
      body: BatikBackground(
        isDark: isDark,
        opacity: 0.05,
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Sedang Diputar',
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // Album art
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: song.albumArt != null
                                ? Image.network(
                                    song.albumArt!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildPlaceholder(theme);
                                    },
                                  )
                                : _buildPlaceholder(theme),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Song info
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Text(
                              song.title,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              song.artist,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Progress bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Slider(
                              value: audioState.position.inSeconds.toDouble(),
                              // Default to 5 minutes if duration unknown (typical song length)
                              max: (audioState.duration?.inSeconds ?? 300).toDouble().clamp(1, double.infinity),
                              onChanged: audioState.duration != null 
                                  ? (value) {
                                      audioNotifier.seek(Duration(seconds: value.toInt()));
                                    }
                                  : null, // Disable slider when duration unavailable
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(audioState.position),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  Text(
                                    _formatDuration(audioState.duration ?? Duration.zero),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.skip_previous),
                            iconSize: 40,
                            onPressed: () => audioNotifier.playPrevious(),
                          ),
                          const SizedBox(width: 20),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primary,
                            ),
                            child: IconButton(
                              icon: Icon(
                                audioState.isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                              ),
                              iconSize: 40,
                              onPressed: () => audioNotifier.togglePlayPause(),
                            ),
                          ),
                          const SizedBox(width: 20),
                          IconButton(
                            icon: const Icon(Icons.skip_next),
                            iconSize: 40,
                            onPressed: () => audioNotifier.playNext(),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Lyrics section
                      _buildLyricsSection(theme, currentLyricIndex),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primary.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.music_note,
          size: 100,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildLyricsSection(ThemeData theme, int currentIndex) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lyrics, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Lirik',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_isLoadingLyrics)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_lyrics == null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Lirik tidak tersedia',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            )
          else if (_lyrics!.syncedLyrics != null && _lyrics!.syncedLyrics!.isNotEmpty)
            // Synced lyrics
            SizedBox(
              height: 300,
              child: ListView.builder(
                controller: _lyricsScrollController,
                itemCount: _lyrics!.syncedLyrics!.length,
                itemBuilder: (context, index) {
                  final line = _lyrics!.syncedLyrics![index];
                  final isActive = index == currentIndex;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      line.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isActive ? 18 : 16,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive 
                            ? theme.colorScheme.primary 
                            : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            // Plain lyrics
            SingleChildScrollView(
              child: Text(
                _lyrics!.plainLyrics,
                style: theme.textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
