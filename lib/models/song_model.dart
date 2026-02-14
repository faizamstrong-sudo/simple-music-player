class Song {
  final String id;
  final String title;
  final String artist;
  final String? albumArt;
  final String? youtubeUrl;
  final Duration? duration;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    this.albumArt,
    this.youtubeUrl,
    this.duration,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'albumArt': albumArt,
      'youtubeUrl': youtubeUrl,
      'duration': duration?.inSeconds,
    };
  }

  // Create from JSON
  factory Song.fromJson(Map<String, dynamic> json) {
    Duration? parseDuration(dynamic value) {
      if (value == null) return null;
      if (value is int) return Duration(seconds: value);
      if (value is String) {
        final parsed = int.tryParse(value);
        return parsed != null ? Duration(seconds: parsed) : null;
      }
      return null;
    }

    return Song(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      albumArt: json['albumArt'] as String?,
      youtubeUrl: json['youtubeUrl'] as String?,
      duration: parseDuration(json['duration']),
    );
  }

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? albumArt,
    String? youtubeUrl,
    Duration? duration,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      albumArt: albumArt ?? this.albumArt,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      duration: duration ?? this.duration,
    );
  }
}
