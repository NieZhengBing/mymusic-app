import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // 👈 新增

import 'AppLog.dart';
import 'providers/audio_provider.dart';
import 'providers/auth_provider.dart';
import 'services/sync_service.dart';
import 'screens/main_screen.dart';
import 'firebase_options.dart'; // 👈 新增

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLog.add('main() 开始执行');

  // 捕获 Flutter 框架错误
  FlutterError.onError = (details) {
    AppLog.add('Flutter错误: ${details.exception}');
    AppLog.add('堆栈: ${details.stack}');
  };

  runZonedGuarded(() async {

    AppLog.add('开始初始化 Firebase');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLog.add('Firebase 初始化成功');

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => AudioProvider()),
        ],
        child: const SyncProvider(
          child: MyApp(),
        ),
      ),
    );

    AppLog.add('runApp 执行完成');

  }, (error, stack) {
    AppLog.add('未捕获异常: $error');
    AppLog.add('堆栈: $stack');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '我的音乐',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const MainScreen(),
      // 👇 添加这个，摇一摇手机显示日志
    );
  }
}
