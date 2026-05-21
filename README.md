<div align="center">

# 🎵 MyMusic App

**一款简洁、无广告的跨平台音乐播放器**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20|%20iOS-brightgreen)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-red)](LICENSE)

[English](./README.md) | [简体中文](./README.zh-CN.md) | [繁體中文](./README.zh-TW.md) | [日本語](./README.ja.md)

</div>

---

A clean, lightweight cross-platform music player built with Flutter. Focus on the pure music experience — no ads, no recommendation algorithms, no bloat.

## ✨ Features

| Feature | Status |
|---------|--------|
| 🎶 Local music playback (MP3, FLAC, WAV, AAC, M4A, OGG, WMA, APE) | ✅ |
| 📝 LRC/KRC lyrics display with auto-scroll | ✅ |
| 📋 Playlist management (create, edit, delete) | ✅ |
| ▶️ Playback controls (play/pause, prev/next, seek) | ✅ |
| 🔁 Play modes (sequence, single loop, shuffle, list loop) | ✅ |
| 🔍 Local music search | ✅ |
| ❤️ Favorites & play history | ✅ |
| 🌙 Dark/Light theme (follows system) | ✅ |
| 🔔 Notification bar controls | ✅ |
| ☁️ Cloud sync (Firebase Auth + Firestore) | ✅ |
| 🎨 Material Design 3 | ✅ |

## 🛠 Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter + Dart |
| State Management | Provider |
| Audio Engine | just_audio + audio_session |
| Local Database | sqflite (SQLite) |
| Local Storage | SharedPreferences |
| File Scanner | permission_handler + file_picker |
| Metadata Parser | audio_metadata |
| Cloud Sync | Firebase Auth + Cloud Firestore |
| Notifications | flutter_local_notifications |
| Animations | flutter_spinkit + Lottie |
| UI | Material Design 3 |

## 🚀 Quick Start

### Prerequisites

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / Xcode (for iOS)

### Installation

```bash
# Clone the repository
git clone https://github.com/NieZhengBing/mymusic-app.git
cd mymusic-app

# Install dependencies
flutter pub get

# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios
```

### Firebase Setup (Optional - for cloud sync)

1. Create a Firebase project at [firebase.google.com](https://firebase.google.com)
2. Add Android/iOS apps to your Firebase project
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Place them in the respective platform directories
5. Update Firebase config in `lib/providers/auth_provider.dart`

## 📁 Project Structure

```
lib/
├── main.dart                     # App entry point
├── models/                       # Data models
│   ├── song.dart                 # Song model
│   ├── playlist.dart             # Playlist model
│   ├── lyric.dart                # Lyric model
│   └── app_user.dart             # User model
├── providers/                    # State management
│   ├── audio_provider.dart       # Audio player state
│   └── auth_provider.dart        # Authentication state
├── screens/                      # UI pages
│   ├── main_screen.dart          # Main screen (bottom nav + mini player)
│   ├── library_screen.dart       # Music library
│   ├── playlist_screen.dart      # Playlist management
│   └── player_screen.dart        # Full-screen player
├── services/                     # Services
│   ├── file_scanner.dart         # File scanning
│   ├── metadata_parser.dart      # Audio metadata parsing
│   ├── notification_service.dart # Notification controls
│   ├── permission_service.dart   # Permission management
│   ├── playlist_storage.dart     # Playlist persistence
│   └── sync_service.dart         # Cloud sync service
├── user/
│   └── database/
│       └──         # SQLite database helper
├── utils/                        # Utilities
│   ├── exceptions.dart           # Custom exceptions & Result type
│   ├── error_handler.dart        # Error handling
│   ├── lyric_parser.dart         # LRC/KRC lyrics parser
│   └── demo_data.dart            # Demo data generator
└── widgets/                      # Reusable widgets
    ├── loading_widget.dart       # Loading states
    └── empty_state_widget.dart   # Empty states
```

## 🎵 Supported Formats

**Audio:** MP3, FLAC, WAV, AAC, M4A, OGG, WMA, APE

**Lyrics:** LRC (full support), KRC (basic support)

## 🔒 Security

- Android: Network security policy with cleartext traffic disabled by default
- iOS: App Transport Security enabled for HTTPS
- Data backup explicitly disabled
- Parameterized SQL queries to prevent injection

## 📜 License

This project is licensed under the **Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License**.

[![CC BY-NC-SA 4.0](https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png)](https://creativecommons.org/licenses/by-nc-sa/4.0/)

### You are free to:
- **Share** — copy and redistribute the material in any medium or format
- **Adapt** — remix, transform, and build upon the material

### Under the following terms:
- **Attribution** — You must give appropriate credit
- **NonCommercial** — You may not use the material for commercial purposes
- **ShareAlike** — If you remix, transform, or build upon the material, you must distribute your contributions under the same license

### Commercial use
Commercial use of this project is **strictly prohibited** without prior written permission from the author. For commercial licensing inquiries, please contact the repository owner.

## 🤝 Contributing

This project is primarily a personal learning project. However, suggestions and bug reports via Issues are welcome.

## 🙏 Acknowledgements

- [just_audio](https://pub.dev/packages/just_audio) - Audio playback engine
- [sqflite](https://pub.dev/packages/sqflite) - Local database
- [Flutter](https://flutter.dev) - Cross-platform framework