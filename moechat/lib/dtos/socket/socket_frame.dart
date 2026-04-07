import 'dart:convert';
import 'dart:typed_data';

/// Frame type enumeration for socket communication.
enum FrameType {
  start,    // Interruption signal
  me,       // User message
  text,     // AI text response
  audio,    // TTS audio data
  complete, // Response completion
  unknown,  // Unknown frame type
}

/// Base class for all socket frames.
///
/// Uses sealed class pattern for type-safe frame handling.
abstract class SocketFrame {
  final FrameType type;

  const SocketFrame(this.type);
}

/// Frame indicating user started speaking (interrupt signal).
class StartFrame extends SocketFrame {
  const StartFrame() : super(FrameType.start);
}

/// Frame containing user message text (ASR result).
class MeFrame extends SocketFrame {
  final String text;

  const MeFrame(this.text) : super(FrameType.me);
}

/// Frame containing AI text response.
class TextFrame extends SocketFrame {
  final String text;

  const TextFrame(this.text) : super(FrameType.text);
}

/// Frame containing audio data (TTS output).
class AudioFrame extends SocketFrame {
  final Uint8List data;

  const AudioFrame(this.data) : super(FrameType.audio);
}

/// Frame indicating AI response is complete.
class CompleteFrame extends SocketFrame {
  const CompleteFrame() : super(FrameType.complete);
}

/// Frame of unknown type (parse error or unsupported).
class UnknownFrame extends SocketFrame {
  final Uint8List? rawData;

  const UnknownFrame({this.rawData}) : super(FrameType.unknown);
}

/// Parser for socket frames.
class SocketFrameParser {
  // Frame delimiter
  static const String _delimiter = '<|end|>';

  // Frame tags
  static const String _tagStart = '<|start|>';
  static const String _tagMe = '<|me|>';
  static const String _tagText = '<|text|>';
  static const String _tagAudio = '<|audio|>';
  static const String _tagComplete = '<|complete|>';

  /// Parses a raw frame bytes into a typed SocketFrame.
  static SocketFrame parse(Uint8List frameBytes) {
    // Check if it's an audio frame (binary data)
    final audioTagBytes = utf8.encode(_tagAudio);
    if (_startsWith(frameBytes, audioTagBytes)) {
      final audioData = frameBytes.sublist(audioTagBytes.length);
      return AudioFrame(audioData);
    }

    // Try to decode as UTF-8 text frame
    String frame;
    try {
      frame = utf8.decode(frameBytes);
    } catch (e) {
      return UnknownFrame(rawData: frameBytes);
    }

    // Parse text frames
    if (frame.startsWith(_tagStart)) {
      return const StartFrame();
    } else if (frame.startsWith(_tagMe)) {
      return MeFrame(frame.substring(_tagMe.length));
    } else if (frame.startsWith(_tagText)) {
      return TextFrame(frame.substring(_tagText.length));
    } else if (frame.startsWith(_tagComplete)) {
      return const CompleteFrame();
    }

    return UnknownFrame(rawData: frameBytes);
  }

  /// Checks if byte array starts with given prefix.
  static bool _startsWith(Uint8List data, List<int> prefix) {
    if (data.length < prefix.length) return false;
    for (int i = 0; i < prefix.length; i++) {
      if (data[i] != prefix[i]) return false;
    }
    return true;
  }

  /// Creates a text message frame.
  static Uint8List createTextFrame(String text) {
    final frame = '$_tagMe$text$_delimiter';
    return Uint8List.fromList(utf8.encode(frame));
  }

  /// Creates an audio frame.
  static Uint8List createAudioFrame(Uint8List audioData) {
    final header = utf8.encode(_tagAudio);
    final footer = utf8.encode(_delimiter);

    final frame = Uint8List(header.length + audioData.length + footer.length);
    frame.setRange(0, header.length, header);
    frame.setRange(header.length, header.length + audioData.length, audioData);
    frame.setRange(header.length + audioData.length, frame.length, footer);

    return frame;
  }
}
