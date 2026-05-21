// 歌曲模型类
class Song {
  final int id;
  final String title;
  final String artist;
  final String album;
  final String path; // 本地文件路径或在线URL
  final Duration duration;
  final String? coverPath; // 封面路径
  final bool isLocal; // 是否是本地文件

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.path,
    required this.duration,
    this.coverPath,
    this.isLocal = true,
  });

  // 从文件路径创建（简化版本）
  factory Song.fromFilePath({
    required int id,
    required String filePath,
    String? title,
    String? artist,
    String? album,
    Duration? duration,
  }) {
    // 从文件名提取标题
    final fileName = filePath.split('/').last;
    final nameWithoutExt = fileName.replaceAll(RegExp(r'\.[^.]*$'), '');

    return Song(
      id: id,
      title: title ?? nameWithoutExt,
      artist: artist ?? '未知歌手',
      album: album ?? '未知专辑',
      path: filePath,
      duration: duration ?? Duration.zero,
      isLocal: true,
    );
  }

  // 格式化时长显示 (mm:ss)
  String get formattedDuration {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'path': path,
      'duration_ms': duration.inMilliseconds,
      'cover_path': coverPath,
      'is_local': isLocal,
    };
  }

  // 从JSON创建
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as int,
      title: json['title'] as String? ?? '未知歌曲',
      artist: json['artist'] as String? ?? '未知歌手',
      album: json['album'] as String? ?? '未知专辑',
      path: json['path'] as String,
      duration: Duration(milliseconds: json['duration_ms'] as int? ?? 0),
      coverPath: json['cover_path'] as String?,
      isLocal: json['is_local'] as bool? ?? true,
    );
  }

  @override
  String toString() {
    return 'Song(id: $id, title: $title, artist: $artist, path: $path)';
  }
}
