import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../theme/app_theme.dart';
import '../../models/assistant.dart';
import '../common/avatar_image.dart';

// Layout constants for consistent avatar positioning.
// Avatar center = sidebarCollapsedWidth / 2 = 30px from left edge.
// Avatar left edge = 30 - 20 = 10px.
const double _avatarSize = 40.0;
const double _avatarLeft = 10.0; // left inset so avatar centers at 30px
const double _itemHeight = 56.0; // fixed row height
const double _selectionInset = 4.0; // inset from sidebar edge for selection box

/// Left sidebar: gradient title, scrollable assistant list, settings button.
/// Supports collapsed mode — icons/avatars stay fixed, only text fades out.
class Sidebar extends GetView<HomeController> {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final collapsed = controller.isSidebarCollapsed.value;

      return AnimatedContainer(
        duration: AppTheme.panelDuration,
        curve: AppTheme.panelCurve,
        width: collapsed
            ? AppTheme.sidebarCollapsedWidth
            : AppTheme.sidebarWidth,
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(color: AppTheme.sidebarBg),
        child: Column(
          children: [
            _SidebarHeader(collapsed: collapsed),
            Expanded(child: _SidebarListView(collapsed: collapsed)),
            const Divider(color: AppTheme.sidebarActive, height: 1),
            _SidebarIconTextButton(
              collapsed: collapsed,
              icon: Icons.add,
              label: '添加助手',
              onTap: () => controller.showEditModal(),
            ),
            const Divider(color: AppTheme.sidebarActive, height: 1),
            _SidebarIconTextButton(
              collapsed: collapsed,
              icon: Icons.settings,
              label: '设置',
              onTap: controller.showSettingsModal,
            ),
          ],
        ),
      );
    });
  }
}

/// Header row: title + chevron button. Icon stays fixed, title fades.
class _SidebarHeader extends GetView<HomeController> {
  final bool collapsed;
  const _SidebarHeader({required this.collapsed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: AnimatedOpacity(
              opacity: collapsed ? 0.0 : 1.0,
              duration: AppTheme.panelDuration,
              curve: AppTheme.panelCurve,
              child: collapsed
                  ? const SizedBox.shrink()
                  : ShaderMask(
                      shaderCallback: (bounds) =>
                          AppTheme.titleGradient.createShader(bounds),
                      child: const Text(
                        'MoeChat',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                      ),
                    ),
            ),
          ),
          IconButton(
            icon: AnimatedRotation(
              turns: collapsed ? 0.0 : 0.5,
              duration: AppTheme.panelDuration,
              curve: AppTheme.panelCurve,
              child: const Icon(
                Icons.chevron_right,
                color: AppTheme.sidebarText,
              ),
            ),
            iconSize: 20,
            onPressed: controller.toggleSidebar,
            tooltip: collapsed ? '展开侧边栏' : '收起侧边栏',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

/// A bottom button row: icon stays fixed at avatar-center position, label fades.
class _SidebarIconTextButton extends StatefulWidget {
  final bool collapsed;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SidebarIconTextButton({
    required this.collapsed,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_SidebarIconTextButton> createState() => _SidebarIconTextButtonState();
}

class _SidebarIconTextButtonState extends State<_SidebarIconTextButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    // Icon center aligns with avatar center (30px from left).
    // Icon is 18px wide, so left padding = 30 - 9 = 21px.
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppTheme.standardDuration,
          color: _hovering ? AppTheme.sidebarHover : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              // Fixed-width spacer so icon center = 30px
              SizedBox(
                width: AppTheme.sidebarCollapsedWidth,
                child: Center(
                  child: Icon(
                    widget.icon,
                    color: AppTheme.sidebarText,
                    size: 18,
                  ),
                ),
              ),
              // Label — fades out
              Expanded(
                child: AnimatedOpacity(
                  opacity: widget.collapsed ? 0.0 : 1.0,
                  duration: AppTheme.panelDuration,
                  curve: AppTheme.panelCurve,
                  child: Text(
                    widget.label,
                    style: AppTheme.cjkStyle(
                      fontSize: 14,
                      color: AppTheme.sidebarText,
                    ),
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Unified list view for assistants.
class _SidebarListView extends StatefulWidget {
  final bool collapsed;
  const _SidebarListView({required this.collapsed});

  @override
  State<_SidebarListView> createState() => _SidebarListViewState();
}

class _SidebarListViewState extends State<_SidebarListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final selectedIndex = controller.selectedAssistantIndex.value;
      final assistants = controller.assistants;

      if (controller.isLoadingAssistants.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppTheme.sidebarText),
        );
      }

      if (assistants.isEmpty) {
        return AnimatedOpacity(
          opacity: widget.collapsed ? 0.0 : 1.0,
          duration: AppTheme.panelDuration,
          child: Center(
            child: Text(
              '暂无助手\n请在设置中配置 API 地址',
              textAlign: TextAlign.center,
              style: AppTheme.cjkStyle(
                fontSize: 14,
                color: AppTheme.sidebarText.withValues(alpha: 0.6),
              ),
            ),
          ),
        );
      }

      return Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: assistants.length,
          itemBuilder: (_, index) => _SidebarAssistantItem(
            assistant: assistants[index],
            isSelected: selectedIndex == index,
            collapsed: widget.collapsed,
            onTap: () => controller.selectAssistant(index),
          ),
        ),
      );
    });
  }
}

/// Single assistant row — avatar always at fixed position, text fades.
///
/// Layout strategy:
///   - The entire row uses a fixed height [_itemHeight].
///   - A selection/hover background box is inset [_selectionInset] from
///     each side of the sidebar, so it's always visually centered.
///   - Inside the box, the avatar is positioned so its center is always
///     at sidebarCollapsedWidth/2 = 30px from the sidebar's left edge.
///   - Text sits to the right of the avatar and fades on collapse.
class _SidebarAssistantItem extends StatefulWidget {
  final Assistant assistant;
  final bool isSelected;
  final bool collapsed;
  final VoidCallback onTap;

  const _SidebarAssistantItem({
    required this.assistant,
    required this.isSelected,
    required this.collapsed,
    required this.onTap,
  });

  @override
  State<_SidebarAssistantItem> createState() => _SidebarAssistantItemState();
}

class _SidebarAssistantItemState extends State<_SidebarAssistantItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.isSelected
        ? AppTheme.sidebarActive
        : _hovering
        ? AppTheme.sidebarHover
        : Colors.transparent;

    // Selection box is inset _selectionInset from each side of the sidebar.
    // Avatar left edge inside the box = _avatarLeft - _selectionInset.
    const avatarLeftInBox = _avatarLeft - _selectionInset;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: _itemHeight,
          margin: const EdgeInsets.symmetric(
            horizontal: _selectionInset,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppTheme.borderRadiusSmall,
          ),
          child: Row(
            children: [
              // Fixed spacer to position avatar
              const SizedBox(width: avatarLeftInBox),
              // Avatar — fixed size, never moves
              ReactiveAvatarImage(
                assistantName: widget.assistant.name,
                fallbackAvatar: widget.assistant.avatar,
                size: _avatarSize,
              ),
              // Text — fades out, clipped so it doesn't overflow when collapsed
              Expanded(
                child: ClipRect(
                  child: AnimatedOpacity(
                    opacity: widget.collapsed ? 0.0 : 1.0,
                    duration: AppTheme.panelDuration,
                    curve: AppTheme.panelCurve,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.assistant.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.cjkStyle(
                              fontSize: 14,
                              fontWeight: 700,
                              color: AppTheme.sidebarText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.assistant.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.cjkStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
