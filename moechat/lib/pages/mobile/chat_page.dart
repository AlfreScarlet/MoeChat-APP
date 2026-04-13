import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../services/socket_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/chat/chat_area.dart';
import 'assistant_detail_page.dart';

/// 聊天页面 - 移动端
///
/// 复用PC端的ChatArea组件，以独立页面形式展示
/// AppBar 显示助手名称、在线状态和通话中指示器
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final socketService = Get.find<SocketService>();

    return Scaffold(
      resizeToAvoidBottomInset: true,  // 确保键盘弹出时布局上移至最新消息可见
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 56,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        title: Obx(() {
          final assistant = controller.currentAssistant;
          final isOnline = socketService.isConnected;

          if (assistant == null) {
            return const Text('聊天');
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(assistant.name),
              const SizedBox(width: 8),
              // 在线状态指示器
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isOnline ? AppTheme.success : AppTheme.textSecondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                isOnline ? '在线' : '离线',
                style: TextStyle(
                  fontSize: 12,
                  color: isOnline ? AppTheme.success : AppTheme.textSecondary,
                ),
              ),
            ],
          );
        }),
        actions: [
          // 通话中指示器
          Obx(() {
            if (!controller.isCallActive.value) {
              return const SizedBox.shrink();
            }
            return _buildCallIndicator(controller.callDuration.value);
          }),
          // 详情按钮（与PC端样式一致）
          IconButton(
            icon: const Icon(Icons.menu, size: 20),
            onPressed: () {
              final assistant = controller.currentAssistant;
              if (assistant != null) {
                Get.to(() => AssistantDetailPage(assistant: assistant));
              }
            },
            splashRadius: 18,
            tooltip: '助手详情',
          ),
        ],
      ),
      // 使用 showHeader: false 隐藏 ChatHeader，因为信息已在 AppBar 中显示
      body: const ChatArea(showHeader: false),
    );
  }

  /// 构建通话中状态指示器
  Widget _buildCallIndicator(int durationSeconds) {
    final minutes = (durationSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (durationSeconds % 60).toString().padLeft(2, '0');
    final timeStr = '$minutes:$seconds';

    return Center(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.danger.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.danger.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 脉冲动画点（简化版）
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppTheme.danger,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            // 通话中文字
            Text(
              '通话中',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.danger,
              ),
            ),
            const SizedBox(width: 6),
            // 分隔线
            Container(
              width: 1,
              height: 10,
              color: AppTheme.danger.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 6),
            // 通话时长
            Text(
              timeStr,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppTheme.danger,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
