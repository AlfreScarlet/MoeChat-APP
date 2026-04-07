/// Timeout-related constants for network operations.
abstract class TimeoutConstants {
  /// Connection timeout duration.
  static const Duration connectTimeout = Duration(seconds: 30);

  /// Receive timeout duration.
  static const Duration receiveTimeout = Duration(seconds: 60);

  /// Send timeout duration.
  static const Duration sendTimeout = Duration(seconds: 30);

  /// Socket connection timeout.
  static const Duration socketConnectionTimeout = Duration(seconds: 5);
}
