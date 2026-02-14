import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/playlist_provider.dart';
import 'playlist_detail_screen.dart';

class PlaylistScreen extends ConsumerWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistState = ref.watch(playlistProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreatePlaylistDialog(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recommended playlists
            if (playlistState.recommendedPlaylists.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Rekomendasi Playlist',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...playlistState.recommendedPlaylists.map((playlist) {
                return ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                    ),
                    child: const Icon(Icons.playlist_play, color: Colors.white),
                  ),
                  title: Text(playlist.name),
                  subtitle: Text(playlist.description ?? '${playlist.songs.length} lagu'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaylistDetailScreen(playlist: playlist),
                      ),
                    );
                  },
                );
              }).toList(),
              const Divider(height: 32),
            ],
            
            // User playlists
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Playlist Saya',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            if (playlistState.userPlaylists.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.playlist_add,
                        size: 64,
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada playlist',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap tombol + untuk membuat playlist baru',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...playlistState.userPlaylists.map((playlist) {
                return ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: theme.colorScheme.primary.withOpacity(0.2),
                    ),
                    child: Icon(Icons.queue_music, color: theme.colorScheme.primary),
                  ),
                  title: Text(playlist.name),
                  subtitle: Text(playlist.description ?? '${playlist.songs.length} lagu'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDelete(context, ref, playlist.id, playlist.name),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaylistDetailScreen(playlist: playlist),
                      ),
                    );
                  },
                );
              }).toList(),
            
            const SizedBox(height: 80), // Space for mini player
          ],
        ),
      ),
    );
  }

  Future<void> _showCreatePlaylistDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Buat Playlist Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Playlist',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  ref.read(playlistProvider.notifier).createPlaylist(
                    nameController.text.trim(),
                    descController.text.trim().isEmpty ? null : descController.text.trim(),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Buat'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, String playlistId, String name) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Playlist'),
          content: Text('Yakin ingin menghapus "$name"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(playlistProvider.notifier).deletePlaylist(playlistId);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
