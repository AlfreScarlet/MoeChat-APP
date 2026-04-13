import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../theme/app_theme.dart';
import 'detail_cover.dart';
import 'stat_cards.dart';
import 'status_section.dart';
import 'text_section.dart';
import 'gsv_settings.dart';
import 'feature_settings.dart';
import 'emotion_section.dart';
import 'assets_section.dart';
import 'detail_actions.dart';

/// Right-side detail panel container.
///
/// Each child section manages its own Obx reactivity independently.
class DetailPanel extends StatefulWidget {
  const DetailPanel({super.key});

  @override
  State<DetailPanel> createState() => _DetailPanelState();
}

class _DetailPanelState extends State<DetailPanel> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.panelBg,
        border: Border(left: BorderSide(color: AppTheme.border)),
      ),
      child: Column(
        children: [
          const DetailCover(),
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: false,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    StatCards(),
                    StatusSection(),
                    _TextSectionsBlock(),
                    GsvSettingsWidget(),
                    FeatureSettingsWidget(),
                    EmotionSection(),
                    AssetsSection(),
                    DetailActions(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dedicated widget for all TextSection blocks.
/// Uses a single Obx to reactively rebuild when the selected assistant changes.
class _TextSectionsBlock extends StatelessWidget {
  const _TextSectionsBlock();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final assistant = controller.currentAssistant;

      if (assistant == null) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextSection(
            icon: Icons.textsms_outlined,
            title: '额外描述',
            content: assistant.extraDescription,
          ),
          TextSection(
            icon: Icons.description_outlined,
            title: '角色设定',
            content: assistant.roleDescription,
            expandable: true,
          ),
          TextSection(
            icon: Icons.favorite_outline,
            title: '性格特点',
            content: assistant.personality,
            expandable: true,
          ),
          TextSection(
            icon: Icons.person_outline,
            title: '用户设定',
            content: assistant.userSetting,
            expandable: true,
          ),
          TextSection(
            icon: Icons.chat_outlined,
            title: '对话案例',
            items: assistant.messageExamples,
          ),
          TextSection(
            icon: Icons.code,
            title: '自定义提示词',
            content: assistant.customPrompt,
            expandable: true,
          ),
          TextSection(
            icon: Icons.chat_bubble_outline,
            title: '开场白',
            items: assistant.greetings,
          ),
        ],
      );
    });
  }
}
