import 'package:flutter/material.dart';

// 空状态Widget集合
// 为不同场景提供统一的空状态显示

// 通用空状态Widget
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? action;
  final Color? iconColor;
  final double iconSize;
  final double spacing;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.info_outline,
    this.action,
    this.iconColor,
    this.iconSize = 64,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: iconColor ?? colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: spacing),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: spacing / 2),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              SizedBox(height: spacing * 2),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// 音乐库空状态
class EmptyLibraryWidget extends StatelessWidget {
  final VoidCallback onScan;

  const EmptyLibraryWidget({super.key, required this.onScan});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: '音乐库是空的',
      subtitle: '点击下方按钮扫描设备中的音乐文件',
      icon: Icons.library_music_outlined,
      iconSize: 80,
      action: ElevatedButton(
        onPressed: onScan,
        child: const Text('扫描音乐文件'),
      ),
    );
  }
}

// 歌单空状态
class EmptyPlaylistWidget extends StatelessWidget {
  final VoidCallback onCreate;

  const EmptyPlaylistWidget({super.key, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: '还没有歌单',
      subtitle: '点击下方按钮创建你的第一个歌单',
      icon: Icons.queue_music_outlined,
      iconSize: 80,
      action: ElevatedButton(
        onPressed: onCreate,
        child: const Text('创建歌单'),
      ),
    );
  }
}

// 歌单内歌曲空状态
class EmptySongsInPlaylistWidget extends StatelessWidget {
  final VoidCallback onAdd;

  const EmptySongsInPlaylistWidget({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: '歌单中还没有音乐',
      subtitle: '从音乐库中添加歌曲到这个歌单',
      icon: Icons.music_note_outlined,
      iconSize: 80,
      action: ElevatedButton(
        onPressed: onAdd,
        child: const Text('添加歌曲'),
      ),
    );
  }
}

// 搜索结果空状态
class EmptySearchResultWidget extends StatelessWidget {
  final String query;

  const EmptySearchResultWidget({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: '没有找到结果',
      subtitle: '没有找到与 "$query" 相关的内容',
      icon: Icons.search_off_outlined,
      iconSize: 80,
      action: TextButton(
        onPressed: () {},
        child: const Text('尝试其他关键词'),
      ),
    );
  }
}

// 播放历史空状态
class EmptyHistoryWidget extends StatelessWidget {
  const EmptyHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: '还没有播放记录',
      subtitle: '播放音乐后，这里会显示你的播放历史',
      icon: Icons.history_outlined,
      iconSize: 80,
    );
  }
}

// 收藏空状态
class EmptyFavoritesWidget extends StatelessWidget {
  const EmptyFavoritesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: '还没有收藏',
      subtitle: '点击歌曲旁边的心形图标收藏你喜欢的音乐',
      icon: Icons.favorite_outline,
      iconSize: 80,
    );
  }
}

// 网络错误空状态
class NetworkErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const NetworkErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: '网络连接错误',
      subtitle: message,
      icon: Icons.wifi_off_outlined,
      iconSize: 80,
      iconColor: Colors.red,
      action: ElevatedButton(
        onPressed: onRetry,
        child: const Text('重试'),
      ),
    );
  }
}

// 权限被拒绝空状态
class PermissionDeniedWidget extends StatelessWidget {
  final String permission;
  final VoidCallback onRequest;

  const PermissionDeniedWidget({
    super.key,
    required this.permission,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: '权限被拒绝',
      subtitle: '需要 $permission 权限才能继续',
      icon: Icons.lock_outline,
      iconSize: 80,
      iconColor: Colors.orange,
      action: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: onRequest,
            child: const Text('申请权限'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {},
            child: const Text('不再提示'),
          ),
        ],
      ),
    );
  }
}
