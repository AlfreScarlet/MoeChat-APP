import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../theme/app_theme.dart';

/// Action buttons at the bottom of the detail panel.
///
/// Contains two full-width stacked buttons:
/// - "编辑助手" purple filled button with edit icon → triggers EditModal
/// - "删除助手" red outlined button
class DetailActions extends StatelessWidget {
  const DetailActions({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final assistant = controller.currentAssistant;

      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // "编辑助手" purple filled button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: assistant == null
                    ? null
                    : () => controller.showEditModal(assistant: assistant),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.primary.withValues(
                    alpha: 0.3,
                  ),
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 8),
                    Text('编辑助手'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // "删除助手" red outlined button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: assistant == null
                    ? null
                    : () => controller.showDeleteConfirmDialog(assistant.name),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.danger,
                  disabledForegroundColor: AppTheme.danger.withValues(
                    alpha: 0.3,
                  ),
                  side: BorderSide(
                    color: assistant == null
                        ? AppTheme.danger.withValues(alpha: 0.3)
                        : AppTheme.danger,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                ),
                child: const Text('删除助手'),
              ),
            ),
          ],
        ),
      );
    });
  }
}
