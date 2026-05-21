// 自定义异常类

// 基础异常
class AppException implements Exception {
  final String message;
  final int? code;

  AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

// 文件扫描异常
class FileScanException extends AppException {
  FileScanException(String message, {int? code}) : super(message, code: code);
}

// 数据库异常
class DatabaseException extends AppException {
  DatabaseException(String message, {int? code}) : super(message, code: code);
}

// 音频播放异常
class AudioException extends AppException {
  AudioException(String message, {int? code}) : super(message, code: code);
}

// 权限异常
class PermissionException extends AppException {
  PermissionException(String message, {int? code}) : super(message, code: code);
}

// 网络异常
class NetworkException extends AppException {
  NetworkException(String message, {int? code}) : super(message, code: code);
}

// 验证异常
class ValidationException extends AppException {
  ValidationException(String message, {int? code}) : super(message, code: code);
}

// 结果封装类
class Result<T> {
  final T? data;
  final AppException? exception;
  final bool isSuccess;

  Result.success(this.data)
    : exception = null,
      isSuccess = true;

  Result.failure(this.exception)
    : data = null,
      isSuccess = false;

  // 静态工厂方法
  static Result<T> successWithData<T>(T data) => Result.success(data);
  static Result<T> failureWithException<T>(AppException exception) => Result.failure(exception);
  static Result<T> failureWithMessage<T>(String message) => Result.failure(AppException(message));

  // 快捷判断
  bool get hasData => data != null;
  bool get hasException => exception != null;

  @override
  String toString() {
    if (isSuccess) {
      return 'Result{success: true, data: $data}';
    } else {
      return 'Result{success: false, exception: $exception}';
    }
  }
}

// 扩展方法
extension ResultExtension<T> on Result<T> {
  // 处理成功情况
  Result<R> map<R>(R Function(T) transform) {
    if (isSuccess && data != null) {
      return Result.success(transform(data!));
    }
    return Result.failure(exception);
  }

  // 处理错误情况
  Result<T> onError(Result<T> Function(AppException) handler) {
    if (!isSuccess && exception != null) {
      return handler(exception!);
    }
    return this;
  }

  // 清理资源
  void dispose() {
    if (data is Disposable) {
      (data as Disposable).dispose();
    }
  }
}

// 可清理资源接口
abstract class Disposable {
  void dispose();
}
