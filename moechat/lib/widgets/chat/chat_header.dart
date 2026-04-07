import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../services/socket_service.dart';
import '../../theme/app_theme.dart';

/// 通话中脉冲动画点 - 使用 StatefulWidget 实现无限循环
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        // 0→0.5: 展开阶段
        // 0.5→1: 收缩阶段
        final phase = t <= 0.5 ? t * 2 : (1 - t) * 2;
        final scale = 1.0 + phase * 0.3;
        final opacity = 0.5 + phase * 0.5;

        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.danger.withOpacity(opacity),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.danger.withOpacity(0.4 * phase),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppTheme.danger,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Chat header bar displaying the current assistant's avatar, name,
/// online status, and a toggle button for the detail panel.
class ChatHeader extends StatelessWidget {
  const ChatHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppTheme.chatBg,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Obx(() {
        final assistant = controller.currentAssistant;
        final socketService = Get.find<SocketService>();
        final isOnline = socketService.isConnected;

        if (assistant == null) {
          return Row(
            children: [
              Text(
                '未选择助手',
                style: AppTheme.cjkStyle(
                  fontSize: 15,
                  fontWeight: 700,
                  color: AppTheme.text,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.menu, size: 20),
                onPressed: controller.toggleDetailPanel,
                splashRadius: 18,
                tooltip: '切换详情面板',
              ),
            ],
          );
        }

        return Row(
          children: [
            // Name + online status
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  assistant.name,
                  style: AppTheme.cjkStyle(
                    fontSize: 15,
                    fontWeight: 700,
                    color: AppTheme.text,
                  ),
                ),
                Text(
                  isOnline ? '在线' : '离线',
                  style: AppTheme.cjkStyle(
                    fontSize: 12,
                    color: isOnline ? AppTheme.success : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // 通话中状态指示器
            Obx(() {
              if (!controller.isCallActive.value) {
                return const SizedBox.shrink();
              }
              return _buildCallIndicator(controller.callDuration.value);
            }),
            const Spacer(),
            // Detail panel toggle button
            IconButton(
              icon: const Icon(Icons.menu, size: 20),
              onPressed: controller.toggleDetailPanel,
              splashRadius: 18,
              tooltip: '切换详情面板',
            ),
          ],
        );
      }),
    );
  }

  /// 构建通话中状态指示器
  Widget _buildCallIndicator(int durationSeconds) {
    final minutes = (durationSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (durationSeconds % 60).toString().padLeft(2, '0');
    final timeStr = '$minutes:$seconds';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 脉冲动画点
          const _PulsingDot(),
          const SizedBox(width: 6),
          // 通话中文字
          Text(
            '通话中',
            style: AppTheme.cjkStyle(
              fontSize: 12,
              fontWeight: 600,
              color: AppTheme.danger,
            ),
          ),
          const SizedBox(width: 8),
          // 分隔线
          Container(
            width: 1,
            height: 12,
            color: AppTheme.danger.withOpacity(0.3),
          ),
          const SizedBox(width: 8),
          // 通话时长
          Text(
            timeStr,
            style: AppTheme.cjkStyle(
              fontSize: 12,
              fontWeight: 500,
              color: AppTheme.danger,
            ),
          ),
        ],
      ),
    );
  }
}
