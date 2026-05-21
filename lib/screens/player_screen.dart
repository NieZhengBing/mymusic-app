import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../providers/audio_provider.dart';
import '../models/lyric.dart';

// 播放器页面
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  // 用于自动滚动歌词
  final ScrollController _lyricScrollController = ScrollController();
  bool _isDraggingSlider = false;
  Timer? _hideControlsTimer;
  bool _controlsVisible = true;

  @override
  void initState() {
    super.initState();
    _startHideControlsTimer();
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _lyricScrollController.dispose();
    super.dispose();
  }

  // 开始隐藏控制栏的计时器
  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    // 5秒后隐藏控制栏
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  // 点击屏幕时重新显示控制栏
  void _onScreenTap() {
    if (!_controlsVisible) {
      setState(() => _controlsVisible = true);
    }
    _startHideControlsTimer();
  }

  // 自动滚动歌词到当前播放的歌词
  void _scrollToCurrentLyric(AudioProvider audioProvider) {
    if (audioProvider.lyric == null) return;

    final currentIndex = audioProvider.lyric!.getCurrentIndex(
      audioProvider.currentPosition,
    );

    if (currentIndex >= 0) {
      // 计算滚动位置
      final itemHeight = 48.0;
      final scrollOffset = currentIndex * itemHeight - 150;

      if (scrollOffset >= 0) {
        _lyricScrollController.animateTo(
          scrollOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        if (audioProvider.currentSong == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('播放器')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.music_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    '没有正在播放的歌曲',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('返回'),
                  ),
                ],
              ),
            ),
          );
        }

        final song = audioProvider.currentSong!;
        final lyric = audioProvider.lyric;

        // 自动滚动歌词
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDraggingSlider) {
            _scrollToCurrentLyric(audioProvider);
          }
        });

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.queue_music, color: Colors.white),
                onPressed: () {
                  // 显示播放列表
                },
              ),
            ],
          ),
          body: GestureDetector(
            onTap: _onScreenTap,
            onVerticalDragStart: (_) => _onScreenTap(),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.primary,
                    colorScheme.primaryContainer,
                    colorScheme.surface,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // 顶部专辑封面
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: const ColoredBox(
                            color: Color(0xFF2196F3),
                            child: Center(
                              child: Icon(
                                Icons.music_note,
                                size: 120,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 歌曲信息
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            song.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${song.artist} - ${song.album}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 歌词区域
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      child: _buildLyricView(audioProvider),
                    ),
                  ),

                  // 进度条
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              audioProvider.formatDuration(
                                audioProvider.currentPosition,
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 16,
                                  ),
                                  activeTrackColor: colorScheme.secondary,
                                  inactiveTrackColor: Colors.white30,
                                  thumbColor: colorScheme.secondary,
                                ),
                                child: Slider(
                                  value: _isDraggingSlider
                                      ? 0
                                      : audioProvider.currentPosition.inMilliseconds
                                          .toDouble(),
                                  min: 0,
                                  max: audioProvider.totalDuration.inMilliseconds
                                      .toDouble(),
                                  onChangeStart: (_) {
                                    setState(() => _isDraggingSlider = true);
                                  },
                                  onChangeEnd: (_) {
                                    setState(() => _isDraggingSlider = false);
                                  },
                                  onChanged: (value) {
                                    audioProvider.seek(
                                      Duration(
                                        milliseconds: value.toInt(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Text(
                              audioProvider.totalDuration.inMilliseconds == 0
                                  ? '--:--'
                                  : audioProvider.formatDuration(
                                      audioProvider.totalDuration,
                                    ),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 控制按钮
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // núcleo - 上一曲
                        _buildControlButton(
                          Icons.shuffle,
                          colorScheme.primary,
                          () => audioProvider.togglePlayMode(),
                        ),
                        // 上一曲
                        _buildControlButton(
                          Icons.skip_previous,
                          colorScheme.primary,
                          audioProvider.playPrevious,
                        ),
                        // 播放/暂停
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: colorScheme.secondary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.secondary.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              audioProvider.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              size: 32,
                              color: colorScheme.onSecondary,
                            ),
                            onPressed: audioProvider.togglePlayPause,
                          ),
                        ),
                        // 下一曲
                        _buildControlButton(
                          Icons.skip_next,
                          colorScheme.primary,
                          audioProvider.playNext,
                        ),
                        // 循环模式
                        _buildControlButton(
                          _getPlayModeIcon(audioProvider.playMode),
                          colorScheme.primary,
                          audioProvider.togglePlayMode,
                        ),
                      ],
                    ),
                  ),

                  // 底部信息栏
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 16,
                      top: 8,
                    ),
                    child: Text(
                      audioProvider.getPlayModeText(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 构建控制按钮
  Widget _buildControlButton(
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return IconButton(
      icon: Icon(icon, size: 28),
      color: Colors.white,
      onPressed: onPressed,
    );
  }

  // 构建歌词视图
  Widget _buildLyricView(AudioProvider audioProvider) {
    final lyric = audioProvider.lyric;
    final currentLyric = audioProvider.currentLyric;

    if (lyric == null || lyric.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.subtitles_off,
              size: 32,
              color: Colors.white30,
            ),
            const SizedBox(height: 8),
            Text(
              '暂无歌词',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white30,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _lyricScrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: lyric.lines.length,
      itemBuilder: (context, index) {
        final line = lyric.lines[index];
        final isCurrent = line.text == currentLyric;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            line.text,
            style: TextStyle(
              fontSize: isCurrent ? 18 : 14,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent ? Colors.white : Colors.white60,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  // 获取播放模式图标
  IconData _getPlayModeIcon(PlayMode mode) {
    switch (mode) {
      case PlayMode.sequence:
        return Icons.repeat_on;
      case PlayMode.loop:
        return Icons.repeat_one_on;
      case PlayMode.shuffle:
        return Icons.shuffle_on;
      case PlayMode.loopAll:
        return Icons.repeat;
    }
  }
}
