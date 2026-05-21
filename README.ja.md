<div align="center">

# 🎵 MyMusic App（マイミュージック）

**シンプルで広告なしのクロスプラットフォーム音楽プレイヤー**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/プラットフォーム-Android%20|%20iOS-brightgreen)](https://flutter.dev)
[![License](https://img.shields.io/badge/ライセンス-CC%20BY--NC--SA%204.0-red)](LICENSE)

[English](./README.md) | [简体中文](./README.zh-CN.md) | [繁體中文](./README.zh-TW.md) | [日本語](./README.ja.md)

</div>

---

Flutter で構築された軽量クロスプラットフォーム音楽プレイヤー。純粋な音楽体験に集中——広告なし、レコメンドアルゴリズムなし、余計な機能なし。

## ✨ 機能一覧

| 機能 | 状態 |
|------|------|
| 🎶 ローカル音楽再生（MP3、FLAC、WAV、AAC、M4A、OGG、WMA、APE） | ✅ |
| 📝 LRC/KRC 歌詞表示、自動スクロール | ✅ |
| 📋 プレイリスト管理（作成、編集、削除） | ✅ |
| ▶️ 再生コントロール（再生/一時停止、前へ/次へ、シーク） | ✅ |
| 🔁 再生モード（順次、単曲リピート、シャッフル、リストリピート） | ✅ |
| 🔍 ローカル音楽検索 | ✅ |
| ❤️ お気に入りと再生履歴 | ✅ |
| 🌙 ダーク/ライトテーマ（システム追従） | ✅ |
| 🔔 通知バーコントロール | ✅ |
| ☁️ クラウド同期（Firebase Auth + Firestore） | ✅ |
| 🎨 Material Design 3 | ✅ |

## 🛠 技術スタック

| レイヤー | 技術 |
|----------|------|
| フレームワーク | Flutter + Dart |
| 状態管理 | Provider |
| オーディオエンジン | just_audio + audio_session |
| ローカルデータベース | sqflite (SQLite) |
| ローカルストレージ | SharedPreferences |
| ファイルスキャン | permission_handler + file_picker |
| メタデータ解析 | audio_metadata |
| クラウド同期 | Firebase Auth + Cloud Firestore |
| 通知 | flutter_local_notifications |
| アニメーション | flutter_spinkit + Lottie |
| UI | Material Design 3 |

## 🚀 クイックスタート

### 必要条件

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / Xcode（iOS 開発用）

### インストール

```bash
# リポジトリをクローン
git clone https://github.com/NieZhengBing/mymusic-app.git
cd mymusic-app

# 依存関係をインストール
flutter pub get

# Android で実行
flutter run -d android

# iOS で実行
flutter run -d ios
```

### Firebase 設定（オプション - クラウド同期用）

1. [firebase.google.com](https://firebase.google.com) で Firebase プロジェクトを作成
2. Android/iOS アプリを Firebase プロジェクトに追加
3. `google-services.json`（Android）と `GoogleService-Info.plist`（iOS）をダウンロード
4. 各プラットフォームのディレクトリに配置
5. `lib/providers/auth_provider.dart` の Firebase 設定を更新

## 📁 プロジェクト構成

```
lib/
├── main.dart                     # アプリエントリポイント
├── models/                       # データモデル
│   ├── song.dart                 # 楽曲モデル
│   ├── playlist.dart             # プレイリストモデル
│   ├── lyric.dart                # 歌詞モデル
│   └── app_user.dart             # ユーザーモデル
├── providers/                    # 状態管理
│   ├── audio_provider.dart       # オーディオ再生状態
│   └── auth_provider.dart        # 認証状態
├── screens/                      # UIページ
│   ├── main_screen.dart          # メイン画面（ボトムナビ + ミニプレイヤー）
│   ├── library_screen.dart       # ミュージックライブラリ
│   ├── playlist_screen.dart      # プレイリスト管理
│   └── player_screen.dart        # フルスクリーンプレイヤー
├── services/                     # サービス層
│   ├── file_scanner.dart         # ファイルスキャン
│   ├── metadata_parser.dart      # オーディオメタデータ解析
│   ├── notification_service.dart # 通知バーコントロール
│   ├── permission_service.dart   # 権限管理
│   ├── playlist_storage.dart     # プレイリスト永続化
│   └── sync_service.dart         # クラウド同期サービス
├── user/
│   └── database/
│       └── db_helper.dart        # SQLiteデータベースヘルパー
├── utils/                        # ユーティリティ
│   ├── exceptions.dart           # カスタム例外 & Result 型
│   ├── error_handler.dart        # エラーハンドリング
│   ├── lyric_parser.dart         # LRC/KRC歌詞パーサー
│   └── demo_data.dart            # デモデータ生成
└── widgets/                      # 再利用可能なウィジェット
    ├── loading_widget.dart       # ローディング状態
    └── empty_state_widget.dart   # 空状態
```

## 🎵 対応フォーマット

**音声フォーマット:** MP3、FLAC、WAV、AAC、M4A、OGG、WMA、APE

**歌詞フォーマット:** LRC（完全対応）、KRC（基本対応）

## 🔒 セキュリティ

- Android：ネットワークセキュリティポリシー、平文トラフィックはデフォルトで禁止
- iOS：App Transport Security 有効、HTTPS を強制
- データバックアップを明示的に無効化
- パラメータ化 SQL クエリでインジェクション対策

## 📜 ライセンス

このプロジェクトは **Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International（CC BY-NC-SA 4.0）** の下でライセンスされています。

[![CC BY-NC-SA 4.0](https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png)](https://creativecommons.org/licenses/by-nc-sa/4.0/)

### あなたは以下の権利を持ちます：
- **共有** — あらゆる媒体や形式で資料を複製・配布
- **翻案** — リミックス、変形、本資料を元にした創作

### 以下の条件に従ってください：
- **表示** — 適切なクレジットを表示してください
- **非営利** — 営利目的での使用はできません
- **継承** — 改変した場合、同じライセンスで配布してください

### 商用利用
**商用利用は固く禁じられています**。商用ライセンスについては、リポジトリ所有者にお問い合わせください。

## 🤝 コントリビューション

本プロジェクトは主に個人の学習用プロジェクトです。提案やバグ報告は Issues からお願いします。

## 🙏 謝辞

- [just_audio](https://pub.dev/packages/just_audio) - オーディオ再生エンジン
- [sqflite](https://pub.dev/packages/sqflite) - ローカルデータベース
- [Flutter](https://flutter.dev) - クロスプラットフォームフレームワーク