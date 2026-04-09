import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:get/get.dart';

import '../core/constants/audio_constants.dart';

/// 音频播放器状态
enum AudioPlayerState { idle, playing, paused, stopped, error }

/// 音频服务 - 使用 flutter_soloud 实现流式播放和实时打断
///
/// 音频格式: 32kHz, 16bit, mono PCM
///
/// 特点:
/// - 应用启动时初始化，全局常驻
/// - 实时流式播放，无需等待完整音频
/// - 即时打断，低延迟响应
/// - 每次会话创建新的 AudioSource，避免 StreamEnded 错误
class AudioService extends GetxService {
  // SoLoud 引擎
  SoLoud? _soloud;

  // 音频流源和播放句柄（每个会话独立）
  AudioSource? _audioSource;
  SoundHandle? _soundHandle;

  // 播放状态
  final playerState = AudioPlayerState.idle.obs;
  final isPlaying = false.obs;

  // 会话管理
  int _currentSessionId = 0;
  bool _isInSession = false;

  // 音频参数 (与后端 TTS 保持一致)
  static const int sampleRate = AudioConstants.sampleRate;
  static const int channels = AudioConstants.channels;
  static const int bitsPerSample = AudioConstants.bitsPerSample;

  /// 初始化音频服务
  ///
  /// 在应用启动时调用，只初始化 SoLoud 引擎
  /// AudioSource 在 startPlayback() 时动态创建
  Future<AudioService> init() async {
    try {
      debugPrint('🎵 初始化音频服务...');

      _soloud = SoLoud.instance;
      await _soloud!.init();

      debugPrint('✅ 音频服务初始化完成');
    } catch (e, stackTrace) {
      debugPrint('❌ 音频服务初始化失败: $e');
      debugPrint('$stackTrace');
      playerState.value = AudioPlayerState.error;
    }

    return this;
  }

  /// 开始新的音频播放会话
  ///
  /// 调用此方法表示开始接收新的音频流，会:
  /// 1. 打断/清理之前的播放
  /// 2. 创建新的 AudioSource（关键：避免复用已结束的流）
  void startPlayback() {
    // 清理之前的资源
    _cleanupCurrentSession();

    if (_soloud == null) {
      debugPrint('❌ 音频引擎未初始化');
      return;
    }

    try {
      // 创建新的音频流（每次会话独立，避免 StreamEnded 错误）
      _audioSource = _soloud!.setBufferStream(
        sampleRate: sampleRate,
        channels: Channels.mono,
        format: BufferType.s16le, // 16-bit signed little-endian PCM
        bufferingType: BufferingType.preserved,
        bufferingTimeNeeds: 0.05, // 50ms 低延迟缓冲，实现实时播放
        maxBufferSizeBytes: 1024 * 1024 * 10, // 10MB 缓冲区上限
        onBuffering: (isBuffering, handle, time) {
          debugPrint('Buffering: $isBuffering, handle: $handle, time: $time');
        },
      );

      // 开始新会话
      _isInSession = true;
      _currentSessionId++;

      debugPrint('🎵 开始音频会话 #$_currentSessionId，创建新 AudioSource');
    } catch (e, stackTrace) {
      debugPrint('❌ 创建音频流失败: $e');
      debugPrint('$stackTrace');
      playerState.value = AudioPlayerState.error;
    }
  }

  /// 清理当前会话资源
  void _cleanupCurrentSession() {
    if (_soloud == null) return;

    try {
      // 停止播放
      if (_soundHandle != null && !_soundHandle!.isError) {
        _soloud!.stop(_soundHandle!);
        _soundHandle = null;
      }

      // 释放旧的 AudioSource（关键：每次会话后必须释放）
      if (_audioSource != null) {
        _soloud!.disposeSource(_audioSource!);
        _audioSource = null;
        debugPrint('🧹 释放旧 AudioSource');
      }
    } catch (e) {
      debugPrint('⚠️ 清理资源时出错: $e');
    }

    _isInSession = false;
    isPlaying.value = false;
  }

  /// 添加音频数据到播放流
  ///
  /// 音频数据会立即推送到 SoLoud 进行播放，无需等待完整音频
  /// 注意：音频流应已通过 [startPlayback] 提前创建，以实现低延迟播放
  ///
  /// [audioData] - 16bit PCM 音频数据
  void enqueueAudio(Uint8List audioData) {
    if (audioData.isEmpty) return;
    if (_soloud == null) {
      debugPrint('⚠️ 音频引擎未初始化，忽略音频数据');
      return;
    }
    // 兜底保护：如果未提前创建会话，自动创建（但会有延迟）
    if (!_isInSession || _audioSource == null) {
      debugPrint('⚠️ 未提前创建音频会话，自动调用 startPlayback()');
      startPlayback();
    }

    _enqueueAudioInternal(audioData);
  }

