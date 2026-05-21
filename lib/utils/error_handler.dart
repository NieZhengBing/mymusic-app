import 'package:flutter/material.dart';
import 'exceptions.dart';
import 'dart:async';

// 错误处理器
// 统一处理应用中的各种错误，并提供用户友好的提示
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();

  factory ErrorHandler() => _instance;

  ErrorHandler._internal();

  // 全局BuildContext（用于在非Widget树中显示提示）
  static BuildContext? _globalContext;

  static void setGlobalContext(BuildContext context) {
    _globalContext = context;
  }

  // 显示错误提示
  static void showError(
    BuildContext? context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color? textColor,
    SnackBarAction? action,
  }) {
    final targetContext = context ?? _globalContext;
    if (targetContext == null) return;

    ScaffoldMessenger.of(targetContext).clearSnackBars();
    ScaffoldMessenger.of(targetContext).showSnackBar(
      SnackBar(
        // content: Text(message),
        content: Text(
          message,
          style: TextStyle(
            color: textColor ?? Colors.white,
          ),
        ),
        backgroundColor: backgroundColor ?? Colors.red,
        // textColor: textColor ?? Colors.white,

        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  // 显示成功提示
  static void showSuccess(
    BuildContext? context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    final targetContext = context ?? _globalContext;
    if (targetContext == null) return;

    ScaffoldMessenger.of(targetContext).clearSnackBars();
    ScaffoldMessenger.of(targetContext).showSnackBar(
      SnackBar(
        // content: Text(message),
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
//         textColor: Colors.white,
//         style: TextStyle(color: Colors.white),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  // 显示加载中提示
  static void showLoading(
    BuildContext? context, {
    String message = '加载中...',
    bool dismissible = false,
  }) {
    final targetContext = context ?? _globalContext;
    if (targetContext == null) return;

    showDialog(
      context: targetContext,
      barrierDismissible: dismissible,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 关闭加载对话框
  static void hideLoading(BuildContext? context) {
    final targetContext = context ?? _globalContext;
    if (targetContext == null) return;
    Navigator.of(targetContext).pop();
  }

  // 处理异常
  static void handleException(
    BuildContext? context,
    dynamic exception, {
    String? customMessage,
    Function? onRetry,
  }) {
    String message = customMessage ?? _getErrorMessage(exception);

    if (onRetry != null) {
      showError(
        context,
        message: message,
        action: SnackBarAction(
          label: '重试',
          textColor: Colors.white,
          // style: TextStyle(color: Colors.white),
          onPressed: (() => onRetry()),
        ),
      );
    } else {
      showError(context, message: message);
    }
  }

  // 获取错误消息
  static String _getErrorMessage(dynamic exception) {
    if (exception is AppException) {
      return exception.message;
    } else if (exception is FileScanException) {
      return '文件扫描失败: ${exception.message}';
    } else if (exception is DatabaseException) {
      return '数据库操作失败: ${exception.message}';
    } else if (exception is AudioException) {
      return '音频播放失败: ${exception.message}';
    } else if (exception is PermissionException) {
      return '权限不足: ${exception.message}';
    } else if (exception is NetworkException) {
      return '网络请求失败: ${exception.message}';
    } else if (exception is ValidationException) {
      return exception.message;
    } else if (exception is TimeoutException) {
      return '请求超时，请检查网络连接';
    } else if (exception is FormatException) {
      return '数据格式错误';
    } else if (exception is NoSuchMethodError) {
      return '功能不可用';
    } else if (exception is TypeError) {
      return '数据为空或类型错误';
    } else if (exception is RangeError) {
      return '索引越界';
    } else {
      return '发生未知错误: $exception';
    }
  }

  // 显示确认对话框
  static Future<bool?> showConfirmDialog(
    BuildContext? context, {
    required String title,
    String? content,
    String confirmText = '确认',
    String cancelText = '取消',
    Color? confirmColor,
    Color? cancelColor,
  }) async {
    final targetContext = context ?? _globalContext;
    if (targetContext == null) return null;

    return await showDialog<bool>(
      context: targetContext,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: content != null ? Text(content) : null,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: cancelColor ?? Theme.of(context).colorScheme.secondary,
            ),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: confirmColor ?? Theme.of(context).colorScheme.primary,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // 显示底部选择Sheet
  static Future<int?> showOptionsSheet(
    BuildContext? context, {
    required String title,
    required List<String> options,
    String? cancelText,
  }) async {
    final targetContext = context ?? _globalContext;
    if (targetContext == null) return null;

    return await showModalBottomSheet<int>(
      context: targetContext,
      builder: (context) => ListView.builder(
        itemCount: options.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            );
          } else if (index == options.length + 1) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                ),
                child: Text(cancelText ?? '取消'),
              ),
            );
          } else {
            return ListTile(
              title: Text(options[index - 1]),
              onTap: () => Navigator.of(context).pop(index - 1),
            );
          }
        },
      ),
    );
  }
}
