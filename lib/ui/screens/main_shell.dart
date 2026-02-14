import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../providers/audio_provider.dart';
import '../widgets/mini_player.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'playlist_screen.dart';
import 'player_screen.dart';
import 'equalizer_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    PlaylistScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openFullPlayer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PlayerScreen(),
      ),
    );
  }

  void _openEqualizer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EqualizerScreen(),
      ),
    );
  }

  void _showSettingsMenu() {
    final themeState = ref.read(themeProvider);
    
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.equalizer),
                title: const Text('Equalizer'),
                onTap: () {
                  Navigator.pop(context);
                  _openEqualizer();
                },
              ),
              ListTile(
                leading: Icon(
                  themeState.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                title: Text(
                  themeState.isDarkMode ? 'Mode Terang' : 'Mode Gelap',
                ),
                trailing: Switch(
                  value: themeState.isDarkMode,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                ),
                onTap: () {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
              ),
              const ListTile(
                leading: Icon(Icons.info),
                title: Text('FASHIN Play'),
                subtitle: Text('Version 1.0.0'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioProvider);
    final hasSong = audioState.currentSong != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FASHIN Play'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsMenu,
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini player
          if (hasSong)
            MiniPlayer(onTap: _openFullPlayer),
          
          // Bottom navigation
          BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Cari',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.queue_music),
                label: 'Playlist',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
