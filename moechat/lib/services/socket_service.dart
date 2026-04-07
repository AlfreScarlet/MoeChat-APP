import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../core/constants/buffer_constants.dart';
import '../core/constants/delimiter_constants.dart';
import '../core/constants/timeout_constants.dart';
import '../core/errors/app_exception.dart';
import '../core/errors/error_handler.dart';
import 'recording_service.dart';

/// Socket 连接状态
enum SocketConnectionState { disconnected, connecting, connected, error }

/// 帧类型枚举
enum FrameType { start, me, text, audio, complete, unknown }

/// 解析后的帧
class SocketFrame {
  final FrameType type;
  final String? textPayload;
  final Uint8List? binaryPayload;

  SocketFrame({required this.type, this.textPayload, this.binaryPayload});
}

/// Socket 服务 - 管理 TCP 连接和帧协议
///
/// 协议格式：<|标签|>载荷<|end|>
class SocketService extends GetxService {
  // Use constants from DelimiterConstants
  static const String delimiter = DelimiterConstants.delimiter;
  static const String tagMe = DelimiterConstants.tagMe;
  static const String tagText = DelimiterConstants.tagText;
  static const String tagComplete = DelimiterConstants.tagComplete;
  static const String tagStart = DelimiterConstants.tagStart;
  static const String tagAudio = DelimiterConstants.tagAudio;

  // ========== 状态 ==========
  final connectionState = SocketConnectionState.disconnected.obs;
  final lastError = Rxn<String>();
  final isRecording = false.obs;

  // 录音静音控制：服务端回复期间暂停发送音频，避免回声循环
  bool _isMuted = false;

  Socket? _socket;
  final _frameController = StreamController<SocketFrame>.broadcast();

  // 使用 Uint8List 作为缓冲区处理二进制数据
  // 用偏移量避免频繁的头部删除操作
  List<int> _buffer = [];
  int _bufferOffset = 0;

  // 缓冲区安全上限，防止异常数据导致内存无限增长
  static const int _maxBufferSize = BufferConstants.maxBufferSize;

  // 断线重连
  String? _lastHost;
  int? _lastPort;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = BufferConstants.maxReconnectAttempts;
  static const Duration _baseReconnectDelay = BufferConstants.baseReconnectDelay;
  bool _intentionalDisconnect = false;

  /// 帧流，UI 层监听此流接收消息
  Stream<SocketFrame> get frameStream => _frameController.stream;

  bool get isConnected =>
      connectionState.value == SocketConnectionState.connected;

  // ========== Socket 连接管理 ==========

  /// 连接到 Socket 服务器
  Future<void> connect(String host, int port) async {
    if (isConnected ||
        connectionState.value == SocketConnectionState.connecting) {
      return;
    }

    _lastHost = host;
    _lastPort = port;
    _intentionalDisconnect = false;
    _cancelReconnect();
    connectionState.value = SocketConnectionState.connecting;
    lastError.value = null;

    try {
      _socket = await Socket.connect(
        host,
        port,
        timeout: TimeoutConstants.socketConnectionTimeout,
      );
      connectionState.value = SocketConnectionState.connected;
      _reconnectAttempts = 0;

      // 监听数据
      _socket!.listen(
        _onData,
        onError: (error) {
          lastError.value = error.toString();
          _handleUnexpectedDisconnect();
        },
        onDone: _handleUnexpectedDisconnect,
      );
    } catch (e) {
      connectionState.value = SocketConnectionState.error;
      lastError.value = e.toString();
      _scheduleReconnect();
    }
  }

  /// 处理非主动断开（触发重连）
  void _handleUnexpectedDisconnect() {
    final socket = _socket;
    _socket = null;
    _buffer.clear();
    _bufferOffset = 0;

    socket?.destroy();

    if (_intentionalDisconnect) {
      connectionState.value = SocketConnectionState.disconnected;
      return;
    }

    connectionState.value = SocketConnectionState.error;
    _scheduleReconnect();
  }

  /// 安排断线重连（指数退避）
  void _scheduleReconnect() {
    if (_intentionalDisconnect) return;
    if (_lastHost == null || _lastPort == null) return;
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      lastError.value = '重连失败，已达最大重试次数';
      connectionState.value = SocketConnectionState.error;
      return;
    }

    final delay = _baseReconnectDelay * (1 << _reconnectAttempts.clamp(0, 5));
    _reconnectAttempts++;

