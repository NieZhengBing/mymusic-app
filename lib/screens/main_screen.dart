import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../AppLog.dart';
import '../providers/audio_provider.dart';
import '../providers/auth_provider.dart';
import 'library_screen.dart';
import 'playlist_screen.dart';
import 'player_screen.dart';

// 主界面 - 底部导航栏
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 页面列表
  final List<Widget> _screens = const [
    LibraryScreen(),
    PlaylistScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 显示当前页面
      body: _screens[_currentIndex],

      // 底部播放器栏（如果有正在播放的歌曲）
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 小播放器栏
          Consumer<AudioProvider>(
            builder: (context, audioProvider, child) {
              if (audioProvider.currentSong != null) {
                return _buildMiniPlayer(audioProvider);
              }
              return const SizedBox(height: 0);
            },
          ),

          // 底部导航栏
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.library_music_outlined),
                activeIcon: Icon(Icons.library_music),
                label: '音乐库',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.queue_music_outlined),
                activeIcon: Icon(Icons.queue_music),
                label: '歌单',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: '设置',
              ),
            ],
            type: BottomNavigationBarType.fixed,
          ),
        ],
      ),
    );
  }

  // 构建迷你播放器栏
  Widget _buildMiniPlayer(AudioProvider audioProvider) {
    final song = audioProvider.currentSong!;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PlayerScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // 专辑封面
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.music_note, size: 24),
            ),
            const SizedBox(width: 12),

            // 歌曲信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    song.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    song.artist,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 播放控制按钮
            IconButton(
              icon: Icon(
                audioProvider.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
              ),
              onPressed: () {
                audioProvider.togglePlayPause();
              },
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: () {
                audioProvider.playNext();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// 设置页面
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isLoggedIn;
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          // 用户信息区域
          InkWell(
            onTap: () {
              if (isLoggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 28,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLoggedIn
                              ? (user?.displayName ?? user?.email ?? '用户')
                              : '登录账户',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          isLoggedIn ? '点击查看账户信息' : '登录以同步数据',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          const Divider(),

          // 关于应用
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('关于'),
            subtitle: const Text('v1.0.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: '我的音乐',
                applicationVersion: '1.0.0',
                children: [
                  const Text('一个简洁无广告的音乐播放器'),
                ],
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: const Text('主题'),
            trailing: const Text('跟随系统'),
            onTap: () {
              // 主题切换逻辑
            },
          ),
          ListTile(
            leading: const Icon(Icons.bug_report_outlined),
            title: const Text('查看日志'),
            onTap: () {
              // 显示日志弹窗
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('日志'),
                  content: SingleChildScrollView(
                    child: Text(AppLog.logs.join('\n')),  // 👈 改这里
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('关闭'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
