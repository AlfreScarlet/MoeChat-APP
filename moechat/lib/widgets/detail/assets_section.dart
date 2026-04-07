import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../theme/app_theme.dart';

/// Assets section in the detail panel.
///
/// Displays a status indicator and three action buttons:
/// - 检查更新, 下载, 上传
class AssetsSection extends StatelessWidget {
  const AssetsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final assistant = controller.currentAssistant;
      final isChecking = controller.isCheckingAssets.value;
      final isDownloading = controller.isDownloadingAssets.value;
      final isUploading = controller.isUploadingAssets.value;

      String statusText = '已是最新版本';
      Color statusColor = AppTheme.success;

      if (isChecking) {
        statusText = '检查中...';
        statusColor = AppTheme.primary;
      } else if (isDownloading) {
        statusText = '下载中...';
        statusColor = AppTheme.primary;
      } else if (isUploading) {
        statusText = '上传中...';
        statusColor = AppTheme.primary;
      } else if (controller.assetsError.value != null) {
        statusText = '操作失败';
        statusColor = AppTheme.danger;
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header: icon + title
            Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 14,
                  color: AppTheme.primary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '资源文件',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Status indicator + action buttons
            Row(
              children: [
                // Status dot
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: controller.assetsError.value != null
                        ? AppTheme.danger
                        : AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                // Action buttons
                _ActionButton(
                  icon: Icons.refresh,
                  tooltip: '检查更新',
                  isLoading: isChecking,
                  onTap: assistant == null || isChecking
                      ? null
                      : () => controller.checkAndUpdateAssets(assistant.name),
                ),
                const SizedBox(width: 6),
                _ActionButton(
                  icon: Icons.download,
                  tooltip: '下载',
                  isLoading: isDownloading,
                  onTap: assistant == null || isDownloading
                      ? null
                      : () => controller.downloadAssets(assistant.name),
                ),
                const SizedBox(width: 6),
                _ActionButton(
                  icon: Icons.upload,
                  tooltip: '上传',
                  isLoading: isUploading,
                  onTap: assistant == null || isUploading
                      ? null
                      : () => controller.uploadAssets(assistant.name),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

/// A 28×28px square icon button with a border that turns purple on hover.
class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    this.isLoading = false,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onTap != null && !widget.isLoading;
    final color = !isEnabled
        ? AppTheme.border
        : _hovered
        ? AppTheme.primary
        : AppTheme.border;
    final iconColor = !isEnabled
        ? AppTheme.textSecondary.withValues(alpha: 0.3)
        : _hovered
        ? AppTheme.primary
        : AppTheme.textSecondary;

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: isEnabled ? (_) => setState(() => _hovered = true) : null,
        onExit: isEnabled ? (_) => setState(() => _hovered = false) : null,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              border: Border.all(color: color),
              borderRadius: BorderRadius.circular(4),
            ),
            child: widget.isLoading
                ? Center(
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                      ),
                    ),
                  )
                : Icon(widget.icon, size: 16, color: iconColor),
          ),
        ),
      ),
    );
  }
}
