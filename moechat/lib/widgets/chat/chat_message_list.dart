import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import 'chat_bubble.dart';

/// Vertically scrollable chat message list.
///
/// Reactively rebuilds when the selected assistant (and thus the
/// current message list) changes. Each message is rendered as a
/// [ChatBubble] with 16px vertical spacing and 20px padding around
/// the list.
class ChatMessageList extends StatefulWidget {
  const ChatMessageList({super.key});

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 滚动到底部
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final messages = controller.messages;
      // 触发响应式依赖后滚动到底部
      if (messages.isNotEmpty) {
        _scrollToBottom();
      }

      return Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          itemCount: messages.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final message = messages[index];
            return ChatBubble(key: ValueKey(message.id), message: message);
          },
        ),
      );
    });
  }
}
