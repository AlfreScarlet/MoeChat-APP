import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../theme/app_theme.dart';

/// Chat input bar with voice call button, text field, and send button.
///
/// - White background with top border line (#e0e0e0)
/// - Voice call button (38x38px) toggles active state via [HomeController.toggleCallActive]
/// - Rounded text input (24px radius, placeholder "输入消息...", purple focus border)
/// - Purple send button (38x38px, white arrow icon)
class ChatInputBar extends StatefulWidget {
  const ChatInputBar({super.key});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  bool _isSendHovered = false;
  bool _isCallHovered = false;

  // 文本输入控制器
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: AppTheme.callPulseDuration,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _syncPulse(bool isActive) {
    if (isActive && !_pulseController.isAnimating) {
      _pulseController.repeat();
    } else if (!isActive && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final controller = Get.find<HomeController>();
    if (controller.currentAssistant == null) return;

    controller.sendTextMessage(text);
    _textController.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.chatBg,
        border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
      ),
      child: Row(
        children: [
          // Voice call button
          Obx(() {
            final isActive = controller.isCallActive.value;
            _syncPulse(isActive);
            return _buildCallButton(isActive, controller);
          }),
          const SizedBox(width: 12),
          // Text input
          Expanded(child: _buildTextInput()),
          const SizedBox(width: 12),
          // Send button
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildCallButton(bool isActive, HomeController controller) {
    // CSS prototype animation:
    //   @keyframes call-pulse {
    //     0%, 100% { box-shadow: 0 0 0 0 rgba(230,69,83,.4); }
    //     50%      { box-shadow: 0 0 0 8px rgba(230,69,83,0); }
    //   }
    // The shadow expands from 0→8px spread while fading from 0.4→0 opacity,
    // then snaps back. CSS `infinite` = repeat without reverse.
    return MouseRegion(
      onEnter: (_) => setState(() => _isCallHovered = true),
      onExit: (_) => setState(() => _isCallHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: controller.toggleCallActive,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            // Map controller value (0→1) to the CSS keyframe:
            // 0%→50%: spread 0→8, opacity 0.4→0
            // 50%→100%: spread 8→0 (snap back), opacity 0→0.4
            final double t = _pulseController.value;
            final double phase = t <= 0.5 ? t * 2.0 : (1.0 - t) * 2.0;
            final double spread = isActive ? phase * 8.0 : 0.0;
            final double opacity = isActive ? 0.4 * (1.0 - phase) : 0.0;

            return Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? AppTheme.danger
                    : _isCallHovered
                    ? AppTheme.primaryLight
                    : Colors.transparent,
                border: isActive
                    ? Border.all(color: AppTheme.danger, width: 2)
                    : Border.all(color: AppTheme.primary, width: 2),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppTheme.danger.withValues(alpha: opacity),
                          spreadRadius: spread,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                Icons.phone,
                size: 18,
                color: isActive ? Colors.white : AppTheme.primary,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextInput() {
    return TextField(
      controller: _textController,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: '输入消息...',
        hintStyle: AppTheme.cjkStyle(
          color: AppTheme.textSecondary,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        filled: false,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppTheme.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        isDense: true,
      ),
      style: AppTheme.cjkStyle(fontSize: 14, color: AppTheme.text),
      onSubmitted: (_) => _sendMessage(),
    );
  }

  Widget _buildSendButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isSendHovered = true),
      onExit: (_) => setState(() => _isSendHovered = false),
      child: GestureDetector(
        onTap: _sendMessage,
        child: AnimatedContainer(
          duration: AppTheme.standardDuration,
          curve: AppTheme.standardCurve,
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isSendHovered ? AppTheme.primaryHover : AppTheme.primary,
          ),
          child: const Icon(Icons.arrow_upward, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}
