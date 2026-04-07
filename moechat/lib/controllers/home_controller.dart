import 'dart:async';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../models/assistant.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../services/socket_service.dart';
import '../services/loading_service.dart';
import '../theme/app_theme.dart';
import '../widgets/modals/edit_assistant_modal.dart';
import '../widgets/modals/settings_modal.dart';

/// Centralized application state controller.
class HomeController extends GetxController {
  // 服务引用
  final _apiService = Get.find<ApiService>();
  final _socketService = Get.find<SocketService>();
  final _audioService = Get.find<AudioService>();

  // 助手列表状态
  final assistants = <Assistant>[].obs;
  final selectedAssistantIndex = 0.obs;
  final isLoadingAssistants = false.obs;
  final assistantsError = Rxn<String>();

  // UI 状态
  final isDetailPanelOpen = true.obs;
  final isCallActive = false.obs;
  final isSidebarCollapsed = false.obs;

  // 通话时长状态
  final callDuration = 0.obs; // 通话时长（秒）
  Timer? _callDurationTimer;

  // 消息状态
  final messages = <ChatMessage>[].obs;
  final isSending = false.obs;
  final currentAiMessage = Rxn<ChatMessage>();

  // 是否正在接收 AI 回复（用于打断判断）
  final isReceivingResponse = false.obs;

  // 音频延迟计时（记录发送请求到收到第一段音频的延迟）
  DateTime? _requestSentTime;
  bool _isFirstAudioFrame = false;

  // 资源管理状态
  final isCheckingAssets = false.obs;
  final isDownloadingAssets = false.obs;
  final isUploadingAssets = false.obs;
  final assetsError = Rxn<String>();

  // Socket 帧订阅
  StreamSubscription<SocketFrame>? _frameSubscription;
  Worker? _socketStateWorker;

  // 计算属性
  Assistant? get currentAssistant {
    if (assistants.isEmpty) return null;
    final index = selectedAssistantIndex.value;
    if (index < 0 || index >= assistants.length) return null;
    return assistants[index];
  }

  @override
  void onInit() {
    super.onInit();
    _listenToSocketFrames();
    _listenToSocketState();
    debugPrint('✅ HomeController 初始化完成');
  }

  @override
  void onClose() {
    _frameSubscription?.cancel();
    _socketStateWorker?.dispose();
    _callDurationTimer?.cancel();
    super.onClose();
  }

  // ==================== Socket 连接状态监听 ====================

