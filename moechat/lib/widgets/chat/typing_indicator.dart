import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Typing indicator with three bouncing purple dots.
///
/// Each dot is 6x6px, colored [AppTheme.primary] (#7c5cfc).
/// The animation has a 0.8s period with dots delayed by 0ms, 150ms, 300ms.
/// Dots bounce up by 4px and opacity goes from 0.3 to 1.0.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// Delay fractions within the 0.8s cycle for each dot.
  /// 0ms / 800ms = 0.0, 150ms / 800ms = 0.1875, 300ms / 800ms = 0.375
  static const List<double> _delayFractions = [0.0, 0.1875, 0.375];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTheme.typingDuration, // 800ms
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Compute a 0→1→0 bounce value for a dot given its delay fraction.
  double _dotValue(double controllerValue, double delay) {
    // Shift the controller value by the delay, wrapping around [0, 1).
    final shifted = (controllerValue - delay) % 1.0;
    // Use a sine curve over the first half of the cycle for a smooth bounce,
    // and stay at rest for the second half.
    if (shifted < 0.5) {
      return math.sin(shifted * 2 * math.pi);
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final value = _dotValue(_controller.value, _delayFractions[index]);
            final opacity = 0.3 + 0.7 * value; // 0.3 → 1.0
            final translateY = -4.0 * value; // bounce up by 4px

            return Padding(
              padding: EdgeInsets.only(right: index < 2 ? 4.0 : 0.0),
              child: Transform.translate(
                offset: Offset(0, translateY),
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
