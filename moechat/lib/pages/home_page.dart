import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../controllers/settings_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/sidebar/sidebar.dart';
import '../widgets/chat/chat_area.dart';
import '../widgets/detail/detail_panel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // SettingsController._autoConnect() 已在 onInit 中触发，
    // 这里作为后备：如果 API 已初始化但助手列表为空，尝试加载
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = Get.find<SettingsController>();
      final home = Get.find<HomeController>();
      if (settings.isApiInitialized.value && home.assistants.isEmpty) {
        home.loadAssistants(silent: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),
          const Expanded(child: ChatArea()),
          _AnimatedDetailPanel(),
        ],
      ),
    );
  }
}

/// Wraps DetailPanel in an AnimatedContainer that reacts to
/// isDetailPanelOpen. Uses a StatefulWidget with a GetX worker
/// to avoid nesting Obx around DetailPanel's own Obx children.
class _AnimatedDetailPanel extends StatefulWidget {
  @override
  State<_AnimatedDetailPanel> createState() => _AnimatedDetailPanelState();
}

class _AnimatedDetailPanelState extends State<_AnimatedDetailPanel> {
  late final HomeController _controller;
  late final Worker _worker;
  late final Worker _assistantWorker;
  late final Worker _listWorker;
  bool _isOpen = true;
  bool _hasAssistant = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<HomeController>();
    _isOpen = _controller.isDetailPanelOpen.value;
    _hasAssistant = _controller.currentAssistant != null;
    _worker = ever(_controller.isDetailPanelOpen, (open) {
      setState(() => _isOpen = open);
    });
    _assistantWorker = ever(_controller.selectedAssistantIndex, (_) {
      setState(() => _hasAssistant = _controller.currentAssistant != null);
    });
    _listWorker = ever(_controller.assistants, (_) {
      setState(() => _hasAssistant = _controller.currentAssistant != null);
    });
  }

  @override
  void dispose() {
    _worker.dispose();
    _assistantWorker.dispose();
    _listWorker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final show = _isOpen && _hasAssistant;
    // Use AnimatedContainer for the outer width, but let the child always
    // lay out at full panel width via Align + SizedBox. The parent's
    // clipBehavior clips the overflow during animation so no RenderFlex errors.
    return AnimatedContainer(
      duration: AppTheme.panelDuration,
      curve: AppTheme.panelCurve,
      width: show ? AppTheme.detailPanelWidth : 0,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(),
      child: OverflowBox(
        alignment: Alignment.centerLeft,
        minWidth: AppTheme.detailPanelWidth,
        maxWidth: AppTheme.detailPanelWidth,
        child: const DetailPanel(),
      ),
    );
  }
}
