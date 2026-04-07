import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

/// 全局加载服务 - 管理加载状态和 Toast 提示
class LoadingService extends GetxService {
  static LoadingService get to => Get.find();

  // ==================== Loading ====================

  final isLoading = false.obs;
  final loadingMessage = ''.obs;
  final canCancel = false.obs;
  VoidCallback? onCancelCallback;
  OverlayEntry? _overlayEntry;
  final _cancelSignal = false.obs;

  void showLoading({
    String message = '加载中...',
    bool showCancel = true,
    VoidCallback? onCancel,
  }) {
    hideLoading();
    _cancelSignal.value = false;
    loadingMessage.value = message;
    isLoading.value = true;
    canCancel.value = showCancel;
    onCancelCallback = onCancel;

    _overlayEntry = OverlayEntry(
      builder: (context) => _LoadingOverlay(service: this),
    );
    final overlay = _getOverlay();
    if (overlay != null) overlay.insert(_overlayEntry!);
  }

  void hideLoading() {
    final entry = _overlayEntry;
    _overlayEntry = null;
    if (entry != null && entry.mounted) entry.remove();
    isLoading.value = false;
    loadingMessage.value = '';
    canCancel.value = false;
    onCancelCallback = null;
  }

  void forceHideAll() {
    hideLoading();
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

  // ==================== Toast ====================

  /// 每个 toast 独立一个 OverlayEntry，避免共享状态导致的生命周期问题
  final List<_ToastEntry> _activeToasts = [];
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

    late final _ToastEntry entry;
    final overlayEntry = OverlayEntry(
      builder: (context) => _ToastOverlayWidget(
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

    entry = _ToastEntry(overlayEntry: overlayEntry);
    _activeToasts.add(entry);

    overlay.insert(overlayEntry);

    // 自动移除的定时器（动画时间 + 显示时间）
    entry.timer = Timer(duration + const Duration(milliseconds: 300), () {
      _dismissToast(entry);
    });

    // 刷新所有 toast 的位置
    _rebuildAllToasts();
  }

  void _dismissToast(_ToastEntry entry) {
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

  // ==================== Overlay 获取 ====================

  OverlayState? _getOverlay() {
    try {
      final nav = Get.key.currentState;
      if (nav != null) return nav.overlay;
    } catch (_) {}
    try {
      final ctx = Get.overlayContext ?? Get.context;
      if (ctx != null) return Overlay.maybeOf(ctx);
    } catch (_) {}
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

// ==================== 数据模型 ====================

class _ToastEntry {
  final OverlayEntry overlayEntry;
  Timer? timer;

  _ToastEntry({required this.overlayEntry});
}

// ==================== Loading Overlay ====================

class _LoadingOverlay extends StatelessWidget {
  final LoadingService service;
  const _LoadingOverlay({required this.service});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.3),
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
                  service.loadingMessage.value,
                  style: AppTheme.cjkStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => service.canCancel.value
                    ? TextButton(
                        onPressed: service._onCancel,
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
    );
  }
}

// ==================== 单个 Toast Overlay Widget ====================

class _ToastOverlayWidget extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final Duration duration;
  final int index;
  final VoidCallback onDismiss;

  const _ToastOverlayWidget({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.duration,
    required this.index,
    required this.onDismiss,
  });

  @override
  State<_ToastOverlayWidget> createState() => _ToastOverlayWidgetState();
}

class _ToastOverlayWidgetState extends State<_ToastOverlayWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  double _timerProgress = 1.0;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();

    // 倒计时进度条
    final totalMs = widget.duration.inMilliseconds;
    const tickMs = 50;
    _progressTimer = Timer.periodic(const Duration(milliseconds: tickMs), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      final elapsed = t.tick * tickMs;
      setState(() {
        _timerProgress = (1.0 - elapsed / totalMs).clamp(0.0, 1.0);
      });
      if (elapsed >= totalMs) {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topOffset = 16.0 + widget.index * 72.0;

    return Positioned(
      top: topOffset,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 300,
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border(left: BorderSide(color: widget.color, width: 3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(widget.icon, color: widget.color, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: AppTheme.cjkStyle(
                            fontSize: 12,
                            fontWeight: 600,
                            color: AppTheme.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.message,
                          style: AppTheme.cjkStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  _buildCloseButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: SizedBox(
          width: 24,
          height: 24,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  value: _timerProgress,
                  strokeWidth: 2,
                  backgroundColor: AppTheme.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.color.withValues(alpha: 0.5),
                  ),
                ),
              ),
              Icon(Icons.close, size: 12, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
