/// Socket frame delimiter and tag constants.
abstract class DelimiterConstants {
  /// Frame delimiter string.
  static const String delimiter = '<|end|>';

  /// Tag for user messages.
  static const String tagMe = '<|me|>';

  /// Tag for text frames.
  static const String tagText = '<|text|>';

  /// Tag for completion frames.
  static const String tagComplete = '<|complete|>';

  /// Tag for start/interrupt frames.
  static const String tagStart = '<|start|>';

  /// Tag for audio frames.
  static const String tagAudio = '<|audio|>';
}
