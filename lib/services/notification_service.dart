import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/song.dart';
import '../utils/exceptions.dart';

// 通知服务
// 管理媒体通知栏控制和系统通知
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _stateSubscription;

  factory NotificationService() => _instance;

  NotificationService._internal();

  // 初始化通知
  Future<Result<bool>> initialize() async {
    try {
      if (_initialized) return Result.success(true);

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _plugin.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      _initialized = true;
      return Result.success(true);
    } catch (e) {
      return Result.failure(
        DatabaseException('通知初始化失败: $e'),
      );
    }
  }

  // 通知点击处理
  void _onNotificationTap(NotificationResponse response) {
    // 点击通知打开应用
  }

  // 显示/更新媒体通知
  // Future<void> showMediaNotification({
  //   required Song song,
  //   required bool isPlaying,
  //   required AudioPlayer audioPlayer,
  //   VoidCallback? onPlayPause,
  //   VoidCallback? onNext,
  //   VoidCallback? onPrevious,
  // }) async {
  //   try {
  //     final androidDetails = AndroidNotificationDetails(
  //       'music_channel',
  //       '音乐播放',
  //       channelDescription: '音乐播放控制通知',
  //       importance: Importance.low,
  //       priority: Priority.low,
  //       icon: '@mipmap/ic_launcher',
  //       largeIcon: song.coverPath != null
  //           ? FilePathAndroidBitmap(song.coverPath!)
  //           : null,
  //       playbackState: isPlaying
  //           ? AndroidPlaybackState.play
  //           : AndroidPlaybackState.pause,
  //       mediaSession: true,
  //       ongoing: true,
  //       autoCancel: false,
  //       actions: [
  //         AndroidNotificationAction(
  //           'previous',
  //           '上一曲',
  //           icon: AndroidNotificationActionIcon.SystemIcon('skip_previous'),
  //           showsUserInterface: false,
  //         ),
  //         AndroidNotificationAction(
  //           isPlaying ? 'pause' : 'play',
  //           isPlaying ? '暂停' : '播放',
  //           icon: AndroidNotificationActionIcon.SystemIcon(
  //             isPlaying ? 'pause' : 'play_arrow',
  //           ),
  //           showsUserInterface: false,
  //         ),
  //         AndroidNotificationAction(
  //           'next',
  //           '下一曲',
  //           icon: AndroidNotificationActionIcon.SystemIcon('skip_next'),
  //           showsUserInterface: false,
  //         ),
  //       ],
  //     );
  Future<void> showMediaNotification({
    required Song song,
    required bool isPlaying,
    required AudioPlayer audioPlayer,
    VoidCallback? onPlayPause,
    VoidCallback? onNext,
    VoidCallback? onPrevious,
  }) async {
    try {
    final androidDetails = AndroidNotificationDetails(
      'music_channel',
      '音乐播放',
      channelDescription: '音乐播放控制通知',
      importance: Importance.low,
      priority: Priority.low,
      icon: '@mipmap/ic_launcher',
      largeIcon: song.coverPath != null
          ? FilePathAndroidBitmap(song.coverPath!)
          : null,
      ongoing: true,
      autoCancel: false,
      actions: [
        AndroidNotificationAction(
          'previous',
          '上一曲',
          // icon: AndroidNotificationActionIcon.SystemIcon(
          //   'skip_previous',
          // ),
          showsUserInterface: false,
        ),
        AndroidNotificationAction(
          isPlaying ? 'pause' : 'play',
          isPlaying ? '暂停' : '播放',
          // icon: AndroidNotificationActionIcon.SystemIcon(
          //   isPlaying ? 'pause' : 'play_arrow',
          // ),
          showsUserInterface: false,
        ),
        AndroidNotificationAction(
          'next',
          '下一曲',
          // icon: AndroidNotificationActionIcon.SystemIcon(
          //   'skip_next',
          // ),
          showsUserInterface: false,
        ),
      ],
    );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: false,
        presentSound: false,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin.show(
        1001,
        song.title,
        song.artist != '未知歌手' ? song.artist : '我的音乐',
        details,
        payload: 'music_player',
      );

      // 监听播放位置更新通知
      _positionSubscription?.cancel();
      _positionSubscription = audioPlayer.positionStream.listen((position) {
        _updateNotificationProgress(song, position, audioPlayer.duration ?? Duration.zero);
      });

      // 监听播放状态更新通知
      _stateSubscription?.cancel();
      _stateSubscription = audioPlayer.playerStateStream.listen((state) {
        if (!state.playing && mounted) {
          _cancelOngoingNotification();
        }
      });
    } catch (e) {
      print('显示媒体通知失败: $e');
    }
  }

  bool get mounted => true;

  // 更新通知进度
  Future<void> _updateNotificationProgress(
    Song song,
    Duration position,
    Duration duration,
  ) async {
    try {
      // Android自动处理进度更新
    } catch (e) {
      print('更新通知进度失败: $e');
    }
  }

  // 取消持续通知
  Future<void> _cancelOngoingNotification() async {
    await _plugin.cancel(1001);
  }

  // 取消所有通知
  Future<void> cancelAll() async {
    _positionSubscription?.cancel();
    _stateSubscription?.cancel();
    await _plugin.cancelAll();
  }

  // 显示下载完成通知
  Future<void> showDownloadComplete(String fileName) async {
    const androidDetails = AndroidNotificationDetails(
      'download_channel',
      '下载完成',
      channelDescription: '文件下载完成通知',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '下载完成',
      fileName,
      details,
    );
  }

  // 显示错误通知
  Future<void> showError(String message) async {
    const androidDetails = AndroidNotificationDetails(
      'error_channel',
      '错误提醒',
      channelDescription: '应用错误通知',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '错误',
      message,
      details,
    );
  }

  // 释放资源
  Future<void> dispose() async {
    _positionSubscription?.cancel();
    _stateSubscription?.cancel();
    await cancelAll();
  }
}