  /// 监听 Socket 连接状态变化
  void _listenToSocketState() {
    _socketStateWorker = ever(_socketService.connectionState, (state) {
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
      _completeCurrentResponse();
    }
    if (isCallActive.value) {
      isCallActive.value = false;
    }
  }

  // ==================== 助手管理 ====================

  /// 加载助手列表
  /// [silent] 为 true 时不显示 loading 弹窗（用于自动连接/刷新）
  Future<void> loadAssistants({bool silent = false}) async {
    if (!_apiService.isInitialized) {
      debugPrint('⚠️ API 服务未初始化，跳过加载助手列表');
      return;
    }

    // 防止并发加载
    if (isLoadingAssistants.value) return;

    isLoadingAssistants.value = true;
    assistantsError.value = null;
    debugPrint('📥 开始加载助手列表...');

    try {
      final List<Assistant> list;
      if (silent) {
        list = await _apiService.fetchAssistants();
      } else {
        final result = await LoadingService.to.wrapLoading(
          () => _apiService.fetchAssistants(),
          message: '正在加载助手列表...',
        );
        if (result == null) {
          debugPrint('❌ 加载助手列表失败');
          return;
        }
        list = result;
      }

      assistants.assignAll(list);
      debugPrint('✅ 加载了 ${list.length} 个助手');

      // 获取当前助手并选中（失败不影响列表显示）
      try {
        final current = await _apiService.fetchCurrentAssistant();
        if (current != null) {
          final index = assistants.indexWhere((a) => a.name == current.name);
          if (index != -1) {
            selectedAssistantIndex.value = index;
            debugPrint('✅ 当前助手: ${current.name}');
          }
        } else {
          debugPrint('⚠️ 没有当前助手');
        }
      } catch (e) {
        debugPrint('⚠️ 获取当前助手失败: $e');
      }
    } catch (e) {
      assistantsError.value = e.toString();
      debugPrint('❌ 加载助手列表失败: $e');
    } finally {
      isLoadingAssistants.value = false;
    }
  }

  /// 切换助手
  Future<void> selectAssistant(int index) async {
    if (index == selectedAssistantIndex.value) return;
    if (index < 0 || index >= assistants.length) return;

    final assistant = assistants[index];

    final result = await LoadingService.to.wrapLoading(
      () => _apiService.switchAssistant(assistant.name),
      message: '正在切换助手...',
    );

    if (result != null) {
      selectedAssistantIndex.value = index;
      messages.clear();
      currentAiMessage.value = null;
      isSending.value = false;
      isReceivingResponse.value = false;
      LoadingService.to.showSuccess('已切换到 ${assistant.name}');
    }
  }

  /// 添加助手
  Future<bool> addAssistant({
    required String name,
    required String avatar,
    required String birthday,
    required String height,
    required String weight,
    required String personality,
    required String description,
    String? user,
    String? mask,
    List<String>? messageExamples,
    String? extraDescription,
    String? customPrompt,
    List<String>? startWith,
    FeatureSettings? settings,
    GsvSettings? gsvSetting,
  }) async {
    final assistant = await LoadingService.to.wrapLoading(
      () => _apiService.addAssistant(
        name: name,
        avatar: avatar,
        birthday: birthday,
        height: height,
        weight: weight,
        personality: personality,
        description: description,
        user: user,
        mask: mask,
        messageExamples: messageExamples,
        extraDescription: extraDescription,
        customPrompt: customPrompt,
        startWith: startWith,
        settings: settings,
        gsvSetting: gsvSetting,
      ),
      message: '正在创建助手...',
    );

    if (assistant != null) {
      assistants.add(assistant);
      // 自动选中新创建的助手并通知服务端
      selectedAssistantIndex.value = assistants.length - 1;
      messages.clear();
      // 通知服务端切换到新助手（失败不影响本地状态）
      try {
        await _apiService.switchAssistant(assistant.name);
      } catch (_) {}
      return true;
    }
    return false;
  }

  /// 编辑助手
  Future<bool> editAssistant({
    required String name,
    String? avatar,
    String? birthday,
    String? height,
    String? weight,
    String? personality,
    String? description,
    String? user,
    String? mask,
    List<String>? messageExamples,
    String? extraDescription,
    String? customPrompt,
    List<String>? startWith,
    FeatureSettings? settings,
    GsvSettings? gsvSetting,
  }) async {
    final updated = await LoadingService.to.wrapLoading(
      () => _apiService.updateAssistant(
        name: name,
        avatar: avatar,
        birthday: birthday,
        height: height,
        weight: weight,
        personality: personality,
        description: description,
        user: user,
        mask: mask,
        messageExamples: messageExamples,
        extraDescription: extraDescription,
        customPrompt: customPrompt,
        startWith: startWith,
        settings: settings,
        gsvSetting: gsvSetting,
      ),
      message: '正在保存修改...',
    );

    if (updated != null) {
      // 更新本地列表
      final index = assistants.indexWhere((a) => a.name == name);
      if (index != -1) {
        assistants[index] = updated;
      }
      return true;
    }
    return false;
  }

  /// 删除助手
  Future<bool> deleteAssistant(String name) async {
    final result = await LoadingService.to.wrapLoading(
      () => _apiService.deleteAssistant(name).then((_) => true),
      message: '正在删除助手...',
    );

    if (result == true) {
      // 从本地列表移除
      final index = assistants.indexWhere((a) => a.name == name);
      if (index != -1) {
        final wasSelected = index == selectedAssistantIndex.value;
        assistants.removeAt(index);

        // 调整选中索引
        if (assistants.isEmpty) {
          selectedAssistantIndex.value = 0;
        } else if (selectedAssistantIndex.value >= assistants.length) {
          selectedAssistantIndex.value = assistants.length - 1;
        }

        // 如果删除的是当前选中的助手，清理消息状态
        if (wasSelected) {
          messages.clear();
          currentAiMessage.value = null;
          isSending.value = false;
          isReceivingResponse.value = false;

          // 通知服务端切换到新选中的助手
          final newAssistant = currentAssistant;
          if (newAssistant != null) {
            _apiService
                .switchAssistant(newAssistant.name)
                .catchError((_) => newAssistant);
          }
        }
      }
      LoadingService.to.showSuccess('助手 "$name" 已删除');
      return true;
    }
    return false;
  }

  /// 显示删除确认对话框
  void showDeleteConfirmDialog(String name) {
    // 防止重复打开
    if (Get.isDialogOpen ?? false) return;

    Get.dialog(
      AlertDialog(
        title: Text('确认删除', style: AppTheme.cjkStyle(fontWeight: 700)),
        content: Text('确定要删除助手 "$name" 吗？此操作不可恢复。', style: AppTheme.cjkStyle()),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              '取消',
              style: AppTheme.cjkStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await deleteAssistant(name);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
            ),
            child: Text('删除', style: AppTheme.cjkStyle()),
          ),
        ],
      ),
    );
  }

  // ==================== 资源管理 ====================

  /// 检查资源更新
  Future<AssetsUpdateResult?> checkAssetsUpdate(String name) async {
    isCheckingAssets.value = true;
    assetsError.value = null;

    final assistant = assistants.firstWhereOrNull((a) => a.name == name);
    final lastModified = assistant?.assetsLastModified ?? 0.0;

    final result = await LoadingService.to.wrapLoading(
      () => _apiService.checkAssetsUpdate(name, lastModified),
      message: '正在检查资源更新...',
    );

    isCheckingAssets.value = false;
    return result;
  }

  /// 下载并解压资源包
  Future<bool> downloadAssets(String name) async {
    isDownloadingAssets.value = true;
    assetsError.value = null;

    final zipData = await LoadingService.to.wrapLoading(
      () => _apiService.downloadAssets(name),
      message: '正在下载资源包...',
    );

    if (zipData == null) {
      isDownloadingAssets.value = false;
      return false;
    }

    try {
      // 解压到本地缓存目录
      final tempDir = await getTemporaryDirectory();
      final assistantDir = Directory('${tempDir.path}/assets/$name');

      // 清理旧目录
      if (await assistantDir.exists()) {
        await assistantDir.delete(recursive: true);
      }
      await assistantDir.create(recursive: true);

      // 解压zip
      final archive = ZipDecoder().decodeBytes(zipData);
      for (final file in archive) {
        // 安全检查：防止路径遍历攻击
        final normalizedName = file.name.replaceAll('\\', '/');
        if (normalizedName.contains('..') || normalizedName.startsWith('/')) {
          debugPrint('⚠️ 跳过不安全的文件路径: ${file.name}');
          continue;
        }

        final filePath = '${assistantDir.path}/$normalizedName';
        if (file.isFile) {
          final data = file.content as List<int>;
          await File(filePath).create(recursive: true);
          await File(filePath).writeAsBytes(data);
        } else {
          await Directory(filePath).create(recursive: true);
        }
      }

      LoadingService.to.showSuccess('资源包已下载并解压');
      return true;
    } catch (e) {
      assetsError.value = e.toString();
      return false;
    } finally {
      isDownloadingAssets.value = false;
    }
  }

  /// 上传资源包
  Future<bool> uploadAssets(String name) async {
    isUploadingAssets.value = true;
    assetsError.value = null;

    try {
      // 选择zip文件
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        isUploadingAssets.value = false;
        return false;
      }

      final file = result.files.first;
      if (file.bytes == null) {
        isUploadingAssets.value = false;
        return false;
      }

      final uploadResult = await LoadingService.to.wrapLoading(
        () => _apiService
            .uploadAssets(name, Uint8List.fromList(file.bytes!))
            .then((_) => true),
        message: '正在上传资源包...',
      );

      if (uploadResult == true) {
        LoadingService.to.showSuccess('资源包上传成功');
        return true;
      }
      return false;
    } catch (e) {
      assetsError.value = e.toString();
      return false;
    } finally {
      isUploadingAssets.value = false;
    }
  }

  /// 检查并更新资源（一键操作）
  Future<bool> checkAndUpdateAssets(String name) async {
    final checkResult = await checkAssetsUpdate(name);
    if (checkResult == null) return false;

    if (!checkResult.needsUpdate) {
      _showSuccess('已是最新', '资源已是最新版本');
      return true;
    }

    return await downloadAssets(name);
  }

  // ==================== 消息和对话 ====================

  /// 发送文本消息
  Future<void> sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 发送文本时立即打断音频播放（不等待服务器回复）
    _audioService.interrupt();

    if (!_socketService.isConnected) {
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
    _requestSentTime = DateTime.now();
    _isFirstAudioFrame = true;

    // 发送给服务端
    _socketService.sendText(text.trim());
  }

  /// 打断当前回复
  void interrupt() {
    _completeCurrentResponse();
  }

  /// 切换语音通话模式
  Future<void> toggleCallActive() async {
    if (!_socketService.isConnected) {
      _showError('未连接', 'Socket 未连接，请检查设置');
      return;
    }

    if (isCallActive.value) {
      // 关闭语音模式
      await _socketService.stopAudioStream();
      isCallActive.value = false;
      _stopCallDurationTimer();
      _showSuccess('语音模式', '已关闭语音通话模式');
    } else {
      // 启动语音模式
      final success = await _socketService.startAudioStream();
      if (success) {
        isCallActive.value = true;
        _startCallDurationTimer();
        _showSuccess('语音模式', '已开启语音通话模式，请说话');
      } else {
        _showError('启动失败', _socketService.lastError.value ?? '无法启动录音');
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

  // ==================== Socket 消息处理 ====================

  /// 监听 Socket 帧
  void _listenToSocketFrames() {
    _frameSubscription = _socketService.frameStream.listen((frame) {
      switch (frame.type) {
        case FrameType.start:
          // 打断信号 - 用户开始说话
          _handleStartFrame();
          break;
        case FrameType.text:
          _handleTextFrame(frame.textPayload ?? '');
          break;
        case FrameType.audio:
          // P1: 播放 TTS 音频
          _handleAudioFrame(frame.binaryPayload);
          break;
        case FrameType.complete:
          _handleCompleteFrame();
          break;
        case FrameType.me:
          // ASR 识别结果，显示为用户消息（语音输入时）
          _handleAsrResult(frame.textPayload ?? '');
          break;
        case FrameType.unknown:
          break;
      }
    });
  }

  /// 处理打断帧（<|start|>）
  void _handleStartFrame() {
    debugPrint('收到打断信号');

    // 立即打断音频播放
    _audioService.interrupt();

    // 用户开始说话，恢复录音发送
    if (isCallActive.value) {
      _socketService.unmuteAudioStream();
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
  void _handleTextFrame(String text) {
    // 收到回复，静音录音避免回声
    if (isCallActive.value) {
      _socketService.muteAudioStream();
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
  void _handleAudioFrame(Uint8List? audioData) {
    if (audioData == null || audioData.isEmpty) return;

    // 计算并输出第一段音频的延迟和具体时间
    if (_isFirstAudioFrame && _requestSentTime != null) {
      final receiveTime = DateTime.now();
      final latency = receiveTime.difference(_requestSentTime!);
      final reqTimeStr = _requestSentTime!.toIso8601String();
      final recvTimeStr = receiveTime.toIso8601String();
      debugPrint(
        '⏱️ 音频延迟: ${latency.inMilliseconds} ms | 请求时间: $reqTimeStr | 收到时间: $recvTimeStr',
      );
      _isFirstAudioFrame = false;
    }

    _audioService.enqueueAudio(audioData);
  }

  /// 处理完成帧
  void _handleCompleteFrame() {
    _completeCurrentResponse();

    // 标记音频播放完成
    _audioService.finishPlayback();

    // 回复结束，恢复录音发送
    if (isCallActive.value) {
      _socketService.unmuteAudioStream();
    }
  }

  /// 处理ASR识别结果（语音输入）
  void _handleAsrResult(String text) {
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
    _requestSentTime = DateTime.now();
    _isFirstAudioFrame = true;
  }

  /// 完成当前回复
  void _completeCurrentResponse() {
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
