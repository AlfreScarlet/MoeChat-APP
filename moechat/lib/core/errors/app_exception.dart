/// Base class for all application exceptions.
abstract class AppException implements Exception {
  /// Human-readable error message.
  final String message;

  /// Optional error code for programmatic handling.
  final String? code;

  /// Original error that caused this exception.
  final dynamic originalError;

  /// Stack trace at the point where the exception was thrown.
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception for network-related errors.
class NetworkException extends AppException {
  // ignore: use_super_parameters
  const NetworkException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code ?? 'NETWORK_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  factory NetworkException.timeout(String operation) => NetworkException(
        '$operation 超时，请检查网络连接',
        code: 'TIMEOUT',
      );

  factory NetworkException.connectionFailed(String operation) =>
      NetworkException(
        '$operation 连接失败，请检查服务器地址',
        code: 'CONNECTION_FAILED',
      );
}

/// Exception for socket-related errors.
class SocketConnectionException extends AppException {
  // ignore: use_super_parameters
  const SocketConnectionException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code ?? 'SOCKET_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  factory SocketConnectionException.notConnected() =>
      const SocketConnectionException(
        'Socket 未连接',
        code: 'NOT_CONNECTED',
      );

  factory SocketConnectionException.writeFailed(dynamic error) =>
      SocketConnectionException(
        '发送数据失败: $error',
        code: 'WRITE_FAILED',
        originalError: error,
      );
}

/// Exception for API-related errors.
class ApiException extends AppException {
  /// HTTP status code if available.
  final int? statusCode;

  // ignore: use_super_parameters
  const ApiException(
    String message, {
    this.statusCode,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code ?? 'API_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  factory ApiException.serverError(int statusCode) => ApiException(
        '服务器错误: $statusCode',
        statusCode: statusCode,
        code: 'SERVER_ERROR',
      );

  factory ApiException.notInitialized() => const ApiException(
        'API 服务未初始化',
        code: 'NOT_INITIALIZED',
      );

  factory ApiException.invalidResponse(String reason) => ApiException(
        '无效的响应: $reason',
        code: 'INVALID_RESPONSE',
      );
}

/// Exception for validation errors.
class ValidationException extends AppException {
  // ignore: use_super_parameters
  const ValidationException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code ?? 'VALIDATION_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  factory ValidationException.requiredField(String field) =>
      ValidationException('必填字段不能为空: $field');

  factory ValidationException.invalidFormat(String field, String expected) =>
      ValidationException('$field 格式无效，期望: $expected');
}

/// Exception for audio-related errors.
class AudioException extends AppException {
  // ignore: use_super_parameters
  const AudioException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code ?? 'AUDIO_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  factory AudioException.notInitialized() => const AudioException(
        '音频引擎未初始化',
        code: 'NOT_INITIALIZED',
      );

  factory AudioException.playbackFailed(dynamic error) => AudioException(
        '播放失败: $error',
        code: 'PLAYBACK_FAILED',
        originalError: error,
      );
}
