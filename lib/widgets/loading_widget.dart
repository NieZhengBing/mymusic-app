import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// 加载状态Widget集合

// 基础加载Widget
class LoadingWidget extends StatelessWidget {
  final double size;
  final Color? color;
  final String? text;
  final TextStyle? textStyle;

  const LoadingWidget({
    super.key,
    this.size = 40,
    this.color,
    this.text,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: SpinKitPulse(
            color: color ?? colorScheme.primary,
            size: size * 0.8,
          ),
        ),
        if (text != null) ...[
          const SizedBox(height: 12),
          Text(
            text!,
            style: textStyle ?? theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

// 全屏加载
class FullScreenLoading extends StatelessWidget {
  final String message;
  final bool showProgress;

  const FullScreenLoading({
    super.key,
    this.message = '加载中...',
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showProgress)
              const CircularProgressIndicator()
            else
              const LoadingWidget(size: 48),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }
}

// 列表加载更多
class LoadingMoreWidget extends StatelessWidget {
  final String text;

  const LoadingMoreWidget({super.key, this.text = '加载更多...'});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(text),
          ],
        ),
      ),
    );
  }
}

// 刷新指示器
class RefreshIndicatorWidget extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const RefreshIndicatorWidget({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: child,
    );
  }
}

// 加载失败Widget
class LoadFailedWidget extends StatelessWidget {
  final String message;
  final String buttonText;
  final VoidCallback onRetry;
  final IconData? icon;

  const LoadFailedWidget({
    super.key,
    required this.message,
    required this.buttonText,
    required this.onRetry,
    this.icon = Icons.refresh,
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
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}

// 空状态Widget
class EmptyWidget extends StatelessWidget {
  final String message;
  final String? subMessage;
  final IconData icon;
  final Widget? action;
  final double iconSize;

  const EmptyWidget({
    super.key,
    required this.message,
    this.subMessage,
    this.icon = Icons.music_off,
    this.action,
    this.iconSize = 64,
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
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (subMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                subMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// 自定义加载动画
class CustomLoadingWidget extends StatelessWidget {
  final double size;
  final Color color;
  final Duration duration;

  const CustomLoadingWidget({
    super.key,
    this.size = 50,
    this.color = Colors.white,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SpinKitRing(
        color: color,
        lineWidth: 4,
        size: size,
      ),
    );
  }
}
