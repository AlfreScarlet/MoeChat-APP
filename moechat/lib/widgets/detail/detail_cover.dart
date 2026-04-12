import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../theme/app_theme.dart';
import '../common/avatar_image.dart';

/// Detail panel cover area.
///
/// 200px tall with a 135° gradient background (#7c5cfc → #b4a0ff → #e8deff),
/// assistant avatar in BoxFit.contain mode, gradient overlay mask,
/// semi-transparent close button (top-right), and assistant name with
/// "当前使用中" tag featuring a green pulsing dot (bottom-left).
class DetailCover extends StatefulWidget {
  const DetailCover({super.key});

  @override
  State<DetailCover> createState() => _DetailCoverState();
}

class _DetailCoverState extends State<DetailCover>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: AppTheme.tagDotPulseDuration,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final assistant = controller.currentAssistant;

      if (assistant == null) {
        return SizedBox(
          height: AppTheme.detailCoverHeight,
          width: double.infinity,
          child: Container(
            decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
            child: const Center(
              child: Icon(Icons.person, size: 64, color: Colors.white54),
            ),
          ),
        );
      }

      return SizedBox(
        height: AppTheme.detailCoverHeight,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Layer 1: Gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
            ),

            // Layer 2: Assistant avatar image (contain mode)
            Positioned.fill(
              child: ReactiveAvatarImage(
                assistantName: assistant.name,
                fallbackAvatar: assistant.avatar,
                fit: BoxFit.contain,
                circular: false,
              ),
            ),

            // Layer 3: Gradient overlay mask (bottom to top)
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: AppTheme.coverOverlay,
                ),
              ),
            ),

            // Layer 4: Close button (top-right)
            Positioned(
              top: 8,
              right: 8,
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Material(
                    color: const Color(0x4D000000), // rgba(0,0,0,0.3)
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: controller.toggleDetailPanel,
                      child: const SizedBox(
                        width: 32,
                        height: 32,
                        child: Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Layer 5: Assistant name + "当前使用中" tag (bottom-left)
            Positioned(
              left: 16,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Assistant name
                  Text(
                    assistant.name,
                    style:
                        AppTheme.cjkStyle(
                          fontSize: 20,
                          fontWeight: 700,
                          color: Colors.white,
                        ).copyWith(
                          shadows: const [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 4,
                              color: Color(0x80000000),
                            ),
                          ],
                        ),
                  ),
                  const SizedBox(height: 4),
                  // "当前使用中" tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x407C5CFC), // purple semi-transparent
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Green pulsing dot
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _pulseAnimation.value,
                              child: child,
                            );
                          },
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppTheme.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '当前使用中',
                          style: AppTheme.cjkStyle(
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
