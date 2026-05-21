import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../AppLog.dart';
import '../models/app_user.dart';
import '../utils/exceptions.dart';
import '../utils/error_handler.dart';

// 认证Provider
// 管理用户登录、注册、登出等认证状态
class AuthProvider with ChangeNotifier {


  final FirebaseAuth _auth = FirebaseAuth.instance;
  AppUser? _currentUser;
  bool _isLoading = false;
  bool _initialized = false;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get initialized => _initialized;

  // 通用重试方法，最多重试 retryCount 次
  Future<T> _retry<T>(
      Future<T> Function() action, {
        int retryCount = 3,
        Duration delay = const Duration(seconds: 2),
      }) async {
    int attempt = 0;
    while (true) {
      try {
        attempt++;
        AppLog.add('第 $attempt 次尝试...');
        return await action();
      } catch (e) {
        AppLog.add('第 $attempt 次失败: $e');
        if (attempt >= retryCount) rethrow; // 超过次数直接抛出
        await Future.delayed(delay);        // 等待后重试
      }
    }
  }

  // 初始化Firebase
  Future<Result<bool>> initialize() async {
    try {
      if (_initialized) return Result.success(true);

      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'YOUR_API_KEY',
          appId: 'YOUR_APP_ID',
          messagingSenderId: 'YOUR_SENDER_ID',
          projectId: 'YOUR_PROJECT_ID',
        ),
      );

      // 检查是否有已登录用户
      final user = _auth.currentUser;
      if (user != null) {
        _currentUser = _fromFirebaseUser(user);
      }

      // 监听认证状态变化
      _auth.authStateChanges().listen((user) {
        if (user != null) {
          _currentUser = _fromFirebaseUser(user);
        } else {
          _currentUser = null;
        }
        notifyListeners();
      });

