import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/assistant.dart';
import '../../services/api_service.dart';
import '../../services/loading_service.dart';
import '../../theme/app_theme.dart';

/// 助手 CRUD mixin
///
/// 提取自 HomeController，负责助手的加载、切换、添加、编辑、删除操作。
mixin AssistantCrudMixin on GetxController {
  // ==================== 依赖（由 HomeController 实现） ====================

  ApiService get apiService;
  RxList<Assistant> get assistants;
  RxInt get selectedAssistantIndex;
  RxList<ChatMessage> get messages;
  Rxn<ChatMessage> get currentAiMessage;
  RxBool get isSending;
  RxBool get isReceivingResponse;
  RxBool get isLoadingAssistants;
  Rxn<String> get assistantsError;

  /// 当前选中的助手（计算属性）
  Assistant? get currentAssistant;

  // ==================== 助手管理 ====================

  /// 加载助手列表
  /// [silent] 为 true 时不显示 loading 弹窗（用于自动连接/刷新）
  Future<void> loadAssistants({bool silent = false}) async {
    if (!apiService.isInitialized) {
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
        list = await apiService.fetchAssistants();
      } else {
        final result = await LoadingService.to.wrapLoading(
          () => apiService.fetchAssistants(),
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
        final current = await apiService.fetchCurrentAssistant();
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
      () => apiService.switchAssistant(assistant.name),
      message: '正在切换助手...',
    );

    if (result != null) {
      selectedAssistantIndex.value = index;
      // 不需要手动清空消息，ever 监听器会自动加载新助手的记录
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
      () => apiService.addAssistant(
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
        await apiService.switchAssistant(assistant.name);
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
      () => apiService.updateAssistant(
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
      () => apiService.deleteAssistant(name).then((_) => true),
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

        // 如果删除的是当前选中的助手，ever 监听器会自动加载新助手的记录
        if (wasSelected) {
          currentAiMessage.value = null;
          isSending.value = false;
          isReceivingResponse.value = false;

          // 通知服务端切换到新选中的助手
          final newAssistant = currentAssistant;
          if (newAssistant != null) {
            apiService
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
}