  void _enqueueAudioInternal(Uint8List audioData) {
    try {
      // 首次数据到达时启动播放
      if (!isPlaying.value) {
        _soundHandle = _soloud!.play(
          _audioSource!,
          paused: false,
        );
        isPlaying.value = true;
        playerState.value = AudioPlayerState.playing;
        debugPrint('▶️ 开始播放');
      }

      // 推送数据到 SoLoud 流
      _soloud!.addAudioDataStream(_audioSource!, audioData);

      debugPrint('📤 推送音频: ${audioData.length} 字节');
    } on SoLoudStreamEndedAlreadyCppException catch (e) {
      debugPrint('⚠️ 音频流已结束，尝试重新创建会话: $e');
      // 自动恢复：重新创建会话并重试
      startPlayback();
      // 重试一次
      if (_audioSource != null) {
        _soundHandle = _soloud!.play(_audioSource!, paused: false);
        isPlaying.value = true;
        playerState.value = AudioPlayerState.playing;
        _soloud!.addAudioDataStream(_audioSource!, audioData);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ 音频推送错误: $e');
      debugPrint('$stackTrace');
      playerState.value = AudioPlayerState.error;
    }
  }

  /// 完成当前播放会话
  ///
  /// 标记当前会话结束，音频会继续播放直到缓冲区耗尽
  /// 注意：不清理资源，让音频自然播放完成；资源在 startPlayback() 或 interrupt() 时清理
  Future<void> finishPlayback() async {
    if (_audioSource == null || _soloud == null) return;

    _isInSession = false;

    try {
      // 标记数据流结束（让 SoLoud 知道没有更多数据了）
      _soloud!.setDataIsEnded(_audioSource!);
      debugPrint('✅ 音频会话 #$_currentSessionId 完成，等待自然播放结束');
      
      // 不清理资源！音频会继续播放直到缓冲区耗尽
      // 资源在下次 startPlayback() 或 interrupt() 时清理
    } catch (e) {
      debugPrint('⚠️ 标记音频结束失败: $e');
    }
  }

  // 标记是否正在淡出中，用于处理连续打断
  bool _isFadingOut = false;

  /// 打断当前播放（带淡出效果）
  ///
  /// 音频会淡出后停止，用户体验更自然
  /// 如果在淡出过程中再次调用，会立即停止并清理资源
  ///
  /// [fadeDuration] - 淡出时长，默认 200ms
  void interrupt({Duration fadeDuration = AudioConstants.defaultFadeDuration}) {
    if (_soloud == null) return;
    if (!_isInSession && !isPlaying.value && !_isFadingOut) return;

    // 如果正在淡出中，立即清理资源（连续打断）
    if (_isFadingOut) {
      debugPrint('⏹️ 连续打断，立即停止播放');
      _cleanupCurrentSession();
      _isFadingOut = false;
      playerState.value = AudioPlayerState.stopped;
      _currentSessionId++;
      return;
    }

    debugPrint('⏹️ 打断音频播放（淡出 ${fadeDuration.inMilliseconds}ms）');

    try {
      // 如果有正在播放的声音，先淡出
      if (_soundHandle != null && !_soundHandle!.isError) {
        _isFadingOut = true;
        _isInSession = false;

        // 从当前音量淡出到 0
        _soloud!.fadeVolume(_soundHandle!, 0.0, fadeDuration);

        // 延迟后真正停止并清理
        Future.delayed(fadeDuration, () {
          if (_isFadingOut) {
            // 只停止当前这个 handle，不 dispose AudioSource
            // 让音频自然结束，资源在 startPlayback() 时再清理
            try {
              _soloud!.stop(_soundHandle!);
            } catch (_) {}
            _soundHandle = null;
            _isFadingOut = false;
            isPlaying.value = false;
            debugPrint('✅ 淡出完成，播放已停止');
          }
        });
      } else {
        // 没有播放中的声音，直接清理
        _cleanupCurrentSession();
      }

      playerState.value = AudioPlayerState.stopped;
      _currentSessionId++;

      debugPrint('✅ 播放已打断');
    } catch (e, stackTrace) {
      debugPrint('❌ 打断播放错误: $e');
      debugPrint('$stackTrace');
      _isFadingOut = false;
    }
  }

  /// 检查音频服务是否已初始化
  bool get isInitialized => _soloud?.isInitialized ?? false;

  @override
  void onClose() {
    _cleanupCurrentSession();
    
    // 清理引擎
    try {
      _soloud?.deinit();
      debugPrint('🧹 音频服务已清理');
    } catch (e) {
      debugPrint('⚠️ 清理音频服务时出错: $e');
    }
    super.onClose();
  }
}
