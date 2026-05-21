import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/playlist.dart';
import '../models/song.dart';

// 歌单存储服务
// 使用SharedPreferences保存歌单数据
class PlaylistStorage {
  static final PlaylistStorage _instance = PlaylistStorage._internal();
  static const String _playlistsKey = 'playlists';
  static const String _songsKey = 'songs';

  factory PlaylistStorage() => _instance;

  PlaylistStorage._internal();

  // 获取所有歌单
  Future<List<Playlist>> getAllPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_playlistsKey);
    if (data == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => Playlist.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // 创建歌单
  Future<void> createPlaylist(String name, {String? description}) async {
    final playlists = await getAllPlaylists();
    final newId = playlists.isEmpty
        ? 1
        : playlists.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;

    playlists.add(Playlist(
      id: newId,
      name: name,
      description: description,
      createdAt: DateTime.now(),
      songIds: [],
    ));

    await _savePlaylists(playlists);
  }

  // 删除歌单
  Future<void> deletePlaylist(int playlistId) async {
    final playlists = await getAllPlaylists();
    playlists.removeWhere((p) => p.id == playlistId);
    await _savePlaylists(playlists);
  }

  // 更新歌单
  Future<void> updatePlaylist(Playlist playlist) async {
    final playlists = await getAllPlaylists();
    final index = playlists.indexWhere((p) => p.id == playlist.id);
    if (index >= 0) {
      playlists[index] = playlist;
      await _savePlaylists(playlists);
    }
  }

  // 添加歌曲到歌单
  Future<void> addSongToPlaylist(int playlistId, int songId) async {
    final playlists = await getAllPlaylists();
    final index = playlists.indexWhere((p) => p.id == playlistId);
    if (index >= 0) {
      if (!playlists[index].songIds.contains(songId)) {
        playlists[index].songIds.add(songId);
        await _savePlaylists(playlists);
      }
    }
  }

  // 从歌单移除歌曲
  Future<void> removeSongFromPlaylist(int playlistId, int songId) async {
    final playlists = await getAllPlaylists();
    final index = playlists.indexWhere((p) => p.id == playlistId);
    if (index >= 0) {
      playlists[index].songIds.remove(songId);
      await _savePlaylists(playlists);
    }
  }

  // 获取歌单(包含歌曲)
  Future<Playlist?> getPlaylistWithSongs(int playlistId) async {
    final playlists = await getAllPlaylists();
    try {
      return playlists.firstWhere((p) => p.id == playlistId);
    } catch (e) {
      return null;
    }
  }

  // 保存歌曲列表
  Future<void> saveSongs(List<Song> songs) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(songs.map((s) => s.toJson()).toList());
    await prefs.setString(_songsKey, data);
  }

  // 获取所有歌曲
  Future<List<Song>> getSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_songsKey);
    if (data == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => Song.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // 根据ID获取歌曲
  Future<Song?> getSongById(int songId) async {
    final songs = await getSongs();
    try {
      return songs.firstWhere((s) => s.id == songId);
    } catch (e) {
      return null;
    }
  }

  // 保存歌单到SharedPreferences
  Future<void> _savePlaylists(List<Playlist> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(playlists.map((p) => p.toJson()).toList());
    await prefs.setString(_playlistsKey, data);
  }
}