import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'chat_header.dart';
import 'chat_message_list.dart';
import 'chat_input_bar.dart';

/// Main chat area container.
///
/// Displays the chat header, scrollable message list, and input bar
/// in a vertical column layout. Reactively updates when the selected
/// assistant changes via [HomeController].
class ChatArea extends StatelessWidget {
  const ChatArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: const Column(
        children: [
          ChatHeader(),
          Expanded(child: ChatMessageList()),
          ChatInputBar(),
        ],
      ),
    );
  }
}