    _reconnectTimer = Timer(delay, () async {
      if (_intentionalDisconnect || isConnected) return;
      connectionState.value = SocketConnectionState.connecting;
      try {
        _socket = await Socket.connect(
          _lastHost!,
          _lastPort!,
          timeout: TimeoutConstants.socketConnectionTimeout,
        );
        connectionState.value = SocketConnectionState.connected;
        _reconnectAttempts = 0;

        _socket!.listen(
          _onData,
          onError: (error) {
            lastError.value = error.toString();
            _handleUnexpectedDisconnect();
          },
          onDone: _handleUnexpectedDisconnect,
        );
      } catch (e) {
        lastError.value = e.toString();
        connectionState.value = SocketConnectionState.error;
        _scheduleReconnect();
      }
    });
  }

  /// 取消重连定时器
  void _cancelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// 主动断开连接（不触发重连）
  void disconnect() {
    if (connectionState.value == SocketConnectionState.disconnected) return;
    _intentionalDisconnect = true;
    _cancelReconnect();

    final socket = _socket;
    _socket = null;
    connectionState.value = SocketConnectionState.disconnected;
    _buffer.clear();
    _bufferOffset = 0;
    socket?.destroy();
  }

  /// 发送文本消息（<|me|>帧）
  void sendText(String text) {
    if (!isConnected) return;
    final frame = '$tagMe$text$delimiter';
    try {
      _socket?.write(frame);
    } catch (e, st) {
      // Log error instead of silently ignoring
      ErrorHandler.handle(
        SocketConnectionException.writeFailed(e),
        context: 'sendText',
        stackTrace: st,
      );
    }
  }

  // ========== 音频录制和发送（实时流式） ==========

  // 录音服务引用
  RecordingService? _recordingService;
  StreamSubscription<Uint8List>? _audioFrameSubscription;

  /// 开始电话模式（启动录音）
  Future<bool> startAudioStream() async {
    debugPrint('🎙️ SocketService.startAudioStream() 被调用');

    if (!isConnected) {
      lastError.value = 'Socket 未连接';
      debugPrint('❌ 无法启动录音: Socket 未连接');
      return false;
    }

    // 懒加载 RecordingService
    _recordingService ??= Get.find<RecordingService>();

    // 检查是否已经在录音
    if (_recordingService!.isRecording.value) {
      debugPrint('⚠️ 录音已经在进行中');
      isRecording.value = true;
      return true;
    }

    try {
      // 启动录音
      debugPrint('🎙️ 调用 RecordingService.start()...');
      final success = await _recordingService!.start();
      if (!success) {
        lastError.value = _recordingService!.lastError.value ?? '启动录音失败';
        debugPrint('❌ 录音启动失败: ${lastError.value}');
        return false;
      }

      // 订阅音频帧流
      debugPrint('🎙️ 订阅音频帧流...');
      _audioFrameSubscription = _recordingService!.audioFrameStream.listen(
        _sendAudioFrame,
        onError: (error) {
          debugPrint('❌ 音频帧流错误: $error');
          lastError.value = '录音错误: $error';
          _cleanupAudioStream();
        },
        onDone: () {
          debugPrint('📝 音频帧流结束');
          _cleanupAudioStream();
        },
      );

      isRecording.value = true;
      _isMuted = false;
      debugPrint('✅ 电话模式已启动');
      return true;
    } catch (e, stackTrace) {
      lastError.value = '启动电话模式失败: $e';
      debugPrint('❌ 启动电话模式失败: $e');
      debugPrint('$stackTrace');
      return false;
    }
  }

  /// 停止电话模式（停止录音）
  Future<void> stopAudioStream() async {
    debugPrint('🛑 SocketService.stopAudioStream() 被调用');

    if (_recordingService == null || !_recordingService!.isRecording.value) {
      debugPrint('⚠️ 录音未在进行中');
      return;
    }

    debugPrint('🛑 停止电话模式...');

    // 取消音频帧订阅
    await _audioFrameSubscription?.cancel();
    _audioFrameSubscription = null;

    // 停止录音
    await _recordingService!.stop();

    _cleanupAudioStream();
    debugPrint('✅ 电话模式已停止');
  }

  /// 清理音频流状态
  void _cleanupAudioStream() {
    isRecording.value = false;
    _isMuted = false;
  }

  /// 发送音频帧
  ///
  /// [frameData] 60ms音频帧 (1920 bytes), 16kHz/16bit/mono
  void _sendAudioFrame(Uint8List frameData) {
    if (!isConnected || frameData.isEmpty || _isMuted) return;

    // 发送音频帧: <|audio|>{audio_data}<|end|>
    final header = utf8.encode(tagAudio);
    final footer = utf8.encode(delimiter);

    final frame = Uint8List(header.length + frameData.length + footer.length);
    frame.setRange(0, header.length, header);
    frame.setRange(header.length, header.length + frameData.length, frameData);
    frame.setRange(header.length + frameData.length, frame.length, footer);

    try {
      _socket?.add(frame);
    } catch (e, st) {
      // Log error instead of silently ignoring
      ErrorHandler.handle(
        SocketConnectionException.writeFailed(e),
        context: '_sendAudioFrame',
        stackTrace: st,
      );
    }
  }

  /// 发送单帧音频数据（用于测试或外部音频源）
  void sendAudioFrame(Uint8List pcmData) {
    if (!isConnected) return;
    _sendAudioFrame(pcmData);
  }

  /// 静音：暂停发送录音数据（服务端回复期间调用）
  void muteAudioStream() {
    _isMuted = true;
  }

  /// 取消静音：恢复发送录音数据（服务端回复结束后调用）
  void unmuteAudioStream() {
    _isMuted = false;
  }

  // ========== 数据接收处理 ==========

  /// 数据接收处理（处理粘包）
  void _onData(Uint8List data) {
    _buffer.addAll(data);

    // 安全检查：缓冲区超过上限说明协议异常，丢弃避免内存爆炸
    if (_buffer.length > _maxBufferSize) {
      _buffer.clear();
      _bufferOffset = 0;
      return;
    }

    final delimiterBytes = utf8.encode(delimiter);

    while (true) {
      // 从 _bufferOffset 开始搜索分隔符
      final idx = _findDelimiter(_buffer, delimiterBytes, _bufferOffset);
      if (idx == -1) break;

      // 提取完整帧
      final frameBytes = Uint8List.fromList(
        _buffer.sublist(_bufferOffset, idx),
      );
      _bufferOffset = idx + delimiterBytes.length;

      if (frameBytes.isNotEmpty) {
        _dispatchFrame(frameBytes);
      }
    }

    // 压缩缓冲区，避免无限增长
    if (_bufferOffset > 0) {
      _buffer = _buffer.sublist(_bufferOffset);
      _bufferOffset = 0;
    }
  }

  /// 在字节数组中查找分隔符位置（从 start 开始搜索）
  int _findDelimiter(List<int> buffer, List<int> delimiter, int start) {
    for (int i = start; i <= buffer.length - delimiter.length; i++) {
      bool found = true;
      for (int j = 0; j < delimiter.length; j++) {
        if (buffer[i + j] != delimiter[j]) {
          found = false;
          break;
        }
      }
      if (found) return i;
    }
    return -1;
  }

  /// 帧分发
  void _dispatchFrame(Uint8List frameBytes) {
    // 检查是否是音频帧（以 <|audio|> 开头）
    final audioTagBytes = utf8.encode(tagAudio);
    final isAudioFrame = _startsWith(frameBytes, audioTagBytes);

    if (isAudioFrame) {
      // 音频帧：提取二进制数据
      final audioData = frameBytes.sublist(audioTagBytes.length);
      _frameController.add(
        SocketFrame(type: FrameType.audio, binaryPayload: audioData),
      );
      return;
    }

    // 其他帧：尝试用 UTF-8 解码
    String frame;
    try {
      frame = utf8.decode(frameBytes);
    } catch (e) {
      // 解码失败，忽略此帧
      return;
    }

    FrameType type = FrameType.unknown;
    String? textPayload;

    if (frame.startsWith(tagStart)) {
      type = FrameType.start;
    } else if (frame.startsWith(tagMe)) {
      type = FrameType.me;
      textPayload = frame.substring(tagMe.length);
    } else if (frame.startsWith(tagText)) {
      type = FrameType.text;
      textPayload = frame.substring(tagText.length);
    } else if (frame.startsWith(tagComplete)) {
      type = FrameType.complete;
    }

    _frameController.add(SocketFrame(type: type, textPayload: textPayload));
  }

  /// 检查字节数组是否以指定前缀开头
  bool _startsWith(Uint8List data, List<int> prefix) {
    if (data.length < prefix.length) return false;
    for (int i = 0; i < prefix.length; i++) {
      if (data[i] != prefix[i]) return false;
    }
    return true;
  }

  @override
  void onClose() {
    _intentionalDisconnect = true;
    _cancelReconnect();
    disconnect();

    // 关闭帧控制器
    _frameController.close();

    super.onClose();
  }
}
