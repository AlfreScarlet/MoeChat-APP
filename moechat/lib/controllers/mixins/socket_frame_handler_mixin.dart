import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../models/assistant.dart';
import '../../services/audio_service.dart';
import '../../services/socket_service.dart';

/// Socket 帧处理 mixin
///
/// 提取自 HomeController，负责监听和处理 Socket 帧消息，
/// 包括文本流式追加、音频播放、打断信号、ASR 识别结果等。
mixin SocketFrameHandlerMixin on GetxController {
  // ==================== 依赖（由 HomeController 实现） ====================

  SocketService get socketService;
  AudioService get audioService;
  RxList<ChatMessage> get messages;
  Rxn<ChatMessage> get currentAiMessage;
  RxBool get isSending;
  RxBool get isReceivingResponse;
  RxBool get isCallActive;

  // ==================== 内部状态 ====================

  /// Socket 帧订阅
  StreamSubscription<SocketFrame>? frameSubscription;

  /// 音频延迟计时（记录发送请求到收到第一段音频的延迟）
  DateTime? requestSentTime;
  bool isFirstAudioFrame = false;

  // ==================== Socket 消息处理 ====================

  /// 监听 Socket 帧
  void listenToSocketFrames() {
    frameSubscription = socketService.frameStream.listen((frame) {
      switch (frame.type) {
        case FrameType.start:
          // 打断信号 - 用户开始说话
          handleStartFrame();
          break;
        case FrameType.text:
          handleTextFrame(frame.textPayload ?? '');
          break;
        case FrameType.audio:
          // P1: 播放 TTS 音频
          handleAudioFrame(frame.binaryPayload);
          break;
        case FrameType.complete:
          handleCompleteFrame();
          break;
        case FrameType.me:
          // ASR 识别结果，显示为用户消息（语音输入时）
          handleAsrResult(frame.textPayload ?? '');
          break;
        case FrameType.unknown:
          break;
      }
    });
  }

  /// 处理打断帧（<|start|>）
  void handleStartFrame() {
    debugPrint('收到打断信号');

    // 立即打断音频播放
    audioService.interrupt();

    // 用户开始说话，恢复录音发送
    if (isCallActive.value) {
      socketService.unmuteAudioStream();
    }

    // 清空未完成的 AI 消息
    if (currentAiMessage.value != null) {
      // 移除正在输入的消息
      messages.removeWhere((m) => m.isTyping && m.sender == MessageSender.bot);
      currentAiMessage.value = null;
    }

    isReceivingResponse.value = false;
  }

  /// 处理文本帧（流式追加）
  void handleTextFrame(String text) {
    // 收到回复，静音录音避免回声
    if (isCallActive.value) {
      socketService.muteAudioStream();
    }

    if (currentAiMessage.value == null) {
      // 创建新的 AI 消息（不在这里启动音频播放，等收到音频帧再启动）
      currentAiMessage.value = ChatMessage(
        sender: MessageSender.bot,
        content: text,
        isTyping: true,
        timestamp: DateTime.now(),
      );
      messages.add(currentAiMessage.value!);
    } else {
      // 追加到当前消息
      currentAiMessage.value = currentAiMessage.value!.copyWith(
        content: currentAiMessage.value!.content + text,
      );
      // 更新列表中对应消息
      final index = messages.indexWhere(
        (m) => m.sender == MessageSender.bot && m.isTyping,
      );
      if (index != -1) {
        messages[index] = currentAiMessage.value!;
      }
    }
  }

  /// 处理音频帧
  void handleAudioFrame(Uint8List? audioData) {
    if (audioData == null || audioData.isEmpty) return;

    // 计算并输出第一段音频的延迟和具体时间
    if (isFirstAudioFrame && requestSentTime != null) {
      final receiveTime = DateTime.now();
      final latency = receiveTime.difference(requestSentTime!);
      final reqTimeStr = requestSentTime!.toIso8601String();
      final recvTimeStr = receiveTime.toIso8601String();
      debugPrint(
        '⏱️ 音频延迟: ${latency.inMilliseconds} ms | 请求时间: $reqTimeStr | 收到时间: $recvTimeStr',
      );
      isFirstAudioFrame = false;
    }

    audioService.enqueueAudio(audioData);
  }

  /// 处理完成帧
  void handleCompleteFrame() {
    completeCurrentResponse();

    // 标记音频播放完成
    audioService.finishPlayback();

    // 回复结束，恢复录音发送
    if (isCallActive.value) {
      socketService.unmuteAudioStream();
    }
  }

  /// 处理ASR识别结果（语音输入）
  void handleAsrResult(String text) {
    if (text.trim().isEmpty) return;

    // 添加用户消息到列表
    messages.add(
      ChatMessage(
        sender: MessageSender.user,
        content: text.trim(),
        timestamp: DateTime.now(),
      ),
    );

    isSending.value = true;
    isReceivingResponse.value = true;

    // 记录请求发送时间（语音输入通过ASR发起），用于计算音频延迟
    requestSentTime = DateTime.now();
    isFirstAudioFrame = true;

    // 提前创建音频流，准备接收AI回复的音频
    audioService.startPlayback();
  }

  /// 完成当前回复
  void completeCurrentResponse() {
    if (currentAiMessage.value != null) {
      currentAiMessage.value = currentAiMessage.value!.copyWith(
        isTyping: false,
      );
      final index = messages.indexWhere(
        (m) => m.sender == MessageSender.bot && m.isTyping,
      );
      if (index != -1) {
        messages[index] = currentAiMessage.value!;
      }
      currentAiMessage.value = null;
    }
    isSending.value = false;
    isReceivingResponse.value = false;
  }
}
