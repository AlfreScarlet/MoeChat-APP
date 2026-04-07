import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../theme/app_theme.dart';

/// Emotion configuration section in the detail panel.
///
/// Displays the assistant's emotion config value in a KV card,
/// or a "未配置" muted state when [emotionConfig] is null.
class EmotionSection extends StatelessWidget {
  const EmotionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final assistant = controller.currentAssistant;

      if (assistant == null) {
        return const SizedBox.shrink();
      }

      final emotionConfig = assistant.emotionConfig;
      final isEmpty = emotionConfig == null || emotionConfig.isEmpty;

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header: icon + title
            Row(
              children: [
                Icon(
                  Icons.mood_outlined,
                  size: 14,
                  color: AppTheme.primary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '情绪设置',
                    style: AppTheme.cjkStyle(
                      fontSize: 12,
                      fontWeight: 600,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // KV list with single item matching prototype .kv-list > .kv-item
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: AppTheme.borderRadiusSmall,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      isEmpty ? '未配置' : emotionConfig,
                      style: isEmpty
                          ? AppTheme.cjkStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                              fontStyle: FontStyle.italic,
                            )
                          : AppTheme.cjkStyle(
                              fontSize: 13,
                              fontWeight: 500,
                              color: AppTheme.text,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
