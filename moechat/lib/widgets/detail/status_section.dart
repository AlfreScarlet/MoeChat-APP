import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../theme/app_theme.dart';

/// Status section displaying love level progress bar and date key-value pairs.
///
/// Shows a section header with heart icon, then:
/// - 好感度 (love level) with a red gradient progress bar and numeric value
/// - 初次相遇 (first meet) date
/// - 最后更新 (last update) date
class StatusSection extends StatelessWidget {
  const StatusSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final assistant = controller.currentAssistant;

      if (assistant == null) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header: heart icon + "状态"
            Row(
              children: [
                Icon(
                  Icons.favorite,
                  size: 14,
                  color: AppTheme.primary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '状态',
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
            // KV list with gap
            _buildLoveLevel(assistant.loveLevel),
            const SizedBox(height: 6),
            _buildKvRow('初次相遇', assistant.firstMeet),
            const SizedBox(height: 6),
            _buildKvRow('最后更新', assistant.lastUpdate),
          ],
        ),
      );
    });
  }

  /// Builds the love level KV item matching prototype .kv-item style.
  Widget _buildLoveLevel(int level) {
    final fraction = (level / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: AppTheme.borderRadiusSmall,
      ),
      child: Row(
        children: [
          Text(
            '好感度',
            style: AppTheme.cjkStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          // Progress bar track
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                height: 6,
                child: Stack(
                  children: [
                    Container(color: AppTheme.border),
                    FractionallySizedBox(
                      widthFactor: fraction,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.loveGradient,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$level',
            style: AppTheme.cjkStyle(
              fontSize: 12,
              fontWeight: 600,
              color: AppTheme.danger,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a key-value row matching prototype .kv-item style.
  Widget _buildKvRow(String key, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: AppTheme.borderRadiusSmall,
      ),
      child: Row(
        children: [
          Text(
            key,
            style: AppTheme.cjkStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: AppTheme.cjkStyle(fontSize: 12, fontWeight: 600),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
