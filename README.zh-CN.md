<div align="center">

# 🎵 MyMusic App（我的音乐）

**一款简洁、无广告的跨平台音乐播放器**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/平台-Android%20|%20iOS-brightgreen)](https://flutter.dev)
[![License](https://img.shields.io/badge/许可协议-CC%20BY--NC--SA%204.0-red)](LICENSE)

[English](./README.md) | [简体中文](./README.zh-CN.md) | [繁體中文](./README.zh-TW.md) | [日本語](./README.ja.md)

</div>

---

使用 Flutter 构建的轻量级跨平台音乐播放器。专注于纯粹的音乐体验——无广告、无推荐算法干扰、无多余功能。

## ✨ 功能特性

| 功能 | 状态 |
|------|------|
| 🎶 本地音乐播放（MP3、FLAC、WAV、AAC、M4A、OGG、WMA、APE） | ✅ |
| 📝 LRC/KRC 歌词显示，自动滚动 | ✅ |
| 📋 歌单管理（创建、编辑、删除） | ✅ |
| ▶️ 播放控制（播放/暂停、上一曲/下一曲、进度拖拽） | ✅ |
| 🔁 播放模式（顺序、单曲循环、随机、列表循环） | ✅ |
| 🔍 本地音乐搜索 | ✅ |
| ❤️ 收藏与播放历史 | ✅ |
| 🌙 深色/浅色主题（跟随系统） | ✅ |
| 🔔 通知栏播放控制 | ✅ |
| ☁️ 云同步（Firebase Auth + Firestore） | ✅ |
| 🎨 Material Design 3 | ✅ |

## 🛠 技术栈

| 层级 | 技术 |
|------|------|
| 框架 | Flutter + Dart |
| 状态管理 | Provider |
| 音频引擎 | just_audio + audio_session |
| 本地数据库 | sqflite (SQLite) |
| 本地存储 | SharedPreferences |
| 文件扫描 | permission_handler + file_picker |
| 元数据解析 | audio_metadata |
| 云同步 | Firebase Auth + Cloud Firestore |
| 通知 | flutter_local_notifications |
| 动画 | flutter_spinkit + Lottie |
| UI | Material Design 3 |

## 🚀 快速开始

### 环境要求

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / Xcode（iOS 开发）

### 安装运行

```bash
# 克隆仓库
git clone https://github.com/NieZhengBing/mymusic-app.git
cd mymusic-app

# 安装依赖
flutter pub get

# 运行到 Android
flutter run -d android

# 运行到 iOS
flutter run -d ios
```

### Firebase 配置（可选 - 用于云同步）

1. 在 [firebase.google.com](https://firebase.google.com) 创建 Firebase 项目
2. 添加 Android/iOS 应用到 Firebase 项目
3. 下载 `google-services.json`（Android）和 `GoogleService-Info.plist`（iOS）
4. 将文件放入对应的平台目录
5. 更新 `lib/providers/auth_provider.dart` 中的 Firebase 配置

## 📁 项目结构

```
lib/
├── main.dart                     # 应用入口
├── models/                       # 数据模型
│   ├── song.dart                 # 歌曲模型
│   ├── playlist.dart             # 歌单模型
│   ├── lyric.dart                # 歌词模型
│   └── app_user.dart             # 用户模型
├── providers/                    # 状态管理
│   ├── audio_provider.dart       # 音频播放状态
│   └── auth_provider.dart        # 认证状态
├── screens/                      # UI页面
│   ├── main_screen.dart          # 主界面（底部导航 + 迷你播放器）
│   ├── library_screen.dart       # 音乐库
│   ├── playlist_screen.dart      # 歌单管理
│   └── player_screen.dart        # 全屏播放器
├── services/                     # 服务层
│   ├── file_scanner.dart         # 文件扫描
│   ├── metadata_parser.dart      # 音频元数据解析
│   ├── notification_service.dart # 通知栏控制
│   ├── permission_service.dart   # 权限管理
│   ├── playlist_storage.dart     # 歌单持久化
│   └── sync_service.dart         # 云同步服务
├── user/
│   └── database/
│       └── db_helper.dart        # SQLite数据库帮助类
├── utils/                        # 工具类
│   ├── exceptions.dart           # 自定义异常 & Result 类型
│   ├── error_handler.dart        # 错误处理
│   ├── lyric_parser.dart         # LRC/KRC歌词解析
│   └── demo_data.dart            # 演示数据生成
└── widgets/                      # 可复用组件
    ├── loading_widget.dart       # 加载状态
    └── empty_state_widget.dart   # 空状态
```

## 🎵 支持格式

**音频格式:** MP3、FLAC、WAV、AAC、M4A、OGG、WMA、APE

**歌词格式:** LRC（完全支持）、KRC（基础支持）

## 🔒 安全说明

- Android：网络安全策略，默认禁止明文流量
- iOS：启用 App Transport Security，强制 HTTPS
- 禁止应用数据备份
- 使用参数化 SQL 查询防止注入攻击

## 📜 许可协议

本项目采用 **Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International（CC BY-NC-SA 4.0）** 许可协议。

[![CC BY-NC-SA 4.0](https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png)](https://creativecommons.org/licenses/by-nc-sa/4.0/)

### 您可以自由：
- **共享** — 在任何媒介以任何形式复制、发行本作品
- **演绎** — 修改、转换或以本作品为基础进行创作

### 惟须遵守以下条件：
- **署名** — 您必须给出适当的署名
- **非商业性使用** — 您不得将本作品用于商业目的
- **相同方式共享** — 如果您对作品进行修改、转换或再创作，必须使用相同的许可协议

### 商业使用
**严禁任何商业用途**。如需商业授权，请联系仓库所有者。

## 🤝 贡献指南

本项目主要作为个人技术练手项目，欢迎通过 Issues 提交建议和 Bug 报告。

## 🙏 致谢

- [just_audio](https://pub.dev/packages/just_audio) - 音频播放引擎
- [sqflite](https://pub.dev/packages/sqflite) - 本地数据库
- [Flutter](https://flutter.dev) - 跨平台框架