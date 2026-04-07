/// Audio-related constants for PCM stream processing.
abstract class AudioConstants {
  /// Sample rate in Hz (32kHz).
  static const int sampleRate = 32000;

  /// Number of audio channels (1 = mono).
  static const int channels = 1;

  /// Bits per sample (16-bit).
  static const int bitsPerSample = 16;

  /// Recording sample rate (16kHz for voice).
  static const int recordingSampleRate = 16000;

  /// Audio frame duration in milliseconds (60ms).
  static const int audioFrameMs = 60;

  /// Default fade duration for audio interruption.
  static const Duration defaultFadeDuration = Duration(milliseconds: 200);
}
