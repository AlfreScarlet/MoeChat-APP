import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Data holder for an active toast overlay entry.
class ToastEntry {
  /// The overlay entry rendered in the overlay stack.
  final OverlayEntry overlayEntry;

  /// Auto-dismiss timer.
  Timer? timer;

  ToastEntry({required this.overlayEntry});
}

/// A single toast notification rendered as an overlay widget.
///
/// Slides in from the right with a fade animation and shows a
/// countdown progress ring on the close button.
class ToastOverlayWidget extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final Duration duration;
  final int index;
  final VoidCallback onDismiss;

  const ToastOverlayWidget({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.duration,
    required this.index,
    required this.onDismiss,
  });

  @override
  State<ToastOverlayWidget> createState() => _ToastOverlayWidgetState();
}

class _ToastOverlayWidgetState extends State<ToastOverlayWidget>
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
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final topOffset = statusBarHeight + 16.0 + widget.index * 72.0;

    return Positioned(
      top: topOffset,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: widget.onDismiss,
              behavior: HitTestBehavior.translucent,
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
