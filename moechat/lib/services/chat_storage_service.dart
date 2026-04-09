import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../models/assistant.dart';

/// 聊天记录本地存储服务
///
/// 使用 get_storage 按助手名称分别存储聊天记录
/// 每个助手最多保留 [_maxMessagesPerAssistant] 条消息
class ChatStorageService extends GetxService {
  static const _boxName = 'chat_history';
  static const _maxMessagesPerAssistant = 100;

  late final GetStorage _box;

  /// 初始化存储（在 main 中调用）
  static Future<void> init() => GetStorage.init(_boxName);

  @override
  void onInit() {
    super.onInit();
    _box = GetStorage(_boxName);
  }

  /// 生成存储键
  String _getKey(String assistantName) => 'messages_$assistantName';

  /// 加载指定助手的聊天记录
  ///
  /// 返回按时间排序的消息列表，过滤掉未完成的输入消息
  List<ChatMessage> loadMessages(String assistantName) {
    final key = _getKey(assistantName);
    final List<dynamic>? data = _box.read(key);
    if (data == null || data.isEmpty) return [];

    try {
      return data
          .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
          .where((msg) => !msg.isTyping) // 过滤未完成的输入消息
          .toList();
    } catch (e) {
      debugPrint('⚠️ 加载聊天记录失败: $e');
      return [];
    }
  }

  /// 保存指定助手的聊天记录
  ///
  /// 自动过滤正在输入的消息，并限制消息数量
  Future<void> saveMessages(
    String assistantName,
    List<ChatMessage> messages,
  ) async {
    final key = _getKey(assistantName);

    // 过滤未完成的输入消息
    final validMessages = messages.where((msg) => !msg.isTyping).toList();

    // 限制数量，保留最新的消息
    final messagesToSave = validMessages.length > _maxMessagesPerAssistant
        ? validMessages.sublist(
            validMessages.length - _maxMessagesPerAssistant,
          )
        : validMessages;

    final data = messagesToSave.map((m) => m.toJson()).toList();
    await _box.write(key, data);
  }

  /// 清除指定助手的聊天记录
  Future<void> clearMessages(String assistantName) async {
    await _box.remove(_getKey(assistantName));
  }

  /// 清除所有聊天记录
  Future<void> clearAllMessages() async {
    await _box.erase();
  }

  /// 获取所有存储的助手名称（用于调试）
  List<String> getStoredAssistantNames() {
    final keys = _box.getKeys();
    return keys
        .where((k) => k.startsWith('messages_'))
        .map((k) => k.substring('messages_'.length))
        .toList();
  }
}
