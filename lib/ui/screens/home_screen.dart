import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/audio_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/youtube_service.dart';
import '../../models/song_model.dart';
import '../widgets/greeting_header.dart';
import '../widgets/recommendation_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final YouTubeService _youtubeService = YouTubeService();

  // Indonesian popular songs
  final List<Song> _indoSongs = [
    Song(id: '1', title: 'Tak Segampang Itu', artist: 'Anggi Marito'),
    Song(id: '2', title: 'Lathi', artist: 'Weird Genius ft. Sara Fajira'),
    Song(id: '3', title: 'Hanya Satu Persinggahan', artist: 'Tulus'),
    Song(id: '4', title: 'Pilu Membiru', artist: 'Kunto Aji'),
    Song(id: '5', title: 'Untuk Perempuan Yang Sedang Dalam Pelukan', artist: 'Payung Teduh'),
    Song(id: '6', title: 'Konselatif', artist: 'Nadin Amizah'),
    Song(id: '7', title: 'Cerita Tentang Gunung Dan Laut', artist: 'Juicy Luicy'),
    Song(id: '8', title: 'Halu', artist: 'Feby Putri'),
  ];

  // Western popular songs
  final List<Song> _westernSongs = [
    Song(id: '9', title: 'Anti-Hero', artist: 'Taylor Swift'),
    Song(id: '10', title: 'Blinding Lights', artist: 'The Weeknd'),
    Song(id: '11', title: 'Levitating', artist: 'Dua Lipa'),
    Song(id: '12', title: 'Shape of You', artist: 'Ed Sheeran'),
    Song(id: '13', title: 'Die With A Smile', artist: 'Lady Gaga, Bruno Mars'),
    Song(id: '14', title: 'Flowers', artist: 'Miley Cyrus'),
    Song(id: '15', title: 'As It Was', artist: 'Harry Styles'),
  ];

  // Trending songs (mix)
  final List<Song> _trendingSongs = [
    Song(id: '16', title: 'Tak Segampang Itu', artist: 'Anggi Marito'),
    Song(id: '17', title: 'Anti-Hero', artist: 'Taylor Swift'),
    Song(id: '18', title: 'Halu', artist: 'Feby Putri'),
    Song(id: '19', title: 'Blinding Lights', artist: 'The Weeknd'),
    Song(id: '20', title: 'Lathi', artist: 'Weird Genius'),
  ];

  Future<void> _playSong(Song song) async {
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mencari ${song.title}...'),
          duration: const Duration(seconds: 2),
        ),
      );

      // Search on YouTube
      final results = await _youtubeService.searchSongs(
        '${song.title} ${song.artist}',
        maxResults: 1,
      );

      if (results.isNotEmpty) {
        // Play the song
        await ref.read(audioProvider.notifier).playSong(results[0]);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lagu tidak ditemukan')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting header
              GreetingHeader(isDark: isDark),
              
              // Trending section
              _buildSection(
                'Trending Minggu Ini',
                _trendingSongs,
                Icons.trending_up,
              ),
              
              // Indonesian popular section
              _buildSection(
                'Lagu Indonesia Populer',
                _indoSongs,
                Icons.flag,
              ),
              
              // Western popular section
              _buildSection(
                'Lagu Barat Populer',
                _westernSongs,
                Icons.language,
              ),
              
              const SizedBox(height: 80), // Space for mini player
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Song> songs, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              return RecommendationCard(
                song: songs[index],
                onTap: () => _playSong(songs[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
