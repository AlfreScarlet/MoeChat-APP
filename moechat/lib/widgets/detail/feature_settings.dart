import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../models/assistant.dart';
import '../../theme/app_theme.dart';

/// Feature settings section for the detail panel.
///
/// Displays context length as a KV card, then a toggle-group with
/// 1px border-gap between items matching the prototype's .toggle-group style.
class FeatureSettingsWidget extends StatelessWidget {
  const FeatureSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final assistant = controller.currentAssistant;

      if (assistant == null) {
        return const SizedBox.shrink();
      }

      final features = assistant.features;

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              children: [
                Icon(
                  Icons.tune,
                  size: 14,
                  color: AppTheme.primary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '功能设置',
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

            // Context length KV card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: AppTheme.borderRadiusSmall,
              ),
              child: Row(
                children: [
                  Text(
                    '上下文长度',
                    style: AppTheme.cjkStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      features.contextLength.toString(),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.cjkStyle(
                        fontSize: 13,
                        fontWeight: 600,
                        color: AppTheme.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Toggle group with 1px gap (border-colored background shows through)
            ClipRRect(
              borderRadius: AppTheme.borderRadiusSmall,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: AppTheme.borderRadiusSmall,
                ),
                child: Column(children: _buildToggleItems(features)),
              ),
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _buildToggleItems(FeatureSettings f) {
    final items = <Widget>[];

    void addItem(Widget w) {
      if (items.isNotEmpty) {
        items.add(const SizedBox(height: 1)); // 1px gap
      }
      items.add(w);
    }

    addItem(_ToggleItem(label: '日记（长期记忆）', enabled: f.diary));
    addItem(_ToggleItem(label: '日记检索加强', enabled: f.diarySearchBoost));
    addItem(
      _SubValueItem(label: '搜索阈值', value: f.diarySearchThreshold.toString()),
    );
    addItem(_ToggleItem(label: '核心记忆', enabled: f.coreMemory));
    addItem(_ToggleItem(label: '世界书（知识库）', enabled: f.worldBook));
    addItem(
      _SubValueItem(label: '搜索阈值', value: f.worldBookThreshold.toString()),
    );
    addItem(_SubValueItem(label: '搜索深度', value: f.worldBookDepth.toString()));
    addItem(_ToggleItem(label: '情绪系统', enabled: f.emotionSystem));
    addItem(_SubToggleItem(label: '情绪持续存储', enabled: f.emotionPersist));

    return items;
  }
}

/// A toggle row with label and green/red badge.
class _ToggleItem extends StatelessWidget {
  final String label;
  final bool enabled;
  const _ToggleItem({required this.label, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTheme.cjkStyle(fontSize: 13, color: AppTheme.text),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          _Badge(enabled: enabled),
        ],
      ),
    );
  }
}

/// Indented sub-item with a numeric value.
class _SubValueItem extends StatelessWidget {
  final String label;
  final String value;
  const _SubValueItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      padding: const EdgeInsets.only(left: 28, right: 12, top: 7, bottom: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTheme.cjkStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: AppTheme.cjkStyle(
              fontSize: 12,
              fontWeight: 600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Indented sub-item with a toggle badge.
class _SubToggleItem extends StatelessWidget {
  final String label;
  final bool enabled;
  const _SubToggleItem({required this.label, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      padding: const EdgeInsets.only(left: 28, right: 12, top: 7, bottom: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTheme.cjkStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          _Badge(enabled: enabled),
        ],
      ),
    );
  }
}

/// Green "开启" or red "关闭" badge.
class _Badge extends StatelessWidget {
  final bool enabled;
  const _Badge({required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(
        color: enabled ? AppTheme.toggleOnBg : AppTheme.toggleOffBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        enabled ? '开启' : '关闭',
        style: AppTheme.cjkStyle(
          fontSize: 11,
          fontWeight: 600,
          color: enabled ? AppTheme.toggleOnText : AppTheme.toggleOffText,
        ),
      ),
    );
  }
}
