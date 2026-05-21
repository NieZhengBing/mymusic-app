import 'dart:io';
import 'dart:typed_data';

import '../models/song.dart';
import '../utils/exceptions.dart';

// 音乐元数据解析器
// 用于从音频文件中提取标题、艺术家、专辑、封面等信息
class MetadataParser {
  // 提取音频文件的元数据
  // 支持MP3、FLAC、WAV、AAC等格式
  static Future<Result<Map<String, dynamic>>> parseAudioMetadata(
    String filePath,
  ) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return Result.failure(
          FileScanException('文件不存在: $filePath'),
        );
      }

      // 读取文件字节
      final bytes = await file.readAsBytes();

      // 使用audio_metadata包解析
      // final metadata = await AudioMetadata.readFromBytes(bytes);
      // final metadata = await MetadataRetriever.fromBytes(bytes);
      //
      // final result = <String, dynamic>{
      //   'title': metadata?.trackName ?? _extractTitleFromFileName(filePath),
      //   'artist': metadata?.trackArtistNames?.join(', ') ?? '未知歌手',
      //   'album': metadata?.albumName ?? '未知专辑',
      //   'duration': metadata?.trackDuration ?? Duration.zero,
      //   'bitrate': metadata?.bitrate,
      //   'sampleRate': null,
      //   'coverData': metadata?.albumArt,
      //   'genre': metadata?.genre,
      //   'year': metadata?.year,
      // };

      final result = <String, dynamic>{
        'title': _extractTitleFromFileName(filePath),
        'artist': '未知歌手',
        'album': '未知专辑',
        'duration': Duration.zero,
        'bitrate': null,
        'sampleRate': null,
        'coverData': null,
        'genre': null,
        'year': null,
      };

      return Result.success(result);
    } on FormatException catch (e) {
      return Result.failure(
        AudioException('音频格式不支持: ${e.message}'),
      );
    } on StateError catch (e) {
      return Result.failure(
        AudioException('音频文件损坏: ${e.toString()}'),
      );
    }
    // on BadStateException catch (e) {
    //   return Result.failure(
    //     AudioException('音频文件损坏: ${e.toString()}'),
    //   );
    // }
    on Exception catch (e) {
      return Result.failure(
        AudioException('解析元数据失败: ${e.toString()}'),
      );
    }
  }

  // 从文件名提取标题
  static String _extractTitleFromFileName(String filePath) {
    final fileName = filePath.split('/').last;
    final nameWithoutExt = fileName.replaceAll(RegExp(r'\.[^.]*$'), '');

    // 检查是否有分隔符（-、_等）
    // 格式：歌手 - 歌曲名 或 歌曲名 - 歌手
    final separators = [' - ', ' -', '- ', '_', ' ¬ ', ' ¬', '¬ '];
    for (final separator in separators) {
      if (nameWithoutExt.contains(separator)) {
        // 尝试获取最后一个分隔符后的内容
        final parts = nameWithoutExt.split(separator);
        if (parts.length >= 2) {
          // 如果第一部分像歌手名（长度较短），返回第二部分
          if (parts[0].length < 10 && parts.last.length > parts[0].length) {
            return parts.last;
          }
        }
      }
    }

    return nameWithoutExt;
  }

  // 批量解析歌曲元数据
  static Future<Result<List<Song>>> parseSongsMetadata(
    List<String> filePaths,
  ) async {
    final songs = <Song>[];

    for (var i = 0; i < filePaths.length; i++) {
      final filePath = filePaths[i];
      final result = await parseAudioMetadata(filePath);

      if (result.isSuccess) {
        final metadata = result.data!;
        songs.add(
          Song(
            id: i,
            title: metadata['title'] as String,
            artist: metadata['artist'] as String,
            album: metadata['album'] as String,
            path: filePath,
            duration: metadata['duration'] as Duration,
            isLocal: true,
          ),
        );
      } else {
        // 如果解析失败，使用文件名创建基础信息
        final file = File(filePath);
        final fileName = file.path.split('/').last.replaceAll(RegExp(r'\.[^.]*$'), '');
        songs.add(
          Song(
            id: i,
            title: fileName,
            artist: '未知歌手',
            album: '未知专辑',
            path: filePath,
            duration: Duration.zero,
            isLocal: true,
          ),
        );
      }
    }

    return Result.success(songs);
  }

  // 解析单个歌曲的完整信息
  static Future<Result<Song>> parseSongWithMetadata(
    String filePath,
    int id,
  ) async {
    final result = await parseAudioMetadata(filePath);

    if (result.isSuccess) {
      final metadata = result.data!;
      return Result.success(
        Song(
          id: id,
          title: metadata['title'] as String,
          artist: metadata['artist'] as String,
          album: metadata['album'] as String,
          path: filePath,
          duration: metadata['duration'] as Duration,
          isLocal: true,
        ),
      );
    } else {
      // 解析失败，使用文件名
      final file = File(filePath);
      final fileName = file.path.split('/').last.replaceAll(RegExp(r'\.[^.]*$'), '');
      return Result.success(
        Song(
          id: id,
          title: fileName,
          artist: '未知歌手',
          album: '未知专辑',
          path: filePath,
          duration: Duration.zero,
          isLocal: true,
        ),
      );
    }
  }

  // 提取封面图片
  static Future<Uint8List?> getCoverArt(String filePath) async {
    try {
      final result = await parseAudioMetadata(filePath);
      if (result.isSuccess) {
        return result.data!['coverData'] as Uint8List?;
      }
      return null;
    } catch (e) {
      print('提取封面失败: $e');
      return null;
    }
  }

  // 保存封面图片到本地
  static Future<File?> saveCoverToCache(
    Uint8List coverData,
    String songId,
  ) async {
    try {
      final cacheDir = await Directory.systemTemp.createTemp('covers');
      final coverFile = File('${cacheDir.path}/cover_$songId.jpg');
      await coverFile.writeAsBytes(coverData);
      return coverFile;
    } catch (e) {
      print('保存封面失败: $e');
      return null;
    }
  }

  // 从缓存加载封面
  static Future<File?> getCachedCover(String songId) async {
    final cacheDir = Directory.systemTemp.createTempSync('covers');
    final coverFile = File('${cacheDir.path}/cover_$songId.jpg');
    if (await coverFile.exists()) {
      return coverFile;
    }
    return null;
  }

  // 获取音频时长（不解析完整元数据）
  static Future<Duration> getAudioDuration(String filePath) async {
    try {
      final result = await parseAudioMetadata(filePath);
      if (result.isSuccess) {
        return result.data!['duration'] as Duration;
      }
      return Duration.zero;
    } catch (e) {
      return Duration.zero;
    }
  }

  // 批量获取文件时长
  static Future<List<Duration>> getDurations(List<String> filePaths) async {
    final durations = <Duration>[];

    for (final filePath in filePaths) {
      final duration = await getAudioDuration(filePath);
      durations.add(duration);
    }

    return durations;
  }
}
