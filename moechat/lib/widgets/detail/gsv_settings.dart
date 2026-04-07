import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../theme/app_theme.dart';

/// GSV voice settings section for the detail panel.
///
/// Displays all 11 GSV parameters as key-value card items matching
/// the prototype's .kv-item style with background cards.
class GsvSettingsWidget extends StatelessWidget {
  const GsvSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final assistant = controller.currentAssistant;

      if (assistant == null) {
        return const SizedBox.shrink();
      }

      final gsv = assistant.gsv;

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              children: [
                Icon(
                  Icons.record_voice_over_outlined,
                  size: 14,
                  color: AppTheme.primary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '语音设置 (GSV)',
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
            _KvList(
              entries: [
                _KvEntry('textLang', gsv.textLang),
                _KvEntry('gptModelPath', gsv.gptModelPath),
                _KvEntry('sovitsModelPath', gsv.sovitsModelPath),
                _KvEntry('refAudioPath', gsv.refAudioPath),
                _KvEntry('promptText', gsv.promptText),
                _KvEntry('promptLang', gsv.promptLang),
                _KvEntry('seed', gsv.seed?.toString()),
                _KvEntry('topK', gsv.topK?.toString()),
                _KvEntry('batchSize', gsv.batchSize?.toString()),
                _KvEntry('text_split_method', gsv.textSplitMethod),
                _KvEntry('extraRefAudio', gsv.extraRefAudio),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _KvEntry {
  final String key;
  final String? value;
  const _KvEntry(this.key, this.value);
}

/// Renders a vertical list of KV card items with 6px gap,
/// matching the prototype's .kv-list > .kv-item style.
class _KvList extends StatelessWidget {
  final List<_KvEntry> entries;
  const _KvList({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < entries.length; i++) ...[
          if (i > 0) const SizedBox(height: 6),
          _buildItem(entries[i]),
        ],
      ],
    );
  }

  Widget _buildItem(_KvEntry entry) {
    final isEmpty = entry.value == null || entry.value!.isEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: AppTheme.borderRadiusSmall,
      ),
      child: Row(
        children: [
          Text(
            entry.key,
            style: AppTheme.cjkStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isEmpty ? '未设置' : entry.value!,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: isEmpty
                  ? AppTheme.cjkStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    )
                  : AppTheme.cjkStyle(
                      fontSize: 12,
                      fontWeight: 600,
                      color: AppTheme.text,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
