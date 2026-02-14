import 'song_model.dart';

class Playlist {
  final String id;
  final String name;
  final String? description;
  final List<Song> songs;
  final bool isRecommended;

  Playlist({
    required this.id,
    required this.name,
    this.description,
    required this.songs,
    this.isRecommended = false,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'songs': songs.map((song) => song.toJson()).toList(),
      'isRecommended': isRecommended,
    };
  }

  // Create from JSON
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      songs: (json['songs'] as List<dynamic>)
          .map((songJson) => Song.fromJson(songJson as Map<String, dynamic>))
          .toList(),
      isRecommended: json['isRecommended'] as bool? ?? false,
    );
  }

  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    List<Song>? songs,
    bool? isRecommended,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      songs: songs ?? this.songs,
      isRecommended: isRecommended ?? this.isRecommended,
    );
  }
}
