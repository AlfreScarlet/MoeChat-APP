import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../widgets/common/loading_dialog.dart';
import '../widgets/common/toast_widget.dart';

/// 全局加载服务 - 管理加载状态和 Toast 提示
///
/// 使用 Get.dialog() 替代 OverlayEntry，从根本上消除竞态条件：
/// - OverlayEntry 的 insert/remove 是异步操作，快速 show/hide 会导致状态不一致
/// - Get.dialog() 是同步操作，由 GetX 内部堆栈管理，更加可靠
class LoadingService extends GetxService {
  static LoadingService get to => Get.find();

  // ==================== Loading (使用 Get.dialog) ====================

  final isLoading = false.obs;
  final loadingMessage = ''.obs;
  final canCancel = false.obs;
  final _isDialogOpen = false.obs;
  VoidCallback? onCancelCallback;
  final _cancelSignal = false.obs;

  void showLoading({
    String message = '加载中...',
    bool showCancel = true,
    VoidCallback? onCancel,
  }) {
    // 如果已有对话框打开，先关闭它
    if (_isDialogOpen.value) {
      hideLoading();
    }

    _cancelSignal.value = false;
    loadingMessage.value = message;
    isLoading.value = true;
    canCancel.value = showCancel;
    onCancelCallback = onCancel;

    // 使用 Get.dialog 替代 OverlayEntry，同步操作避免竞态条件
    _isDialogOpen.value = true;
    Get.dialog(
      LoadingDialog(
        loadingMessage: loadingMessage,
        canCancel: canCancel,
        onCancel: _onCancel,
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      transitionDuration: Duration.zero, // 无动画，立即显示
      useSafeArea: false,
    ).then((_) {
      // dialog 关闭时更新状态
      // （无论是调用 Get.back() 还是其他方式关闭）
      _isDialogOpen.value = false;
    });
  }

  void hideLoading() {
    // 只有当对话框确实打开时才调用 Get.back()
    // 避免误关闭其他对话框（如 SettingsModal）
    if (_isDialogOpen.value && Get.isDialogOpen == true) {
      Get.back();
    }
    _isDialogOpen.value = false;
    isLoading.value = false;
    loadingMessage.value = '';
    canCancel.value = false;
    onCancelCallback = null;
  }

  /// 异步隐藏 loading（兼容旧代码）
  Future<void> hideLoadingAsync() async {
    hideLoading();
    // 延迟一帧确保状态更新
    await Future.delayed(Duration.zero);
  }

  void forceHideAll() {
    if (_isDialogOpen.value && Get.isDialogOpen == true) {
      Get.back();
    }
    _isDialogOpen.value = false;
    isLoading.value = false;
    loadingMessage.value = '';
    canCancel.value = false;
    onCancelCallback = null;
    _cancelSignal.value = false;
    _clearAllToasts();
  }

  bool get isCancelled => _cancelSignal.value;

  void updateMessage(String message) {
    loadingMessage.value = message;
  }

  void _onCancel() {
    _cancelSignal.value = true;
    final callback = onCancelCallback;
    hideLoading();
    callback?.call();
  }

  // ==================== Toast (保留 OverlayEntry 实现) ====================

  /// Toast 保持使用 OverlayEntry，因为：
  /// - Toast 显示时间较长（3-4秒），没有快速 show/hide 问题
  /// - 需要支持多个 Toast 同时显示（堆叠效果）
  /// - Get.dialog 同一时间只能显示一个对话框
  final List<ToastEntry> _activeToasts = [];
  static const int _maxToasts = 3;

  void showSuccess(String message, {String? title}) {
    _showToast(
      title: title ?? '成功',
      message: message,
      icon: Icons.check_circle_rounded,
      color: AppTheme.success,
    );
  }

  void showError(String message, {String? title}) {
    _showToast(
      title: title ?? '错误',
      message: message,
      icon: Icons.error_rounded,
      color: AppTheme.danger,
      duration: const Duration(seconds: 4),
    );
  }

  void showInfo(String message, {String? title}) {
    _showToast(
      title: title ?? '提示',
      message: message,
      icon: Icons.info_rounded,
      color: AppTheme.primary,
    );
  }

  void _showToast({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    Duration duration = const Duration(seconds: 3),
  }) {
    // 超出上限时移除最早的
    while (_activeToasts.length >= _maxToasts) {
      _dismissToast(_activeToasts.first);
    }

    final overlay = _getOverlay();
    if (overlay == null) return;

    late final ToastEntry entry;
    final overlayEntry = OverlayEntry(
      builder: (context) => ToastOverlayWidget(
        title: title,
        message: message,
        icon: icon,
        color: color,
        duration: duration,
        index: _activeToasts
            .indexWhere((e) => e == entry)
            .clamp(0, _maxToasts - 1),
        onDismiss: () => _dismissToast(entry),
      ),
    );

    entry = ToastEntry(overlayEntry: overlayEntry);
    _activeToasts.add(entry);

    overlay.insert(overlayEntry);

    // 自动移除的定时器（动画时间 + 显示时间）
    entry.timer = Timer(duration + const Duration(milliseconds: 300), () {
      _dismissToast(entry);
    });

    // 刷新所有 toast 的位置
    _rebuildAllToasts();
  }

  void _dismissToast(ToastEntry entry) {
    if (!_activeToasts.contains(entry)) return;
    entry.timer?.cancel();
    _activeToasts.remove(entry);
    if (entry.overlayEntry.mounted) {
      entry.overlayEntry.remove();
    }
    _rebuildAllToasts();
  }

  void _rebuildAllToasts() {
    for (final entry in _activeToasts) {
      if (entry.overlayEntry.mounted) {
        entry.overlayEntry.markNeedsBuild();
      }
    }
  }

  void _clearAllToasts() {
    for (final entry in List.of(_activeToasts)) {
      entry.timer?.cancel();
      if (entry.overlayEntry.mounted) {
        entry.overlayEntry.remove();
      }
    }
    _activeToasts.clear();
  }

  // ==================== Overlay 获取 (仅用于 Toast) ====================

  OverlayState? _getOverlay() {
    // 尝试多种方式获取 overlay，增加容错
    for (int i = 0; i < 3; i++) {
      try {
        final nav = Get.key.currentState;
        if (nav?.overlay != null) return nav!.overlay;
      } catch (_) {}

      try {
        final ctx = Get.overlayContext ?? Get.context;
        if (ctx != null) {
          final overlay = Overlay.maybeOf(ctx);
          if (overlay != null) return overlay;
        }
      } catch (_) {}

      // 如果不是最后一次尝试，短暂延迟后重试
      if (i < 2) {
        continue;
      }
    }
    return null;
  }

  // ==================== wrapLoading ====================

  Future<T?> wrapLoading<T>(
    Future<T> Function() future, {
    String message = '加载中...',
    String? successMessage,
    String? errorMessage,
    bool showErrorToast = true,
    bool showCancel = true,
    VoidCallback? onCancel,
  }) async {
    _cancelSignal.value = false;
    showLoading(message: message, showCancel: showCancel, onCancel: onCancel);
    try {
      final result = await future();
      if (_cancelSignal.value) {
        hideLoading();
        return null;
      }
      hideLoading();
      if (successMessage != null) showSuccess(successMessage);
      return result;
    } catch (e) {
      hideLoading();
      if (_cancelSignal.value) return null;
      if (showErrorToast) showError(errorMessage ?? e.toString());
      return null;
    }
  }
}
