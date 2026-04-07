import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:record/record.dart';

/// 录音服务 - 使用 record v6+ 实现实时音频录制
///
/// 音频格式: 16kHz, 16bit, mono PCM
/// 数据分帧: 每 60ms = 1920 bytes
class RecordingService extends GetxService {
  final AudioRecorder _recorder = AudioRecorder();

  final isRecording = false.obs;
  final lastError = Rxn<String>();

  StreamSubscription<Uint8List>? _audioStreamSubscription;

  static const int sampleRate = 16000;
  static const int channels = 1;
  static const int bitsPerSample = 16;
  static const int frameSize = 1920; // 60ms = 16000 * 2 * 0.06

  final List<int> _buffer = [];
  final _audioFrameController = StreamController<Uint8List>.broadcast();

  Stream<Uint8List> get audioFrameStream => _audioFrameController.stream;

  /// v6: 检查权限（不请求）
  Future<bool> checkPermission() async {
    return await _recorder.hasPermission(request: false);
  }

  /// v6: 请求权限
  Future<bool> requestPermission() async {
    return await _recorder.hasPermission();
  }

  /// 开始录音
  Future<bool> start() async {
    debugPrint('🎙️ RecordingService.start() 被调用');

    if (isRecording.value) {
      debugPrint('⚠️ 录音已经在进行中');
      return true;
    }

    // 检查当前权限状态
    bool hasPerm = await checkPermission();
    debugPrint('🔍 当前权限状态: $hasPerm');

    if (!hasPerm) {
      debugPrint('🔐 请求录音权限...');
      hasPerm = await requestPermission();
      debugPrint('🔐 权限请求结果: $hasPerm');

      if (!hasPerm) {
        lastError.value = '没有录音权限，请在系统设置中允许录音';
        debugPrint('❌ 录音权限被拒绝');
        return false;
      }
    }

    try {
      debugPrint('🎙️ 初始化录音...');
      lastError.value = null;
      _buffer.clear();

      const config = RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: sampleRate,
        numChannels: channels,
      );

      debugPrint('🎙️ 启动流式录音...');
      final stream = await _recorder.startStream(config);
      debugPrint('✅ 录音流已启动');

      _audioStreamSubscription = stream.listen(
        _onAudioData,
        onError: _onAudioError,
        onDone: _onAudioDone,
      );

      isRecording.value = true;
      debugPrint('✅ 录音已开始 (16kHz/16bit/mono)');
      return true;
    } catch (e, stackTrace) {
      lastError.value = '启动录音失败: $e';
      debugPrint('❌ 启动录音失败: $e');
      debugPrint('$stackTrace');
      isRecording.value = false;
      return false;
    }
  }

  /// 停止录音
  Future<void> stop() async {
    debugPrint('🛑 RecordingService.stop() 被调用');

    if (!isRecording.value) {
      debugPrint('⚠️ 录音未在进行中');
      return;
    }

    try {
      await _audioStreamSubscription?.cancel();
      _audioStreamSubscription = null;

      await _recorder.stop();
      _buffer.clear();

      isRecording.value = false;
      debugPrint('✅ 录音已停止');
    } catch (e) {
      debugPrint('⚠️ 停止录音时出错: $e');
    }
  }

  /// v6+: 取消录音
  Future<void> cancel() async {
    debugPrint('🛑 RecordingService.cancel() 被调用');

    if (!isRecording.value) return;

    try {
      await _audioStreamSubscription?.cancel();
      _audioStreamSubscription = null;

      await _recorder.cancel();
      _buffer.clear();
      isRecording.value = false;
      debugPrint('✅ 录音已取消');
    } catch (e) {
      debugPrint('⚠️ 取消录音时出错: $e');
    }
  }

  void _onAudioData(Uint8List data) {
    _buffer.addAll(data);

    while (_buffer.length >= frameSize) {
      final frame = Uint8List.fromList(_buffer.sublist(0, frameSize));
      _buffer.removeRange(0, frameSize);

      if (!_audioFrameController.isClosed) {
        _audioFrameController.add(frame);
      }
    }

    // 缓冲区溢出保护
    final maxBufferSize = frameSize * 2;
    if (_buffer.length > maxBufferSize) {
      debugPrint('⚠️ 缓冲区溢出，丢弃 ${_buffer.length - frameSize} bytes');
      _buffer.removeRange(0, _buffer.length - frameSize);
    }
  }

  void _onAudioError(Object error) {
    debugPrint('❌ 录音流错误: $error');
    lastError.value = '录音错误: $error';
    isRecording.value = false;
  }

  void _onAudioDone() {
    debugPrint('📝 录音流结束');
    isRecording.value = false;
  }

  @override
  void onClose() {
    _audioStreamSubscription?.cancel();
    _recorder.dispose();
    _audioFrameController.close();
    super.onClose();
  }
}
