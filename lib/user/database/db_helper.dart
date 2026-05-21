import 'dart:io';

// import 'package:sqflite/sqflite.dart'  hide DatabaseException;
// import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:sqflite/sqflite.dart'
    hide DatabaseException;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';

import '../../utils/exceptions.dart';

// 数据库帮助类
// 管理收藏、播放历史、用户信息和同步状态
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static const String _dbName = 'music_player.db';
  static const int _dbVersion = 2;

  // 表名
  static const String tableFavorites = 'favorites';
  static const String tablePlayHistory = 'play_history';
  static const String tableUsers = 'users';
  static const String tableSyncStatus = 'sync_status';

  // 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // 初始化数据库
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  // 配置数据库
  Future<void> _onConfigure(Database db) async {
    // 启用外键约束
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // 创建表
  Future<void> _onCreate(Database db, int version) async {
    // 收藏表
    await db.execute('''
      CREATE TABLE $tableFavorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        song_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        artist TEXT DEFAULT '未知歌手',
        album TEXT DEFAULT '未知专辑',
        path TEXT NOT NULL,
        duration INTEGER DEFAULT 0,
        cover_path TEXT,
        is_local INTEGER DEFAULT 1,
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
      )
    ''');

    // 播放历史表
    await db.execute('''
      CREATE TABLE $tablePlayHistory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        song_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        artist TEXT DEFAULT '未知歌手',
        album TEXT DEFAULT '未知专辑',
        path TEXT NOT NULL,
        duration INTEGER DEFAULT 0,
        cover_path TEXT,
        is_local INTEGER DEFAULT 1,
        position INTEGER DEFAULT 0,
        completed INTEGER DEFAULT 0,
        played_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
      )
    ''');

    // 用户表
    await db.execute('''
      CREATE TABLE $tableUsers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT UNIQUE NOT NULL,
        email TEXT,
        display_name TEXT,
        avatar_url TEXT,
        is_current INTEGER DEFAULT 0,
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
      )
    ''');

    // 同步状态表
    await db.execute('''
      CREATE TABLE $tableSyncStatus (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id INTEGER NOT NULL,
        action TEXT NOT NULL CHECK(action IN ('create', 'update', 'delete')),
        status TEXT NOT NULL DEFAULT 'pending' CHECK(status IN ('pending', 'synced', 'failed')),
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        synced_at TEXT
      )
    ''');

    // 索引
    await db.execute(
        'CREATE INDEX idx_favorites_song_id ON $tableFavorites(song_id)');
    await db.execute(
        'CREATE INDEX idx_play_history_song_id ON $tablePlayHistory(song_id)');
    await db.execute(
        'CREATE INDEX idx_play_history_played_at ON $tablePlayHistory(played_at)');
    await db.execute(
        'CREATE INDEX idx_sync_status_status ON $tableSyncStatus(status)');
    await db.execute(
        'CREATE UNIQUE INDEX idx_sync_status_record ON $tableSyncStatus(table_name, record_id, action)');
  }

  // 数据库升级
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 升级到版本2：添加用户和同步状态表
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableUsers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT UNIQUE NOT NULL,
          email TEXT,
          display_name TEXT,
          avatar_url TEXT,
          is_current INTEGER DEFAULT 0,
          created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
          updated_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableSyncStatus (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          table_name TEXT NOT NULL,
          record_id INTEGER NOT NULL,
          action TEXT NOT NULL CHECK(action IN ('create', 'update', 'delete')),
          status TEXT NOT NULL DEFAULT 'pending' CHECK(status IN ('pending', 'synced', 'failed')),
          created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
          synced_at TEXT
        )
      ''');

      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_sync_status_status ON $tableSyncStatus(status)');
      await db.execute(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_sync_status_record ON $tableSyncStatus(table_name, record_id, action)');
    }
  }

  // ==================== 收藏功能 ====================

  // 添加收藏
  Future<Result<int>> addFavorite({
    required int songId,
    required String title,
    required String path,
    String artist = '未知歌手',
    String album = '未知专辑',
    int duration = 0,
    String? coverPath,
    bool isLocal = true,
  }) async {
    try {
      final db = await database;
      final id = await db.insert(tableFavorites, {
        'song_id': songId,
        'title': title,
        'artist': artist,
        'album': album,
        'path': path,
        'duration': duration,
        'cover_path': coverPath,
        'is_local': isLocal ? 1 : 0,
      });
      return Result.success(id);
    } catch (e) {
      return Result.failure(
        DatabaseException('添加收藏失败: $e'),
      );
    }
  }

  // 取消收藏
  Future<Result<int>> removeFavorite(int songId) async {
    try {
      final db = await database;
      final count = await db.delete(
        tableFavorites,
        where: 'song_id = ?',
        whereArgs: [songId],
      );
      return Result.success(count);
    } catch (e) {
      return Result.failure(
        DatabaseException('取消收藏失败: $e'),
      );
    }
  }

  // 检查是否已收藏
  Future<Result<bool>> isFavorite(int songId) async {
    try {
      final db = await database;
      final result = await db.query(
        tableFavorites,
        where: 'song_id = ?',
        whereArgs: [songId],
        limit: 1,
      );
      return Result.success(result.isNotEmpty);
    } catch (e) {
      return Result.failure(
        DatabaseException('查询收藏状态失败: $e'),
      );
    }
  }

  // 获取所有收藏
  Future<Result<List<Map<String, dynamic>>>> getAllFavorites() async {
    try {
      final db = await database;
      final result = await db.query(
        tableFavorites,
        orderBy: 'created_at DESC',
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(
        DatabaseException('获取收藏列表失败: $e'),
      );
    }
  }

  // 批量添加收藏（用于同步）
  Future<Result<int>> addFavoritesBatch(
    List<Map<String, dynamic>> favorites,
  ) async {
    try {
      final db = await database;
      final batch = db.batch();
      for (final fav in favorites) {
        batch.insert(tableFavorites, fav);
      }
      final results = await batch.commit(noResult: true);
      return Result.success(results.length);
    } catch (e) {
      return Result.failure(
        DatabaseException('批量添加收藏失败: $e'),
      );
    }
  }

  // 清空收藏
  Future<Result<int>> clearFavorites() async {
    try {
      final db = await database;
      final count = await db.delete(tableFavorites);
      return Result.success(count);
    } catch (e) {
      return Result.failure(
        DatabaseException('清空收藏失败: $e'),
      );
    }
  }

  // 获取收藏数量
  Future<Result<int>> getFavoriteCount() async {
    try {
      final db = await database;
      final result =
          await db.rawQuery('SELECT COUNT(*) as count FROM $tableFavorites');
//       return Result.success(sqflite.Sqflite.firstIntValue(result) ?? 0);
      return Result.success(Sqflite.firstIntValue(result) ?? 0);
    } catch (e) {
      return Result.failure(
        DatabaseException('获取收藏数量失败: $e'),
      );
    }
  }

  // ==================== 播放历史功能 ====================

  // 添加播放历史
  Future<Result<int>> addPlayHistory({
    required int songId,
    required String title,
    required String path,
    String artist = '未知歌手',
    String album = '未知专辑',
    int duration = 0,
    String? coverPath,
    bool isLocal = true,
  }) async {
    try {
      final db = await database;

      // 检查是否已有相同歌曲的记录
      final existing = await db.query(
        tablePlayHistory,
        where: 'song_id = ?',
        whereArgs: [songId],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        // 更新已有记录的播放时间
        await db.update(
          tablePlayHistory,
          {
            'played_at':
                DateTime.now().toIso8601String(),
            'position': 0,
            'completed': 0,
          },
          where: 'song_id = ?',
          whereArgs: [songId],
        );
        return Result.success(existing.first['id'] as int);
      }

      final id = await db.insert(tablePlayHistory, {
        'song_id': songId,
        'title': title,
        'artist': artist,
        'album': album,
        'path': path,
        'duration': duration,
        'cover_path': coverPath,
        'is_local': isLocal ? 1 : 0,
        'position': 0,
        'completed': 0,
      });
      return Result.success(id);
    } catch (e) {
      return Result.failure(
        DatabaseException('添加播放历史失败: $e'),
      );
    }
  }

  // 更新播放位置
  Future<Result<int>> updatePlayPosition(int songId, int position) async {
    try {
      final db = await database;
      final count = await db.update(
        tablePlayHistory,
        {'position': position},
        where: 'song_id = ?',
        whereArgs: [songId],
      );
      return Result.success(count);
    } catch (e) {
      return Result.failure(
        DatabaseException('更新播放位置失败: $e'),
      );
    }
  }

  // 设置播放完成
  Future<Result<int>> setPlayCompleted(int songId) async {
    try {
      final db = await database;
      final count = await db.update(
        tablePlayHistory,
        {'completed': 1},
        where: 'song_id = ?',
        whereArgs: [songId],
      );
      return Result.success(count);
    } catch (e) {
      return Result.failure(
        DatabaseException('设置播放完成失败: $e'),
      );
    }
  }

  // 获取最近的播放记录
  Future<Result<List<Map<String, dynamic>>>> getRecentPlays({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final db = await database;
      final result = await db.query(
        tablePlayHistory,
        orderBy: 'played_at DESC',
        limit: limit,
        offset: offset,
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(
        DatabaseException('获取播放历史失败: $e'),
      );
    }
  }

  // 获取指定歌曲的播放历史
  Future<Result<List<Map<String, dynamic>>>> getSongPlayHistory(
    int songId, {
    int limit = 20,
  }) async {
    try {
      final db = await database;
      final result = await db.query(
        tablePlayHistory,
        where: 'song_id = ?',
        whereArgs: [songId],
        orderBy: 'played_at DESC',
        limit: limit,
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(
        DatabaseException('获取歌曲播放历史失败: $e'),
      );
    }
  }

  // 获取播放次数统计
  Future<Result<int>> getPlayCounts(int songId) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tablePlayHistory WHERE song_id = ?',
        [songId],
      );
//       return Result.success(sqflite.Sqflite.firstIntValue(result) ?? 0);
      return Result.success(Sqflite.firstIntValue(result) ?? 0);
    } catch (e) {
      return Result.failure(
        DatabaseException('获取播放次数失败: $e'),
      );
    }
  }

  // 删除指定播放历史
  Future<Result<int>> deletePlayHistory(int songId) async {
    try {
      final db = await database;
      final count = await db.delete(
        tablePlayHistory,
        where: 'song_id = ?',
        whereArgs: [songId],
      );
      return Result.success(count);
    } catch (e) {
      return Result.failure(
        DatabaseException('删除播放历史失败: $e'),
      );
    }
  }

  // 清空播放历史
  Future<Result<int>> clearPlayHistory() async {
    try {
      final db = await database;
      final count = await db.delete(tablePlayHistory);
      return Result.success(count);
    } catch (e) {
      return Result.failure(
        DatabaseException('清空播放历史失败: $e'),
      );
    }
  }

  // 删除旧的历史记录（保留最近N条）
  Future<Result<int>> deleteOldHistory({int keep = 200}) async {
    try {
      final db = await database;
      final count = await db.rawDelete('''
        DELETE FROM $tablePlayHistory
        WHERE id NOT IN (
          SELECT id FROM $tablePlayHistory
          ORDER BY played_at DESC
          LIMIT ?
        )
      ''', [keep]);
      return Result.success(count);
    } catch (e) {
      return Result.failure(
        DatabaseException('删除旧历史失败: $e'),
      );
    }
  }

  // ==================== 用户功能 ====================

  // 插入或更新用户
  Future<Result<int>> upsertUser({
    required String userId,
    String? email,
    String? displayName,
    String? avatarUrl,
    bool isCurrent = false,
  }) async {
    try {
      final db = await database;

      // 如果设置为当前用户，先清除其他用户的当前状态
      if (isCurrent) {
        await db.update(
          tableUsers,
          {'is_current': 0},
          where: 'is_current = 1',
        );
      }

      // 检查用户是否已存在
      final existing = await db.query(
        tableUsers,
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        await db.update(
          tableUsers,
          {
            'email': email,
            'display_name': displayName,
            'avatar_url': avatarUrl,
            'is_current': isCurrent ? 1 : 0,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'user_id = ?',
          whereArgs: [userId],
        );
        return Result.success(existing.first['id'] as int);
      }

      final id = await db.insert(tableUsers, {
        'user_id': userId,
        'email': email,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'is_current': isCurrent ? 1 : 0,
      });
      return Result.success(id);
    } catch (e) {
      return Result.failure(
        DatabaseException('保存用户信息失败: $e'),
      );
    }
  }

  // 获取用户信息
  Future<Result<Map<String, dynamic>?>> getUser(String userId) async {
    try {
      final db = await database;
      final result = await db.query(
        tableUsers,
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );
      return Result.success(result.isNotEmpty ? result.first : null);
    } catch (e) {
      return Result.failure(
        DatabaseException('获取用户信息失败: $e'),
      );
    }
  }

  // 获取当前用户
  Future<Result<Map<String, dynamic>?>> getCurrentUser() async {
    try {
      final db = await database;
      final result = await db.query(
        tableUsers,
        where: 'is_current = 1',
        limit: 1,
      );
      return Result.success(result.isNotEmpty ? result.first : null);
    } catch (e) {
      return Result.failure(
        DatabaseException('获取当前用户失败: $e'),
      );
    }
  }

  // 删除用户
  Future<Result<int>> deleteUser(String userId) async {
    try {
      final db = await database;
      final count = await db.delete(
        tableUsers,
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      return Result.success(count);
    } catch (e) {
      return Result.failure(
        DatabaseException('删除用户失败: $e'),
      );
    }
  }

  // ==================== 同步状态功能 ====================

  // 更新同步状态
  Future<Result<int>> updateSyncStatus({
    required String tableName,
    required int recordId,
    required String action,
    String status = 'pending',
  }) async {
    try {
      final db = await database;
      final id = await db.insert(
        tableSyncStatus,
        {
          'table_name': tableName,
          'record_id': recordId,
          'action': action,
          'status': status,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return Result.success(id);
    } catch (e) {
      return Result.failure(
        DatabaseException('更新同步状态失败: $e'),
      );
    }
  }

  // 获取同步状态
  Future<Result<Map<String, dynamic>?>> getSyncStatus({
    required String tableName,
    required int recordId,
    required String action,
  }) async {
    try {
      final db = await database;
      final result = await db.query(
        tableSyncStatus,
        where:
            'table_name = ? AND record_id = ? AND action = ?',
        whereArgs: [tableName, recordId, action],
        limit: 1,
      );
      return Result.success(result.isNotEmpty ? result.first : null);
    } catch (e) {
      return Result.failure(
        DatabaseException('获取同步状态失败: $e'),
      );
    }
  }

  // 获取待同步的记录
  Future<Result<List<Map<String, dynamic>>>> getPendingSyncs() async {
    try {
      final db = await database;
      final result = await db.query(
        tableSyncStatus,
        where: 'status = ?',
        whereArgs: ['pending'],
        orderBy: 'created_at ASC',
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(
        DatabaseException('获取待同步记录失败: $e'),
      );
    }
  }

  // 标记同步完成
  Future<Result<int>> markSyncCompleted(int id) async {
    try {
      final db = await database;
      final count = await db.update(
        tableSyncStatus,
        {
          'status': 'synced',
          'synced_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      return Result.success(count);
    } catch (e) {
      return Result.failure(
        DatabaseException('标记同步完成失败: $e'),
      );
    }
  }

  // 标记同步失败
  Future<Result<int>> markSyncFailed(int id) async {
    try {
      final db = await database;
      final count = await db.update(
        tableSyncStatus,
        {'status': 'failed'},
        where: 'id = ?',
        whereArgs: [id],
      );
      return Result.success(count);
    } catch (e) {
      return Result.failure(
        DatabaseException('标记同步失败失败: $e'),
      );
    }
  }

  // 清除已同步的记录
  Future<Result<int>> clearSyncedRecords() async {
    try {
      final db = await database;
      final count = await db.delete(
        tableSyncStatus,
        where: 'status = ?',
        whereArgs: ['synced'],
      );
      return Result.success(count);
    } catch (e) {
      return Result.failure(
        DatabaseException('清除同步记录失败: $e'),
      );
    }
  }

  // ==================== 工具方法 ====================

  // 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  // 删除数据库
  Future<Result<bool>> deleteDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);
      if (_database != null) {
        await _database!.close();
        _database = null;
      }
      await sqflite.deleteDatabase(path);
      return Result.success(true);
    } catch (e) {
      return Result.failure(
        DatabaseException('删除数据库失败: $e'),
      );
    }
  }

  // 获取数据库文件大小（字节）
  Future<Result<int>> getDatabaseSize() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);
      final file = await File(path).length();
      return Result.success(file);
    } catch (e) {
      return Result.failure(
        DatabaseException('获取数据库大小失败: $e'),
      );
    }
  }

  // 获取各表记录数
  Future<Result<Map<String, int>>> getTableCounts() async {
    try {
      final db = await database;
      final tables = [
        tableFavorites,
        tablePlayHistory,
        tableUsers,
        tableSyncStatus,
      ];
      final counts = <String, int>{};
      for (final table in tables) {
        final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table');
//         counts[table] = sqflite.Sqflite.firstIntValue(result) ?? 0;
        counts[table] = Sqflite.firstIntValue(result) ?? 0;
      }
      return Result.success(counts);
    } catch (e) {
      return Result.failure(
        DatabaseException('获取表记录数失败: $e'),
      );
    }
  }
}