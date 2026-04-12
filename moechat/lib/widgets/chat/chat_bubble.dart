import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../models/assistant.dart';
import '../../theme/app_theme.dart';
import '../common/avatar_image.dart';
import 'streaming_text.dart';
import 'typing_indicator.dart';

/// Chat message bubble widget.
///
/// Renders bot messages left-aligned with avatar + light-purple bubble,
/// and user messages right-aligned with purple bubble + white text.
/// When [ChatMessage.isTyping] is true, shows a [TypingIndicator]
/// instead of text content.
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isBot = message.sender == MessageSender.bot;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxBubbleWidth = constraints.maxWidth * 0.7;

        if (isBot) {
          return _buildBotMessage(maxBubbleWidth);
        } else {
          return _buildUserMessage(maxBubbleWidth);
        }
      },
    );
  }

  Widget _buildBotMessage(double maxBubbleWidth) {
    final controller = Get.find<HomeController>();
    final assistant = controller.currentAssistant;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReactiveAvatarImage(
          assistantName: assistant?.name ?? '',
          fallbackAvatar: assistant?.avatar,
          size: 32,
        ),
        const SizedBox(width: 10),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxBubbleWidth),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppTheme.bubbleBot,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: message.isTyping && message.content.isEmpty
                ? const TypingIndicator()
                : StreamingText(
                    text: message.content,
                    isStreaming: message.isTyping,
                    style: AppTheme.cjkStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: AppTheme.text,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserMessage(double maxBubbleWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxBubbleWidth),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppTheme.bubbleUser,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Text(
              message.content,
              style: AppTheme.cjkStyle(
                fontSize: 14,
                height: 1.6,
                color: AppTheme.bubbleUserText,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
