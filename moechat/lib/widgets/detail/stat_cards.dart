import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../theme/app_theme.dart';

/// Three side-by-side stat cards showing birthday, height, and weight.
///
/// Each card has a [#f0f2f5] background, 8px border radius, and displays
/// an icon at top, value in middle, and label at bottom.
/// On hover the card translates up 2px and shows a purple shadow.
class StatCards extends StatelessWidget {
  const StatCards({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final assistant = controller.currentAssistant;

      if (assistant == null) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.cake_outlined,
                value: assistant.birthday,
                label: '生日',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                icon: Icons.height,
                value: assistant.height,
                label: '身高',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                icon: Icons.fitness_center_outlined,
                value: assistant.weight,
                label: '体重',
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// A single stat card with hover animation.
///
/// Uses [MouseRegion] to track hover state and [AnimatedContainer] for the
/// smooth translateY(-2px) + purple shadow transition.
class _StatCard extends StatefulWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppTheme.standardDuration,
        curve: AppTheme.standardCurve,
        transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: AppTheme.borderRadiusSmall,
          boxShadow: _isHovered
              ? const [AppTheme.statCardHoverShadow]
              : const [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 18, color: AppTheme.primary),
            const SizedBox(height: 2),
            Text(
              widget.value,
              style: AppTheme.cjkStyle(
                fontSize: 14,
                fontWeight: 700,
                color: AppTheme.text,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 2),
            Text(
              widget.label,
              style: AppTheme.cjkStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