      _initialized = true;
      return Result.success(true);
    } catch (e) {
      return Result.failure(
        NetworkException('初始化认证失败: $e'),
      );
    }
  }

  // Firebase User 转换为 AppUser
  AppUser _fromFirebaseUser(User user) {
    return AppUser(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      avatarUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: user.metadata.lastSignInTime,
    );
  }

  Future<Result<bool>> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      AppLog.add('邮箱注册...');
      _isLoading = true;
      notifyListeners();

      // 👇 加超时 15秒
      final result = await _retry(
            () => _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ).timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw TimeoutException('注册请求超时'),
        ),
        retryCount: 3,       // 最多重试3次
        delay: const Duration(seconds: 2), // 每次间隔2秒
      );

      if (displayName != null && result.user != null) {
        await result.user!.updateDisplayName(displayName)
            .timeout(const Duration(seconds: 10));
      }

      _isLoading = false;
      notifyListeners();
      return Result.success(true);

    } on TimeoutException catch (e) {
      _isLoading = false;
      notifyListeners();
      AppLog.add('邮箱注册超时: $e');
      return Result.failure(NetworkException('请求超时，请重试'));

    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      AppLog.add('邮箱注册异常: $e');
      return Result.failure(NetworkException(_getAuthErrorMessage(e)));

    } catch (e) {
      _isLoading = false;
      notifyListeners();
      AppLog.add('邮箱注册异常: $e');
      return Result.failure(NetworkException('注册失败: $e'));
    }
  }

  // 邮箱登录
  Future<Result<bool>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return Result.success(true);
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return Result.failure(
        NetworkException(_getAuthErrorMessage(e)),
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return Result.failure(
        NetworkException('登录失败: $e'),
      );
    }
  }

  // 退出登录
  Future<Result<bool>> signOut() async {
    try {
      await _auth.signOut();
      _currentUser = null;
      notifyListeners();
      return Result.success(true);
    } catch (e) {
      return Result.failure(
        NetworkException('退出失败: $e'),
      );
    }
  }

  // 密码重置
  Future<Result<bool>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return Result.success(true);
    } on FirebaseAuthException catch (e) {
      return Result.failure(
        NetworkException(_getAuthErrorMessage(e)),
      );
    } catch (e) {
      return Result.failure(
        NetworkException('发送重置密码邮件失败: $e'),
      );
    }
  }

  // 获取认证错误信息
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return '未找到该用户';
      case 'wrong-password':
        return '密码错误';
      case 'email-already-in-use':
        return '该邮箱已被注册';
      case 'invalid-email':
        return '邮箱格式不正确';
      case 'weak-password':
        return '密码强度不够';
      case 'user-disabled':
        return '该账号已被禁用';
      case 'too-many-requests':
        return '请求过于频繁，请稍后重试';
      case 'operation-not-allowed':
        return '该操作不被允许';
      case 'network-request-failed':
        return '网络请求失败，请检查网络连接';
      default:
        return e.message ?? '认证失败';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// 登录页面
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isRegister = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_isRegister) {
      // logger.i('邮箱注册开始。。。');
      AppLog.add('邮箱注册开始。。。');
      final result = await authProvider.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : null,
      );

      if (!result.isSuccess && context.mounted) {
        ErrorHandler.showError(
          context,
          message: result.exception?.message ?? '注册失败',
        );
      }
    } else {
      final result = await authProvider.loginWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!result.isSuccess && context.mounted) {
        ErrorHandler.showError(
          context,
          message: result.exception?.message ?? '登录失败',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegister ? '注册' : '登录'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 标题和图标
                Icon(
                  Icons.music_note,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  '我的音乐',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isRegister ? '创建账号以同步数据' : '登录以同步你的音乐数据',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 48),

                // 注册时显示昵称输入框
                if (_isRegister) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '昵称（选填）',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 邮箱输入
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: '邮箱',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入邮箱';
                    }
                    if (!value.contains('@')) {
                      return '请输入有效的邮箱地址';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 密码输入
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: '密码',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入密码';
                    }
                    if (_isRegister && value.length < 6) {
                      return '密码至少6位';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // 忘记密码
                if (!_isRegister)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showResetPasswordDialog(),
                      child: const Text('忘记密码？'),
                    ),
                  ),
                const SizedBox(height: 24),

                // 登录/注册按钮
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _submit,
                    child: authProvider.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_isRegister ? '注册' : '登录'),
                  ),
                ),
                const SizedBox(height: 16),

                // 切换登录/注册
                TextButton(
                  onPressed: () {
                    setState(() => _isRegister = !_isRegister);
                  },
                  child: Text(
                    _isRegister ? '已有账号？去登录' : '没有账号？去注册',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showResetPasswordDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置密码'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            hintText: '输入注册邮箱',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                await authProvider.resetPassword(email);
                if (context.mounted) {
                  Navigator.pop(context);
                  ErrorHandler.showSuccess(
                    context,
                    message: '重置密码邮件已发送',
                  );
                }
              }
            },
            child: const Text('发送'),
          ),
        ],
      ),
    );
    emailController.dispose();
  }
}

// 用户中心页面
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('账户'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 32),

          // 用户头像和信息
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  authProvider.currentUser?.displayNameOrEmail ?? '未登录',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (authProvider.currentUser?.email != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      authProvider.currentUser!.email!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),

          // 设置项
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('云同步'),
            subtitle: Text(
              authProvider.isLoggedIn ? '已开启' : '未登录',
            ),
            onTap: () {
              if (!authProvider.isLoggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.cloud_download),
            title: const Text('管理同步数据'),
            subtitle: const Text('查看和管理云端数据'),
          ),
          const Divider(),

          // 退出登录
          if (authProvider.isLoggedIn)
            ListTile(
              leading: Icon(
                Icons.logout,
                color: theme.colorScheme.error,
              ),
              title: Text(
                '退出登录',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () async {
                final confirm = await ErrorHandler.showConfirmDialog(
                  context,
                  title: '退出登录',
                  content: '确定要退出登录吗？退出后不会删除本地数据。',
                  confirmText: '退出',
                );
                if (confirm == true) {
                  await authProvider.signOut();
                }
              },
            ),
        ],
      ),
    );
  }
}