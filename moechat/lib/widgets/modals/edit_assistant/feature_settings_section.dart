import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../common/form_widgets.dart';

/// 功能设置区块 — 上下文长度、日记开关、核心记忆、知识库、情绪系统
///
/// 接收 controllers、开关状态和 onToggleChanged 回调，不管理状态。
class FeatureSettingsSection extends StatelessWidget {
  final TextEditingController contextLengthCtrl;
  final TextEditingController diaryThresholdCtrl;
  final TextEditingController worldBookThresholdCtrl;
  final TextEditingController worldBookDepthCtrl;
  final bool enableLongMemory;
  final bool enableLongMemorySearchEnhance;
  final bool enableCoreMemory;
  final bool enableLoreBooks;
  final bool enableEmotionSystem;
  final bool enableEmotionPersist;
  final void Function(String key, bool value) onToggleChanged;

  const FeatureSettingsSection({
    super.key,
    required this.contextLengthCtrl,
    required this.diaryThresholdCtrl,
    required this.worldBookThresholdCtrl,
    required this.worldBookDepthCtrl,
    required this.enableLongMemory,
    required this.enableLongMemorySearchEnhance,
    required this.enableCoreMemory,
    required this.enableLoreBooks,
    required this.enableEmotionSystem,
    required this.enableEmotionPersist,
    required this.onToggleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        const ModalSectionDivider(title: '功能设置', icon: Icons.tune),
        const SizedBox(height: 12),
        // 上下文长度 KV 卡片
        ModalKvInputRow(
          label: '上下文长度',
          controller: contextLengthCtrl,
          placeholder: '40',
        ),
        const SizedBox(height: 6),
        // 开关组（卡片式，1px 间隔）
        ClipRRect(
          borderRadius: AppTheme.borderRadiusSmall,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.border,
              borderRadius: AppTheme.borderRadiusSmall,
            ),
            child: Column(
              children: [
                ModalCardToggle(
                  label: '日记（长期记忆）',
                  value: enableLongMemory,
                  onChanged: (v) => onToggleChanged('longMemory', v),
                ),
                const SizedBox(height: 1),
                ModalCardToggle(
                  label: '日记检索加强',
                  value: enableLongMemorySearchEnhance,
                  onChanged: (v) =>
                      onToggleChanged('longMemorySearchEnhance', v),
                ),
                const SizedBox(height: 1),
                ModalCardSubInput(
                  label: '搜索阈值',
                  controller: diaryThresholdCtrl,
                  placeholder: '0.38',
                ),
                const SizedBox(height: 1),
                ModalCardToggle(
                  label: '核心记忆',
                  value: enableCoreMemory,
                  onChanged: (v) => onToggleChanged('coreMemory', v),
                ),
                const SizedBox(height: 1),
                ModalCardToggle(
                  label: '知识库（世界书）',
                  value: enableLoreBooks,
                  onChanged: (v) => onToggleChanged('loreBooks', v),
                ),
                const SizedBox(height: 1),
                ModalCardSubInput(
                  label: '搜索阈值',
                  controller: worldBookThresholdCtrl,
                  placeholder: '0.5',
                ),
                const SizedBox(height: 1),
                ModalCardSubInput(
                  label: '搜索深度',
                  controller: worldBookDepthCtrl,
                  placeholder: '3',
                ),
                const SizedBox(height: 1),
                ModalCardToggle(
                  label: '情绪系统',
                  value: enableEmotionSystem,
                  onChanged: (v) => onToggleChanged('emotionSystem', v),
                ),
                const SizedBox(height: 1),
                ModalCardSubToggle(
                  label: '情绪持续存储',
                  value: enableEmotionPersist,
                  onChanged: (v) => onToggleChanged('emotionPersist', v),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
