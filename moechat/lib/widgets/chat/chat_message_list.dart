import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../models/assistant.dart';
import 'chat_bubble.dart';

/// 使用 flutter_list_view 实现的高性能聊天消息列表。
///
/// 特性：
/// - 支持跳转到指定消息索引
/// - 在顶部插入数据时不自动滚动（保持位置）
/// - 高效的列表项复用
/// - 自动滚动到底部（当新消息到达时）
class ChatMessageList extends StatefulWidget {
  const ChatMessageList({super.key});

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  late final FlutterListViewController _listController;
  final _controller = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    _listController = FlutterListViewController();
    // 监听消息列表变化，自动滚动到底部
    ever(_controller.messages, _onMessagesChanged);
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  /// 消息列表变化时的处理
  ///
  /// 当有新消息添加时，自动滚动到底部
  void _onMessagesChanged(List<ChatMessage> messages) {
    if (messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _listController.hasClients) {
          _scrollToBottom();
        }
      });
    }
  }

  /// 滚动到底部
  void _scrollToBottom() {
    final messages = _controller.messages;
    if (messages.isEmpty) return;

    // 使用 jumpToIndex 跳转到最新消息
    // 使用 smooth: true 实现平滑滚动
    _listController.sliverController.jumpToIndex(
      messages.length - 1,
      offsetBasedOnBottom: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final messages = _controller.messages;

      if (messages.isEmpty) {
        return const Center(
          child: Text(
            '开始对话吧~',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        );
      }

      return Scrollbar(
        controller: _listController,
        thumbVisibility: true,
        child: FlutterListView(
          controller: _listController,
          delegate: FlutterListViewDelegate(
            (BuildContext context, int index) {
              final message = messages[index];
              // 添加间距：顶部和底部需要 padding，消息之间有间距
              final isFirst = index == 0;
              final isLast = index == messages.length - 1;
              return Padding(
                padding: EdgeInsets.only(
                  top: isFirst ? 20 : 0,
                  bottom: isLast ? 20 : 0,
                  left: 20,
                  right: 20,
                ),
                child: Column(
                  children: [
                    ChatBubble(
                      key: ValueKey(message.id),
                      message: message,
                    ),
                    if (!isLast) const SizedBox(height: 16),
                  ],
                ),
              );
            },
            childCount: messages.length,
            // 使用消息 ID 作为 key，确保列表项正确识别
            onItemKey: (index) => messages[index].id,
            // 禁用缓存，保持消息状态（聊天消息通常需要保持状态）
            disableCacheItems: true,
            // 保持最后一个消息可见（用于自动滚动）
            keepPosition: false,
          ),
        ),
      );
    });
  }
}
