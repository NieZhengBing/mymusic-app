// 歌单模型类
class Playlist {
  final int id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final List<int> songIds; // 包含的歌曲ID列表

  Playlist({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.songIds,
  });

  // 创建新歌单
  factory Playlist.newPlaylist({
    required int id,
    required String name,
    String? description,
  }) {
    return Playlist(
      id: id,
      name: name,
      description: description,
      createdAt: DateTime.now(),
      songIds: [],
    );
  }

  // 获取歌单中的歌曲数量
  int get songCount => songIds.length;

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'song_ids': songIds,
    };
  }

  // 从JSON创建
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      songIds: (json['song_ids'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
    );
  }

  @override
  String toString() {
    return 'Playlist(id: $id, name: $name, songs: $songCount)';
  }
}
