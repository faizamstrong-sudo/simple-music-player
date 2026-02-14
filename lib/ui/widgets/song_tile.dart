import 'package:flutter/material.dart';
import '../../models/song_model.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final VoidCallback? onMorePressed;
  final bool isPlaying;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.onMorePressed,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
        style: TextStyle(
          fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
          color: isPlaying ? theme.colorScheme.primary : null,
        ),
      ),
      subtitle: Text(
        song.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: theme.textTheme.bodySmall?.color,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPlaying)
            Icon(
              Icons.graphic_eq,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          if (onMorePressed != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: onMorePressed,
              iconSize: 20,
            ),
          ],
        ],
      ),
      onTap: onTap,
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
}
