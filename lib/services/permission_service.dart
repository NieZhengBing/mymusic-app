import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

import '../utils/exceptions.dart';
import '../utils/error_handler.dart';

// 权限服务
// 统一管理应用中的所有权限请求
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();

  factory PermissionService() => _instance;

  PermissionService._internal();

  // 存储权限状态
  PermissionStatus _storageStatus = PermissionStatus.denied;
  PermissionStatus _audioStatus = PermissionStatus.denied;
  PermissionStatus _notificationStatus = PermissionStatus.denied;

  // 检查并请求存储权限
  Future<bool> checkAndRequestStoragePermission({BuildContext? context}) async {
    // Android 13+
    if (defaultTargetPlatform == TargetPlatform.android) {
      // 尝试新的音频权限
      _audioStatus = await Permission.audio.request();
      if (_audioStatus.isGranted) {
        return true;
      }

      // fallback 到存储权限
      _storageStatus = await Permission.storage.request();
      if (_storageStatus.isGranted) {
        return true;
      }

      // 如果权限被永久拒绝，引导用户到设置
      if (_audioStatus.isPermanentlyDenied || _storageStatus.isPermanentlyDenied) {
        _showPermissionDeniedDialog(context);
      }

      return false;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      _storageStatus = await Permission.storage.request();
      if (_storageStatus.isGranted) {
        return true;
      }

      _audioStatus = await Permission.photos.request();
      if (_audioStatus.isGranted) {
        return true;
      }

      return false;
    }

    // Web和其他平台不需要权限
    return true;
  }

  // 检查通知权限
  Future<bool> checkAndRequestNotificationPermission({BuildContext? context}) async {
    _notificationStatus = await Permission.notification.request();
    return _notificationStatus.isGranted;
  }

  // 检查是否有存储权限
  Future<bool> hasStoragePermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final audioStatus = await Permission.audio.status;
      final storageStatus = await Permission.storage.status;
      return audioStatus.isGranted || storageStatus.isGranted;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final storageStatus = await Permission.storage.status;
      return storageStatus.isGranted;
    }
    return true;
  }

  // 打开设置页面
  static Future<void> openSettings() async {
    await openAppSettings();
  }

  // 显示权限被拒绝的对话框
  void _showPermissionDeniedDialog(BuildContext? context) {
    if (context == null) return;

    ErrorHandler.showConfirmDialog(
      context,
      title: '权限被拒绝',
      content: '为了正常使用应用，请到设置中启用存储权限',
      confirmText: '去设置',
      cancelText: '取消',
    ).then((value) {
      if (value == true) {
        openSettings();
      }
    });
  }

  // 请求特定权限
  Future<bool> requestPermission(
    Permission permission, {
    BuildContext? context,
    String? title,
    String? message,
  }) async {
    final status = await permission.request();

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      // 权限被永久拒绝
      if (context != null) {
        ErrorHandler.showConfirmDialog(
          context,
          title: title ?? '权限需要',
          content: message ?? '请到设置中启用此权限',
          confirmText: '去设置',
          cancelText: '取消',
        ).then((value) {
          if (value == true) {
            openSettings();
          }
        });
      }
    }

    return false;
  }

  // 获取权限状态
  Future<PermissionStatus> getPermissionStatus(Permission permission) async {
    return await permission.status;
  }

  // 检查所有必要权限
  Future<Map<String, bool>> checkAllPermissions() async {
    final permissions = <String, bool>{};

    if (defaultTargetPlatform == TargetPlatform.android) {
      permissions['storage'] = await hasStoragePermission();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final status = await Permission.storage.status;
      permissions['storage'] = status.isGranted;
    }

    permissions['notification'] = (await Permission.notification.status).isGranted;

    return permissions;
  }

  // 请求所有必要权限
  Future<Map<String, bool>> requestAllPermissions({BuildContext? context}) async {
    final result = <String, bool>{};

    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      result['storage'] = await checkAndRequestStoragePermission(context: context);
    }

    result['notification'] = await checkAndRequestNotificationPermission();

    return result;
  }

  // 重置权限状态
  void resetPermissionStatus() {
    _storageStatus = PermissionStatus.denied;
    _audioStatus = PermissionStatus.denied;
    _notificationStatus = PermissionStatus.denied;
  }
}
