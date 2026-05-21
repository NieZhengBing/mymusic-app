import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

import '../models/song.dart';
import '../models/lyric.dart';
import '../utils/lyric_parser.dart';

// 播放模式枚举
enum PlayMode {
  sequence, // 顺序播放
  loop,     // 单曲循环
  shuffle,  // 随机播放
  loopAll,  // 列表循环
}


// 音频播放器Provider
// 管理播放状态、当前歌曲、播放列表等
class AudioProvider with ChangeNotifier {

  Song? _currentSong;

  // 播放器实例
  final AudioPlayer _audioPlayer = AudioPlayer();

  // 播放列表
  List<Song> _playlist = [];
  int _currentIndex = -1;

  // 播放状态
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // 其他状态
  PlayMode _playMode = PlayMode.sequence;
  double _volume = 1.0;
  Lyric? _lyric;
  String _currentLyric = '';

  // 初始化
  AudioProvider() {
    _initPlayer();
  }

  // 初始化播放器
  Future<void> _initPlayer() async {
    // 配置音频会话
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // 监听播放位置
    _audioPlayer.positionStream.listen((position) {
      _currentPosition = position;
      _updateLyric();
      notifyListeners();
    });

    // 监听总时长
    _audioPlayer.durationStream.listen((duration) {
      _totalDuration = duration ?? Duration.zero;
      notifyListeners();
    });

    // 监听播放状态
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      // 监听播放完成
      if (state.processingState == ProcessingState.completed) {
        _handlePlaybackCompleted();
      }
      notifyListeners();
    });

    // 设置音量
    _audioPlayer.setVolume(_volume);
  }

  // 更新当前歌词
  void _updateLyric() {
    if (_lyric == null) return;
    final newLyric = _lyric!.getLyricAt(_currentPosition);
    if (newLyric != _currentLyric) {
      _currentLyric = newLyric;
      notifyListeners();
    }
  }

  // 处理播放完成
  Future<void> _handlePlaybackCompleted() async {
    switch (_playMode) {
      case PlayMode.sequence:
        // 顺序播放 - 播放下一曲
        if (_currentIndex < _playlist.length - 1) {
          await playSong(_playlist[_currentIndex + 1]);
        }
        break;
      case PlayMode.loop:
        // 单曲循环 - 重新播放
        if (_currentSong != null) {
          await seek(Duration.zero);
          await play();
        }
        break;
      case PlayMode.shuffle:
        // 随机播放
        if (_playlist.isNotEmpty) {
          final randomIndex = (_currentIndex + 1) % _playlist.length;
          await playSong(_playlist[randomIndex]);
        }
        break;
      case PlayMode.loopAll:
        // 列表循环
        if (_playlist.isNotEmpty) {
          final nextIndex = (_currentIndex + 1) % _playlist.length;
          await playSong(_playlist[nextIndex]);
        }
        break;
    }
  }

  // ============ Getters ============

  AudioPlayer get audioPlayer => _audioPlayer;
  List<Song> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  PlayMode get playMode => _playMode;
  double get volume => _volume;
  Lyric? get lyric => _lyric;
  String get currentLyric => _currentLyric;

  Song? get currentSong => _currentIndex >= 0 && _currentIndex < _playlist.length
      ? _playlist[_currentIndex]
      : null;

  // ============ 播放控制 ============

  // 播放歌曲
  Future<void> playSong(Song song, {List<Song>? playlist}) async {
    if (playlist != null) {
      _playlist = playlist;
      _currentIndex = _playlist.indexWhere((s) => s.id == song.id);
      if (_currentIndex == -1) {
        // 如果歌曲不在播放列表中，添加它
        _playlist.insert(0, song);
        _currentIndex = 0;
      }
    } else {
      // 如果当前播放列表为空，创建新列表
      if (_playlist.isEmpty) {
        _playlist = [song];
        _currentIndex = 0;
      } else {
        // 找到歌曲在列表中的位置
        _currentIndex = _playlist.indexWhere((s) => s.id == song.id);
        if (_currentIndex == -1) {
          _playlist = [song];
          _currentIndex = 0;
        }
      }
    }

    // 设置音频源
    await _audioPlayer.setUrl(song.path);

    // 加载歌词
    await _loadLyric(song);

    // 开始播放
    await play();
  }

  // 加载歌词
  Future<void> _loadLyric(Song song) async {
    // 如果是本地文件，尝试加载本地歌词
    if (song.isLocal) {
      _lyric = await LyricParser.loadLyricFromFile(song.path);
    } else {
      _lyric = null;
    }
    _currentLyric = '';
  }

  // 播放
  Future<void> play() async {
    await _audioPlayer.play();
  }

  // 暂停
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  // 切换播放/暂停
  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      if (_currentSong == null && _playlist.isNotEmpty) {
        await playSong(_playlist[0]);
      } else {
        await play();
      }
    }
  }

  // 停止
  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentPosition = Duration.zero;
    notifyListeners();
  }

  // 跳转到指定位置
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // 播放上一曲
  Future<void> playPrevious() async {
    if (_playlist.isEmpty) return;

    switch (_playMode) {
      case PlayMode.shuffle:
        // 随机模式下随机播放
        final randomIndex = DateTime.now().millisecond % _playlist.length;
        await playSong(_playlist[randomIndex]);
        break;
      default:
        // 其他模式下播放上一曲
        if (_currentIndex > 0) {
          await playSong(_playlist[_currentIndex - 1]);
        } else {
          // 到达开头，根据模式处理
          if (_playMode == PlayMode.loopAll && _playlist.isNotEmpty) {
            await playSong(_playlist[_playlist.length - 1]);
          }
        }
    }
  }

  // 播放下一曲
  Future<void> playNext() async {
    if (_playlist.isEmpty) return;

    switch (_playMode) {
      case PlayMode.shuffle:
        // 随机模式下随机播放
        final randomIndex = DateTime.now().millisecond % _playlist.length;
        await playSong(_playlist[randomIndex]);
        break;
      default:
        // 其他模式下播放下一曲
        if (_currentIndex < _playlist.length - 1) {
          await playSong(_playlist[_currentIndex + 1]);
        } else {
          // 到达末尾，根据模式处理
          if (_playMode == PlayMode.loopAll && _playlist.isNotEmpty) {
            await playSong(_playlist[0]);
          }
        }
    }
  }

  // 设置播放模式
  void setPlayMode(PlayMode mode) {
    _playMode = mode;
    notifyListeners();
  }

  // 切换播放模式
  void togglePlayMode() {
    final modes = PlayMode.values;
    final currentIndex = modes.indexOf(_playMode);
    _playMode = modes[(currentIndex + 1) % modes.length];
    notifyListeners();
  }

  // 设置音量
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(_volume);
    notifyListeners();
  }

  // 设置播放列表
  void setPlaylist(List<Song> songs, {int startIndex = 0}) {
    _playlist = List.from(songs);
    if (_playlist.isNotEmpty && startIndex >= 0 && startIndex < _playlist.length) {
      _currentIndex = startIndex;
    } else {
      _currentIndex = 0;
    }
    notifyListeners();
  }

  // 添加歌曲到播放列表
  void addToPlaylist(Song song) {
    _playlist.add(song);
    notifyListeners();
  }

  // 从播放列表移除歌曲
  void removeFromPlaylist(int index) {
    if (index >= 0 && index < _playlist.length) {
      _playlist.removeAt(index);
      // 调整当前索引
      if (_currentIndex >= _playlist.length) {
        _currentIndex = _playlist.length - 1;
      } else if (_currentIndex > index) {
        _currentIndex--;
      }
      notifyListeners();
    }
  }

  // 清空播放列表
  void clearPlaylist() {
    _playlist.clear();
    _currentIndex = -1;
    _lyric = null;
    _currentLyric = '';
    stop();
    notifyListeners();
  }

  // 格式化时长显示
  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // 获取播放模式显示文本
  String getPlayModeText() {
    switch (_playMode) {
      case PlayMode.sequence:
        return '顺序播放';
      case PlayMode.loop:
        return '单曲循环';
      case PlayMode.shuffle:
        return '随机播放';
      case PlayMode.loopAll:
        return '列表循环';
    }
  }

  // 清理
  @override
  Future<void> dispose() async {
    await _audioPlayer.dispose();
    super.dispose();
  }
}
