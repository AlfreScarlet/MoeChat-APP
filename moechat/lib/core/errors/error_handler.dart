import 'dart:developer' as developer;

import 'app_exception.dart';

/// Centralized error handler for the application.
///
/// Provides consistent error handling, logging, and user-friendly messages.
class ErrorHandler {
  ErrorHandler._();

  /// Handles an error and returns an appropriate AppException.
  static AppException handle(
    dynamic error, {
    String? context,
    StackTrace? stackTrace,
    bool shouldLog = true,
  }) {
    final exception = _convertToAppException(error, context);

    if (shouldLog) {
      _logError(exception, stackTrace);
    }

    return exception;
  }

  /// Converts various error types to AppException.
  static AppException _convertToAppException(dynamic error, String? context) {
    // Already an AppException
    if (error is AppException) {
      return error;
    }

    // Generic exception
    final prefix = context != null ? '[$context] ' : '';
    return ApiException(
      '$prefix${error.toString()}',
      originalError: error,
    );
  }

  /// Logs the error with appropriate level.
  static void _logError(AppException exception, StackTrace? stackTrace) {
    final buffer = StringBuffer()
      ..writeln('╔══════════════════════════════════════')
      ..writeln('║ ❌ ERROR: ${exception.runtimeType}')
      ..writeln('║ Message: ${exception.message}')
      ..writeln('║ Code: ${exception.code ?? "N/A"}');

    if (exception.originalError != null) {
      buffer.writeln('║ Original: ${exception.originalError}');
    }

    buffer.writeln('╚══════════════════════════════════════');

    developer.log(
      buffer.toString(),
      name: 'ErrorHandler',
      error: exception.originalError,
      stackTrace: stackTrace,
    );
  }

  /// Gets a user-friendly error message.
  static String getUserMessage(AppException exception) {
    return exception.message;
  }

  /// Checks if the error is retryable.
  static bool isRetryable(AppException exception) {
    return exception is NetworkException ||
        exception is SocketConnectionException;
  }
}
