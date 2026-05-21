import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/audio_provider.dart';
import '../services/file_scanner.dart';
import '../models/song.dart';
import 'player_screen.dart';

// 音乐库页面
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<Song> _songs = [];
  bool _isLoading = true;
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  // 加载歌曲
  Future<void> _loadSongs() async {
    setState(() => _isLoading = true);

    // 使用文件扫描器扫描音乐文件
    final scanner = FileScanner();
    final result = await scanner.scanAndGetSongs();
    final songs = result.isSuccess ? result.data! : <Song>[];

    setState(() {
      _songs = songs;
      _isLoading = false;
      _hasScanned = true;
    });
  }

  // 刷新歌曲列表
  Future<void> _refreshSongs() async {
    await _loadSongs();
    // 显示提示
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('音乐库已刷新')),
    );
  }

  // 搜索歌曲
  void _searchSongs(String query) {
    if (query.isEmpty) {
      _loadSongs();
      return;
    }

    // 过滤歌曲
    setState(() {
      _songs = _songs.where((song) {
        return song.title.toLowerCase().contains(query.toLowerCase()) ||
            song.artist.toLowerCase().contains(query.toLowerCase()) ||
            song.album.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('音乐库'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshSongs,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _SongSearchDelegate(_songs),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _songs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.music_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        _hasScanned
                            ? '未找到音乐文件'
                            : '点击按钮扫描音乐',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (_hasScanned)
                        Text(
                          '请确保音乐文件在 Music 或 Download 目录',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _refreshSongs,
                        child: const Text('重新扫描'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _songs.length,
                  itemBuilder: (context, index) {
                    final song = _songs[index];
                    return _buildSongTile(context, song);
                  },
                ),
    );
  }

  // 构建歌曲列表项
  Widget _buildSongTile(BuildContext context, Song song) {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);

    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.music_note, size: 20),
      ),
      title: Text(
        song.title,
        style: const TextStyle(fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${song.artist} - ${song.album}',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        song.formattedDuration,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      onTap: () {
        audioProvider.playSong(song, playlist: _songs);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PlayerScreen(),
          ),
        );
      },
    );
  }
}

// 搜索代理类
class _SongSearchDelegate extends SearchDelegate<String> {
  final List<Song> songs;

  _SongSearchDelegate(this.songs);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // 过滤结果
    final results = songs.where((song) {
      return song.title.toLowerCase().contains(query.toLowerCase()) ||
          song.artist.toLowerCase().contains(query.toLowerCase()) ||
          song.album.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final song = results[index];
        return ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.music_note, size: 20),
          ),
          title: Text(song.title),
          subtitle: Text('${song.artist} - ${song.album}'),
          onTap: () {
            final audioProvider = Provider.of<AudioProvider>(context, listen: false);
            audioProvider.playSong(song, playlist: results);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PlayerScreen(),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // 显示所有匹配的建议
    final suggestions = query.isEmpty
        ? songs.sublist(0, 5)
        : songs.where((song) {
            return song.title.toLowerCase().contains(query.toLowerCase()) ||
                song.artist.toLowerCase().contains(query.toLowerCase()) ||
                song.album.toLowerCase().contains(query.toLowerCase());
          }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final song = suggestions[index];
        return ListTile(
          leading: const Icon(Icons.music_note),
          title: Text(song.title),
          subtitle: Text(song.artist),
          onTap: () {
            query = song.title;
            showResults(context);
          },
        );
      },
    );
  }
}
