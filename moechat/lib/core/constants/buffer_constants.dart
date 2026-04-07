/// Buffer-related constants for socket and data handling.
abstract class BufferConstants {
  /// Maximum buffer size (1MB) to prevent memory overflow from malformed data.
  static const int maxBufferSize = 1024 * 1024;

  /// Maximum reconnection attempts.
  static const int maxReconnectAttempts = 10;

  /// Base delay between reconnection attempts.
  static const Duration baseReconnectDelay = Duration(seconds: 2);
}
