<div align="center">

# 🎵 MyMusic App（我的音樂）

**一款簡潔、無廣告的跨平台音樂播放器**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/平台-Android%20|%20iOS-brightgreen)](https://flutter.dev)
[![License](https://img.shields.io/badge/許可協議-CC%20BY--NC--SA%204.0-red)](LICENSE)

[English](./README.md) | [简体中文](./README.zh-CN.md) | [繁體中文](./README.zh-TW.md) | [日本語](./README.ja.md)

</div>

---

使用 Flutter 構建的輕量級跨平台音樂播放器。專注於純粹的音樂體驗——無廣告、無推薦算法干擾、無多餘功能。

## ✨ 功能特性

| 功能 | 狀態 |
|------|------|
| 🎶 本地音樂播放（MP3、FLAC、WAV、AAC、M4A、OGG、WMA、APE） | ✅ |
| 📝 LRC/KRC 歌詞顯示，自動滾動 | ✅ |
| 📋 歌單管理（創建、編輯、刪除） | ✅ |
| ▶️ 播放控制（播放/暫停、上一曲/下一曲、進度拖拽） | ✅ |
| 🔁 播放模式（順序、單曲循環、隨機、列表循環） | ✅ |
| 🔍 本地音樂搜尋 | ✅ |
| ❤️ 收藏與播放歷史 | ✅ |
| 🌙 深色/淺色主題（跟隨系統） | ✅ |
| 🔔 通知欄播放控制 | ✅ |
| ☁️ 雲端同步（Firebase Auth + Firestore） | ✅ |
| 🎨 Material Design 3 | ✅ |

## 🛠 技術棧

| 層級 | 技術 |
|------|------|
| 框架 | Flutter + Dart |
| 狀態管理 | Provider |
| 音頻引擎 | just_audio + audio_session |
| 本地數據庫 | sqflite (SQLite) |
| 本地存儲 | SharedPreferences |
| 文件掃描 | permission_handler + file_picker |
| 元數據解析 | audio_metadata |
| 雲端同步 | Firebase Auth + Cloud Firestore |
| 通知 | flutter_local_notifications |
| 動畫 | flutter_spinkit + Lottie |
| UI | Material Design 3 |

## 🚀 快速開始

### 環境要求

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / Xcode（iOS 開發）

### 安裝運行

```bash
# 克隆倉庫
git clone https://github.com/NieZhengBing/mymusic-app.git
cd mymusic-app

# 安裝依賴
flutter pub get

# 運行到 Android
flutter run -d android

# 運行到 iOS
flutter run -d ios
```

### Firebase 配置（可選 - 用於雲端同步）

1. 在 [firebase.google.com](https://firebase.google.com) 創建 Firebase 項目
2. 添加 Android/iOS 應用到 Firebase 項目
3. 下載 `google-services.json`（Android）和 `GoogleService-Info.plist`（iOS）
4. 將文件放入對應的平台目錄
5. 更新 `lib/providers/auth_provider.dart` 中的 Firebase 配置

## 📁 項目結構

```
lib/
├── main.dart                     # 應用入口
├── models/                       # 數據模型
│   ├── song.dart                 # 歌曲模型
│   ├── playlist.dart             # 歌單模型
│   ├── lyric.dart                # 歌詞模型
│   └── app_user.dart             # 用戶模型
├── providers/                    # 狀態管理
│   ├── audio_provider.dart       # 音頻播放狀態
│   └── auth_provider.dart        # 認證狀態
├── screens/                      # UI頁面
│   ├── main_screen.dart          # 主界面（底部導航 + 迷你播放器）
│   ├── library_screen.dart       # 音樂庫
│   ├── playlist_screen.dart      # 歌單管理
│   └── player_screen.dart        # 全屏播放器
├── services/                     # 服務層
│   ├── file_scanner.dart         # 文件掃描
│   ├── metadata_parser.dart      # 音頻元數據解析
│   ├── notification_service.dart # 通知欄控制
│   ├── permission_service.dart   # 權限管理
│   ├── playlist_storage.dart     # 歌單持久化
│   └── sync_service.dart         # 雲端同步服務
├── user/
│   └── database/
│       └── db_helper.dart        # SQLite數據庫幫助類
├── utils/                        # 工具類
│   ├── exceptions.dart           # 自定義異常 & Result 類型
│   ├── error_handler.dart        # 錯誤處理
│   ├── lyric_parser.dart         # LRC/KRC歌詞解析
│   └── demo_data.dart            # 演示數據生成
└── widgets/                      # 可復用組件
    ├── loading_widget.dart       # 加載狀態
    └── empty_state_widget.dart   # 空狀態
```

## 🎵 支持格式

**音頻格式:** MP3、FLAC、WAV、AAC、M4A、OGG、WMA、APE

**歌詞格式:** LRC（完全支持）、KRC（基礎支持）

## 🔒 安全說明

- Android：網絡安全策略，默認禁止明文流量
- iOS：啟用 App Transport Security，強制 HTTPS
- 禁止應用數據備份
- 使用參數化 SQL 查詢防止注入攻擊

## 📜 許可協議

本項目採用 **Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International（CC BY-NC-SA 4.0）** 許可協議。

[![CC BY-NC-SA 4.0](https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png)](https://creativecommons.org/licenses/by-nc-sa/4.0/)

### 您可以自由：
- **共享** — 在任何媒介以任何形式複製、發行本作品
- **演繹** — 修改、轉換或以本作品為基礎進行創作

### 惟須遵守以下條件：
- **署名** — 您必須給出適當的署名
- **非商業性使用** — 您不得將本作品用於商業目的
- **相同方式共享** — 如果您對作品進行修改、轉換或再創作，必須使用相同的許可協議

### 商業使用
**嚴禁任何商業用途**。如需商業授權，請聯繫倉庫所有者。

## 🤝 貢獻指南

本項目主要作為個人技術練手項目，歡迎通過 Issues 提交建議和 Bug 報告。

## 🙏 致謝

- [just_audio](https://pub.dev/packages/just_audio) - 音頻播放引擎
- [sqflite](https://pub.dev/packages/sqflite) - 本地數據庫
- [Flutter](https://flutter.dev) - 跨平台框架