import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Reusable text section widget for the detail panel.
///
/// Renders a section header (icon + title) followed by either:
/// - A prompt-block styled text area (when [content] is provided)
/// - A list of card items (when [items] is provided)
/// - A "未设置" empty state (when both are null/empty)
///
/// When [expandable] is true, the prompt block is collapsed by default
/// (same height as the original input box) with an expand/collapse toggle
/// in the header.
class TextSection extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? content;
  final List<String>? items;
  final bool expandable;

  const TextSection({
    super.key,
    required this.icon,
    required this.title,
    this.content,
    this.items,
    this.expandable = false,
  });

  @override
  State<TextSection> createState() => _TextSectionState();
}

class _TextSectionState extends State<TextSection> {
  bool _expanded = false;

  bool get _isEmpty =>
      (widget.content == null || widget.content!.isEmpty) &&
      (widget.items == null || widget.items!.isEmpty);

  bool get _hasItems => widget.items != null && widget.items!.isNotEmpty;

  bool get _hasContent => widget.content != null && widget.content!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          if (_hasItems)
            _buildItemsList()
          else if (_isEmpty)
            _buildEmptyBlock()
          else
            _buildPromptBlock(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          widget.icon,
          size: 14,
          color: AppTheme.primary.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            widget.title,
            style: AppTheme.cjkStyle(
              fontSize: 12,
              fontWeight: 600,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (widget.expandable && _hasContent) ...[
          const SizedBox(width: 4),
          _ExpandToggle(
            expanded: _expanded,
            onTap: () => setState(() => _expanded = !_expanded),
          ),
        ],
      ],
    );
  }

  Widget _buildPromptBlock() {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: AppTheme.borderRadiusSmall,
        border: const Border(
          left: BorderSide(color: AppTheme.primary, width: 3),
        ),
      ),
      child: Text(
        widget.content!,
        style: AppTheme.cjkStyle(
          fontSize: 13,
          height: 1.6,
          color: AppTheme.text,
        ),
      ),
    );

    if (!widget.expandable) return child;

    return AnimatedCrossFade(
      firstChild: Container(
        width: double.infinity,
        height: 60,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: AppTheme.borderRadiusSmall,
          border: const Border(
            left: BorderSide(color: AppTheme.primary, width: 3),
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Text(
          widget.content!,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.cjkStyle(
            fontSize: 13,
            height: 1.6,
            color: AppTheme.text,
          ),
        ),
      ),
      secondChild: child,
      crossFadeState: _expanded
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      duration: AppTheme.standardDuration,
    );
  }

  Widget _buildEmptyBlock() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: AppTheme.borderRadiusSmall,
        border: const Border(
          left: BorderSide(color: AppTheme.border, width: 3),
        ),
      ),
      child: Text(
        '未设置',
        style: AppTheme.cjkStyle(
          fontSize: 13,
          height: 1.6,
          color: AppTheme.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    return Column(
      children: widget.items!
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _ListItem(text: item),
            ),
          )
          .toList(),
    );
  }
}

/// Expand/collapse toggle button shown in the section header.
class _ExpandToggle extends StatefulWidget {
  final bool expanded;
  final VoidCallback onTap;

  const _ExpandToggle({required this.expanded, required this.onTap});

  @override
  State<_ExpandToggle> createState() => _ExpandToggleState();
}

class _ExpandToggleState extends State<_ExpandToggle> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppTheme.standardDuration,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: _hovered
                ? AppTheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.expanded ? '收起' : '展开',
                style: AppTheme.cjkStyle(fontSize: 11, color: AppTheme.primary),
              ),
              Icon(
                widget.expanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: 14,
                color: AppTheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single list item card with hover translate-right effect.
class _ListItem extends StatefulWidget {
  final String text;

  const _ListItem({required this.text});

  @override
  State<_ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<_ListItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppTheme.standardDuration,
        curve: AppTheme.standardCurve,
        transform: Matrix4.translationValues(_hovered ? 4 : 0, 0, 0),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: AppTheme.borderRadiusSmall,
        ),
        child: Text(
          widget.text,
          style: AppTheme.cjkStyle(fontSize: 13, color: AppTheme.text),
        ),
      ),
    );
  }
}
