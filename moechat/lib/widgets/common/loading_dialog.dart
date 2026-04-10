import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';

/// Loading dialog widget displayed via Get.dialog().
///
/// Accepts service state as parameters instead of a direct
/// `LoadingService` reference, keeping the widget decoupled
/// from the service layer.
class LoadingDialog extends StatelessWidget {
  /// Reactive loading message displayed below the spinner.
  final RxString loadingMessage;

  /// Whether the cancel button is visible.
  final RxBool canCancel;

  /// Called when the user taps the cancel button.
  final VoidCallback? onCancel;

  const LoadingDialog({
    super.key,
    required this.loadingMessage,
    required this.canCancel,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 阻止返回键关闭
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => Text(
                    loadingMessage.value.isEmpty
                        ? '加载中...'
                        : loadingMessage.value,
                    style: AppTheme.cjkStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => canCancel.value
                      ? TextButton(
                          onPressed: onCancel,
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.textSecondary,
                          ),
                          child: Text(
                            '取消',
                            style: AppTheme.cjkStyle(fontSize: 13),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
