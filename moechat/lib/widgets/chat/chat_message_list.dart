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
/// - 使用 reverse 模式，键盘弹出时最新消息自然可见
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

  /// 滚动到底部（实际上是顶部，因为 reverse: true）
  void _scrollToBottom() {
    final messages = _controller.messages;
    if (messages.isEmpty) return;

    // reverse: true 时，最新消息在索引 0，滚动到 0 就是到底部
    _listController.sliverController.jumpToIndex(0);
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

      // 反转消息列表，配合 reverse: true 实现最新消息在底部
      final reversedMessages = messages.reversed.toList();

      return Scrollbar(
        controller: _listController,
        thumbVisibility: false,
        child: FlutterListView(
          controller: _listController,
          // 反向列表：从底部开始渲染，解决键盘弹出遮挡问题
          reverse: true,
          delegate: FlutterListViewDelegate(
            (BuildContext context, int index) {
              // index 是反转后的索引，0 对应最新消息
              final message = reversedMessages[index];
              final actualIndex = messages.length - 1 - index;
              final isFirst = actualIndex == 0;
              final isLast = actualIndex == messages.length - 1;

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
            childCount: reversedMessages.length,
            // 使用消息 ID 作为 key，确保列表项正确识别
            onItemKey: (index) => reversedMessages[index].id,
            // 禁用缓存，保持消息状态
            disableCacheItems: true,
            // 保持位置，插入新消息时不自动滚动
            keepPosition: true,
            // 第一个条目对齐到结束位置（底部）
            firstItemAlign: FirstItemAlign.end,
          ),
        ),
      );
    });
  }
}
