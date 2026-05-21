import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/song.dart';
import '../utils/exceptions.dart';
import '../utils/error_handler.dart';

// 文件扫描器
// 用于扫描设备中的音频文件
class FileScanner {
  // 支持的音频文件扩展名
  static const List<String> audioExtensions = [
    '.mp3',
    '.flac',
    '.wav',
    '.aac',
    '.m4a',
    '.ogg',
    '.wma',
    '.ape',
    '.mp2',
    '.m4b',
    '.m4p',
    '.m4r',
  ];

  // 扫描音乐文件
  // 返回Result类型，包含扫描结果或异常
  Future<Result<List<File>>> scanMusicFiles() async {
    try {
      // 检查并请求权限
      final hasPermission = await _ensureStoragePermission();
      if (!hasPermission) {
        return Result.failure(
          PermissionException('需要存储权限才能扫描音乐文件'),
        );
      }

      final List<File> musicFiles = [];

      // Android 10+ 需要使用特定的目录
      // iOS 需要通过 file_picker 获取
      try {
        // 获取外部存储目录
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          // 扫描常见音乐目录
          final musicDirs = [
            Directory('${externalDir.parent.parent.path}/Music'),
            Directory('${externalDir.parent.parent.path}/Download/Music'),
            Directory('${externalDir.parent.parent.path}/Documents'),
            Directory('${externalDir.parent.parent.path}/Downloads'),
          ];

          for (final dir in musicDirs) {
            if (await dir.exists()) {
              await _scanDirectory(dir, musicFiles);
            }
          }
        }

        // 也扫描应用文档目录
        final docDir = await getApplicationDocumentsDirectory();
        await _scanDirectory(docDir, musicFiles);

        // 去重
        final uniqueFiles = <File>{};
        musicFiles.retainWhere((file) => uniqueFiles.add(file));

        return Result.success(uniqueFiles.toList());
      } catch (e, stackTrace) {
        print('扫描文件时发生错误: $e\n$stackTrace');
        return Result.failure(
          FileScanException('扫描文件时发生错误: ${e.toString()}'),
        );
      }
    } catch (e) {
      print('文件扫描器初始化错误: $e');
      return Result.failure(
        FileScanException('文件扫描器初始化错误: ${e.toString()}'),
      );
    }
  }

  // 递归扫描目录
  Future<void> _scanDirectory(Directory dir, List<File> result) async {
    try {
      await for (final entity in dir.list(recursive: false)) {
        if (entity is File) {
          // 检查是否是音频文件
          if (_isAudioFile(entity.path)) {
            // 检查文件大小是否合理 (>10KB, <200MB)
            final length = await entity.length();
            if (length > 10240 && length < 200 * 1024 * 1024) {
              result.add(entity);
            }
          }
        } else if (entity is Directory) {
          // 递归扫描子目录，但限制深度
          // 这里不限制深度，但实际使用中可以考虑限制
          await _scanDirectory(entity, result);
        }
      }
    } catch (e) {
      // 目录可能无法访问，跳过
      print('扫描目录 ${dir.path} 时发生错误: $e');
    }
  }

  // 判断是否是音频文件
  bool _isAudioFile(String path) {
    final lowerPath = path.toLowerCase();
    return audioExtensions.any((ext) => lowerPath.endsWith(ext));
  }

  // 确保有存储权限
  Future<bool> _ensureStoragePermission() async {
    // Android 13+
    if (Platform.isAndroid) {
      // 尝试请求 Android 13+ 的 READ_MEDIA_AUDIO 权限
      var status = await Permission.audio.request();
      if (!status.isGranted) {
        // fallback 到 READ_EXTERNAL_STORAGE
        status = await Permission.storage.request();
        if (!status.isGranted && status != PermissionStatus.denied) {
          // 权限被永久拒绝，需要引导用户到设置页面
          return false;
        }
      }
      return status.isGranted;
    }
    // iOS
    else if (Platform.isIOS) {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        status = await Permission.photos.request();
      }
      return status.isGranted;
    }
    // 其他平台
    return true;
  }

  // 检查是否有扫描权限
  Future<bool> hasScanPermission() async {
    if (Platform.isAndroid) {
      final audioStatus = await Permission.audio.status;
      final storageStatus = await Permission.storage.status;
      return audioStatus.isGranted || storageStatus.isGranted;
    } else if (Platform.isIOS) {
      final storageStatus = await Permission.storage.status;
      final photosStatus = await Permission.photos.status;
      return storageStatus.isGranted || photosStatus.isGranted;
    }
    return true;
  }

  // 请求权限
  Future<bool> requestPermission(BuildContext? context) async {
    final result = await _ensureStoragePermission();
    if (!result && context != null) {
      // 显示权限引导
      ErrorHandler.showConfirmDialog(
        context,
        title: '需要存储权限',
        content: '为了扫描和播放音乐文件，应用需要访问存储权限',
        confirmText: '去设置',
        cancelText: '取消',
      ).then((value) {
        if (value == true) {
          // 引导用户去设置
          openAppSettings();
        }
      });
    }
    return result;
  }

  // 根据文件获取歌曲信息（简化版）
  Song getSongFromFile(File file, int id) {
    final fileName = file.path.split('/').last;
    final nameWithoutExt = fileName.replaceAll(RegExp(r'\.[^.]*$'), '');

    // 尝试从文件名解析艺术家和标题
    // 格式：歌手 - 歌曲名.mp3
    final parts = nameWithoutExt.split(' - ');
    String artist = '未知歌手';
    String title = nameWithoutExt;

    if (parts.length >= 2) {
      artist = parts[0].trim();
      title = parts.sublist(1).join(' - ').trim();
    }

    // 从文件名解析专辑
    String album = '未知专辑';
    if (parts.length >= 3) {
      // 如果有专辑信息：歌手 - 专辑 - 歌曲名
      album = parts[1].trim();
      title = parts.sublist(2).join(' - ').trim();
    }

    return Song(
      id: id,
      title: title,
      artist: artist,
      album: album,
      path: file.path,
      duration: Duration.zero, // 时长需要通过媒体元数据获取
      isLocal: true,
    );
  }

  // 扫描并返回 Song 列表
  Future<Result<List<Song>>> scanAndGetSongs() async {
    final scanResult = await scanMusicFiles();
    if (!scanResult.isSuccess) {
      return Result.failure(scanResult.exception!);
    }

    final files = scanResult.data!;
    final songs = <Song>[];

    for (int i = 0; i < files.length; i++) {
      songs.add(getSongFromFile(files[i], i));
    }

    return Result.success(songs);
  }

  // 按目录分组扫描
  Future<Result<Map<String, List<File>>>> scanByDirectory() async {
    try {
      final hasPermission = await _ensureStoragePermission();
      if (!hasPermission) {
        return Result.failure(
          PermissionException('需要存储权限'),
        );
      }

      final result = <String, List<File>>{};

      // 扫描Music目录
      try {
        if (Platform.isAndroid) {
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            final musicDir = Directory('${externalDir.parent.parent.path}/Music');
            if (await musicDir.exists()) {
              await _scanDirectoryByGroup(musicDir, result);
            }
          }
        }
      } catch (e) {
        print('扫描Music目录错误: $e');
      }

      return Result.success(result);
    } catch (e) {
      return Result.failure(
        FileScanException('按目录分组扫描失败: ${e.toString()}'),
      );
    }
  }

  // 按目录分组扫描
  Future<void> _scanDirectoryByGroup(Directory dir, Map<String, List<File>> result) async {
    try {
      await for (final entity in dir.list(recursive: false)) {
        if (entity is File && _isAudioFile(entity.path)) {
          final dirName = dir.path.split('/').last;
          result.putIfAbsent(dirName, () => []).add(entity);
        } else if (entity is Directory) {
          await _scanDirectoryByGroup(entity, result);
        }
      }
    } catch (e) {
      print('分组扫描错误: $e');
    }
  }

  // 获取指定目录下的音乐文件
  Future<Result<List<File>>> scanDirectory(String path) async {
    try {
      final dir = Directory(path);
      if (!await dir.exists()) {
        return Result.failure(
          FileScanException('目录不存在: $path'),
        );
      }

      final files = <File>[];
      await _scanDirectory(dir, files);
      return Result.success(files);
    } catch (e) {
      return Result.failure(
        FileScanException('扫描目录失败: ${e.toString()}'),
      );
    }
  }
}
