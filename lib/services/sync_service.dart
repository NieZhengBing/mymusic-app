import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/app_user.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import '../user/database/db_helper.dart';
import '../utils/exceptions.dart';
import '../providers/auth_provider.dart';

// 云同步服务
// 管理Firestore云端数据同步
class SyncService {
  static final SyncService _instance = SyncService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;
  bool _isOnline = true;

  factory SyncService() => _instance;

  SyncService._internal();

  // 初始化连接监听
  void initConnectivityListener() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((results) async {
        final result = await Connectivity().checkConnectivity();
        _isOnline = result != ConnectivityResult.none;
      if (_isOnline) {
        syncAll();
      }
    });
  }

  // 检查网络连接
  Future<bool> checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // 同步所有数据
  Future<Result<bool>> syncAll({String? userId}) async {
    if (_isSyncing) return Result.success(true);
    if (!_isOnline) {
      return Result.failure(
        NetworkException('网络未连接，无法同步'),
      );
    }

    _isSyncing = true;

    try {
      // 同步待处理数据
      await _syncPendingRecords(userId);

      // 从云端拉取数据
      await _pullFavoritesFromCloud(userId);
      await _pullPlaylistsFromCloud(userId);

      _isSyncing = false;
      return Result.success(true);
    } catch (e) {
      _isSyncing = false;
      return Result.failure(
        NetworkException('同步失败: $e'),
      );
    }
  }

  // 同步待处理记录
  Future<void> _syncPendingRecords(String? userId) async {
    final pendingResult = await _dbHelper.getPendingSyncs();
    if (!pendingResult.isSuccess || pendingResult.data == null) return;

    final pendingRecords = pendingResult.data!;
    for (final record in pendingRecords) {
      try {
        final tableName = record['table_name'] as String;
        final recordId = record['record_id'] as int;
        final action = record['action'] as String;
        final id = record['id'] as int;

        // 根据表和操作执行云端同步
        final docRef = _firestore
            .collection('users')
            .doc(userId ?? 'anonymous')
            .collection(tableName)
            .doc(recordId.toString());

        switch (action) {
          case 'create':
          case 'update':
            await docRef.set(record);
            break;
          case 'delete':
            await docRef.delete();
            break;
        }

        await _dbHelper.markSyncCompleted(id);
      } catch (e) {
        await _dbHelper.markSyncFailed(record['id'] as int);
      }
    }
  }

  // 从云端拉取收藏数据
  Future<void> _pullFavoritesFromCloud(String? userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId ?? 'anonymous')
          .collection('favorites')
          .get();

      if (snapshot.docs.isNotEmpty) {
        final favorites = snapshot.docs
            .map((doc) => doc.data())
            .toList();
        await _dbHelper.addFavoritesBatch(favorites);
      }
    } catch (e) {
      // 静默处理拉取错误
    }
  }

  // 从云端拉取歌单数据
  Future<void> _pullPlaylistsFromCloud(String? userId) async {
    // 歌单同步在PlaylistStorage中处理
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId ?? 'anonymous')
          .collection('playlists')
          .get();

      // 简化实现: 只做记录，具体由各服务处理
    } catch (e) {
      // 静默处理
    }
  }

  // 上传收藏到云端
  Future<Result<bool>> uploadFavorite(Map<String, dynamic> favorite, {
    String? userId,
  }) async {
    try {
      if (!_isOnline) {
        return Result.failure(
          NetworkException('网络未连接'),
        );
      }

      await _firestore
          .collection('users')
          .doc(userId ?? 'anonymous')
          .collection('favorites')
          .doc(favorite['song_id'].toString())
          .set(favorite);

      return Result.success(true);
    } catch (e) {
      return Result.failure(
        NetworkException('上传收藏失败: $e'),
      );
    }
  }

  // 删除云端收藏
  Future<Result<bool>> removeCloudFavorite(int songId, {
    String? userId,
  }) async {
    try {
      if (!_isOnline) {
        return Result.success(false);
      }

      await _firestore
          .collection('users')
          .doc(userId ?? 'anonymous')
          .collection('favorites')
          .doc(songId.toString())
          .delete();

      return Result.success(true);
    } catch (e) {
      return Result.failure(
        NetworkException('删除云端收藏失败: $e'),
      );
    }
  }

  // 上传歌单到云端
  Future<Result<bool>> uploadPlaylist(Playlist playlist, {
    String? userId,
  }) async {
    try {
      if (!_isOnline) {
        return Result.failure(
          NetworkException('网络未连接'),
        );
      }

      await _firestore
          .collection('users')
          .doc(userId ?? 'anonymous')
          .collection('playlists')
          .doc(playlist.id.toString())
          .set(playlist.toJson());

      return Result.success(true);
    } catch (e) {
      return Result.failure(
        NetworkException('上传歌单失败: $e'),
      );
    }
  }

  // 上传播放历史到云端
  Future<Result<bool>> uploadPlayHistory(Map<String, dynamic> history, {
    String? userId,
  }) async {
    try {
      if (!_isOnline) {
        return Result.failure(
          NetworkException('网络未连接'),
        );
      }

      final docId = '${history['song_id']}_${DateTime.now().millisecondsSinceEpoch}';
      await _firestore
          .collection('users')
          .doc(userId ?? 'anonymous')
          .collection('play_history')
          .doc(docId)
          .set(history);

      return Result.success(true);
    } catch (e) {
      return Result.failure(
        NetworkException('上传播放历史失败: $e'),
      );
    }
  }

  // 获取同步状态
  bool get isSyncing => _isSyncing;
  bool get isOnline => _isOnline;

  // 清理
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}

// 同步包装器Widget
// class SyncProvider extends StatelessWidget {
//   final Widget child;
//
//   const SyncProvider({super.key, required this.child});
//
//   @override
//   Widget build(BuildContext context) {
//     return widget.child;
//   }
// }

class SyncProvider extends StatefulWidget {
  final Widget child;

  const SyncProvider({super.key, required this.child});

  @override
  State<SyncProvider> createState() => _SyncProviderState();
}

class _SyncProviderState extends State<SyncProvider> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}