import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// 流式出字动画组件
///
/// 当 [text] 增长时，新增的字符会以 fade + slide-up 动画逐渐显现。
/// 已有字符直接显示，不重复动画。
class StreamingText extends StatefulWidget {
  const StreamingText({
    super.key,
    required this.text,
    required this.style,
    this.isStreaming = false,
  });

  final String text;
  final TextStyle style;

  /// 是否仍在流式接收中（true 时末尾显示光标闪烁）
  final bool isStreaming;

  @override
  State<StreamingText> createState() => _StreamingTextState();
}

class _StreamingTextState extends State<StreamingText>
    with TickerProviderStateMixin {
  // 每批新增字符的动画控制器列表
  // 每次 text 增长时，为新增部分创建一个 AnimationController
  final List<_TextChunk> _chunks = [];

  // 光标闪烁
  late final AnimationController _cursorController;
  late final Animation<double> _cursorOpacity;

  String _lastText = '';

  @override
  void initState() {
    super.initState();

    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _cursorOpacity = CurvedAnimation(
      parent: _cursorController,
      curve: Curves.easeInOut,
    );

    // 初始文本直接显示，不做动画
    if (widget.text.isNotEmpty) {
      _chunks.add(
        _TextChunk(
          text: widget.text,
          controller: null,
          opacity: null,
          offset: null,
        ),
      );
      _lastText = widget.text;
    }
  }

  @override
  void didUpdateWidget(StreamingText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.text.length > _lastText.length &&
        widget.text.startsWith(_lastText)) {
      // 有新增字符，为新增部分创建动画
      final newChars = widget.text.substring(_lastText.length);
      _addAnimatedChunk(newChars);
      _lastText = widget.text;
    } else if (widget.text != _lastText) {
      // 文本被替换（如切换对话），重置
      _disposeChunks();
      _chunks.clear();
      if (widget.text.isNotEmpty) {
        _chunks.add(
          _TextChunk(
            text: widget.text,
            controller: null,
            opacity: null,
            offset: null,
          ),
        );
      }
      _lastText = widget.text;
    }
  }

  void _addAnimatedChunk(String newText) {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    final opacity = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    final offset = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    _chunks.add(
      _TextChunk(
        text: newText,
        controller: controller,
        opacity: opacity,
        offset: offset,
      ),
    );

    controller.forward();
  }

  void _disposeChunks() {
    for (final chunk in _chunks) {
      chunk.controller?.dispose();
    }
  }

  @override
  void dispose() {
    _disposeChunks();
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        ..._chunks.where((c) => c.controller != null).map((c) => c.controller!),
        _cursorController,
      ]),
      builder: (context, _) {
        return Text.rich(
          TextSpan(
            children: [
              // 已有字符（无动画）
              for (final chunk in _chunks)
                if (chunk.controller == null || chunk.controller!.isCompleted)
                  TextSpan(text: chunk.text)
                else
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: FadeTransition(
                      opacity: chunk.opacity!,
                      child: SlideTransition(
                        position: chunk.offset!,
                        child: Text(chunk.text, style: widget.style),
                      ),
                    ),
                  ),
              // 光标
              if (widget.isStreaming)
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: FadeTransition(
                    opacity: _cursorOpacity,
                    child: Text(
                      '▋',
                      style: widget.style.copyWith(
                        color: AppTheme.primary,
                        fontSize: (widget.style.fontSize ?? 14) * 0.85,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          style: widget.style,
        );
      },
    );
  }
}

class _TextChunk {
  final String text;
  final AnimationController? controller;
  final Animation<double>? opacity;
  final Animation<Offset>? offset;

  _TextChunk({
    required this.text,
    required this.controller,
    required this.opacity,
    required this.offset,
  });
}
