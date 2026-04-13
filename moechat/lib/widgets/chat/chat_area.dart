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
  /// Whether to show the chat header.
  /// Set to false for mobile layouts where the header is in AppBar.
  final bool showHeader;

  const ChatArea({super.key, this.showHeader = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: Column(
        children: [
          if (showHeader) const ChatHeader(),
          const Expanded(child: ChatMessageList()),
          const ChatInputBar(),
        ],
      ),
    );
  }
}
