import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/assistant.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../services/socket_service.dart';
import '../services/loading_service.dart';
import '../services/chat_storage_service.dart';
import '../widgets/modals/edit_assistant_modal.dart';
import '../widgets/modals/settings_modal.dart';
import 'mixins/mixins.dart';

/// Centralized application state controller.
class HomeController extends GetxController
    with SocketFrameHandlerMixin, AssetManagementMixin, AssistantCrudMixin {
  // ==================== 服务引用（供 mixin 访问） ====================

  @override
  final apiService = Get.find<ApiService>();
  @override
  final socketService = Get.find<SocketService>();
  @override
  final audioService = Get.find<AudioService>();
  final _chatStorage = Get.find<ChatStorageService>();

  // ==================== 共享响应式状态 ====================

  @override
  final assistants = <Assistant>[].obs;
  @override
  final selectedAssistantIndex = 0.obs;
  @override
  final isLoadingAssistants = false.obs;
  @override
  final assistantsError = Rxn<String>();

  // UI 状态
  final isDetailPanelOpen = true.obs;
  @override
  final isCallActive = false.obs;
  final isSidebarCollapsed = false.obs;

  // 输入框焦点状态（用于移动端键盘弹出时滚动消息列表）
  final isInputFocused = false.obs;

  // 通话时长状态
  final callDuration = 0.obs; // 通话时长（秒）
  Timer? _callDurationTimer;

  // 消息状态
  @override
  final messages = <ChatMessage>[].obs;
  @override
  final isSending = false.obs;
  @override
  final currentAiMessage = Rxn<ChatMessage>();

  // 是否正在接收 AI 回复（用于打断判断）
  @override
  final isReceivingResponse = false.obs;

  // Socket 状态监听
  Worker? _socketStateWorker;

  // 计算属性
  @override
  Assistant? get currentAssistant {
    if (assistants.isEmpty) return null;
    final index = selectedAssistantIndex.value;
    if (index < 0 || index >= assistants.length) return null;
    return assistants[index];
  }

  // 存储监听 Worker
  Worker? _messagesWorker;
  Worker? _assistantWorker;

  @override
  void onInit() {
    super.onInit();
    listenToSocketFrames();
    _listenToSocketState();
    _setupStorageListeners();
    debugPrint('✅ HomeController 初始化完成');
  }

  /// 设置存储监听
  void _setupStorageListeners() {
    // 监听消息列表变化，自动保存到本地
    _messagesWorker = ever(messages, (_) => _saveCurrentMessages());

    // 监听当前助手变化，加载对应聊天记录
    _assistantWorker = ever(selectedAssistantIndex, (_) {
      _loadMessagesForCurrentAssistant();
    });
  }

  /// 保存当前助手的聊天记录
  void _saveCurrentMessages() {
    final assistant = currentAssistant;
    if (assistant == null) return;
    _chatStorage.saveMessages(assistant.name, messages);
  }

  /// 加载当前助手的聊天记录
  void _loadMessagesForCurrentAssistant() {
    final assistant = currentAssistant;
    if (assistant == null) {
      messages.clear();
      return;
    }

    final savedMessages = _chatStorage.loadMessages(assistant.name);
    messages.assignAll(savedMessages);
    debugPrint('📂 加载 ${assistant.name} 的 ${savedMessages.length} 条历史消息');
  }

  @override
  void onClose() {
    frameSubscription?.cancel();
    _socketStateWorker?.dispose();
    _callDurationTimer?.cancel();
    _messagesWorker?.dispose();
    _assistantWorker?.dispose();
    super.onClose();
  }

  // ==================== Socket 连接状态监听 ====================

  /// 监听 Socket 连接状态变化
  void _listenToSocketState() {
    _socketStateWorker = ever(socketService.connectionState, (state) {
      if (state == SocketConnectionState.connected) {
        _onSocketReconnected();
      } else if (state == SocketConnectionState.error ||
          state == SocketConnectionState.disconnected) {
        _onSocketDisconnected();
      }
    });
  }

  /// Socket 重连成功后的处理
  void _onSocketReconnected() {
    debugPrint('🔄 Socket 重连成功');
    // 不切换助手，服务端保持自己的当前助手状态
  }

  /// Socket 断开后清理卡住的状态
  void _onSocketDisconnected() {
    if (isReceivingResponse.value) {
      debugPrint('⚠️ Socket 断开，清理进行中的回复状态');
      completeCurrentResponse();
    }
    if (isCallActive.value) {
      isCallActive.value = false;
    }
  }

  // ==================== 消息和对话 ====================

  /// 发送文本消息
  Future<void> sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 发送文本时立即打断音频播放（不等待服务器回复）
    audioService.interrupt();

    if (!socketService.isConnected) {
      _showError('未连接', 'Socket 未连接，请检查设置');
      return;
    }

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

    // 记录请求发送时间，用于计算音频延迟
    requestSentTime = DateTime.now();
    isFirstAudioFrame = true;

    // 发送给服务端
    socketService.sendText(text.trim());

    // 提前创建音频流，减少收到音频后的播放延迟
    audioService.startPlayback();
  }

  /// 打断当前回复
  void interrupt() {
    // 先打断音频播放
    audioService.interrupt();
    // 再完成当前回复
    completeCurrentResponse();
  }

  /// 切换语音通话模式
  Future<void> toggleCallActive() async {
    if (!socketService.isConnected) {
      _showError('未连接', 'Socket 未连接，请检查设置');
      return;
    }

    if (isCallActive.value) {
      // 关闭语音模式
      await socketService.stopAudioStream();
      isCallActive.value = false;
      _stopCallDurationTimer();
      _showSuccess('语音模式', '已关闭语音通话模式');
    } else {
      // 启动语音模式
      final success = await socketService.startAudioStream();
      if (success) {
        isCallActive.value = true;
        _startCallDurationTimer();
        _showSuccess('语音模式', '已开启语音通话模式，请说话');
      } else {
        _showError('启动失败', socketService.lastError.value ?? '无法启动录音');
      }
    }
  }

  /// 启动通话时长计时器
  void _startCallDurationTimer() {
    callDuration.value = 0;
    _callDurationTimer?.cancel();
    _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      callDuration.value++;
    });
  }

  /// 停止通话时长计时器
  void _stopCallDurationTimer() {
    _callDurationTimer?.cancel();
    _callDurationTimer = null;
    callDuration.value = 0;
  }

  // ==================== UI 操作 ====================

  void toggleDetailPanel() {
    isDetailPanelOpen.value = !isDetailPanelOpen.value;
  }

  void toggleSidebar() {
    isSidebarCollapsed.value = !isSidebarCollapsed.value;
  }

  void showEditModal({Assistant? assistant}) {
    // 防止重复打开
    if (Get.isDialogOpen ?? false) return;

    Get.dialog(
      EditAssistantModal(assistant: assistant),
      barrierColor: const Color(0x66000000),
    );
  }

  void showSettingsModal() {
    // 防止重复打开
    if (Get.isDialogOpen ?? false) return;

    Get.dialog(const SettingsModal(), barrierColor: const Color(0x66000000));
  }

  // ==================== 辅助方法 ====================

  void _showSuccess(String title, String message) {
    LoadingService.to.showSuccess(message, title: title);
  }

  void _showError(String title, String message) {
    LoadingService.to.showError(message, title: title);
  }
}
