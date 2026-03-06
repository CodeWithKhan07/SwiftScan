import 'package:flutter/material.dart';

import '../../core/resources/theme/app_theme.dart';

class ScannerOverlay extends StatefulWidget {
  const ScannerOverlay({super.key});

  @override
  State<ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.05,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    // UI Constants
    final double rectWidth = size.width * 0.82;
    final double rectHeight = size.height * 0.5;
    final double verticalOffset = (size.height - rectHeight) / 2;
    final double horizontalOffset = (size.width - rectWidth) / 2;

    return Stack(
      children: [
        // 1. Background Mask (Darkens outside the frame)
        // We keep this dark even in light mode to make the scanner feel immersive
        Positioned.fill(
          child: CustomPaint(
            painter: HolePainter(
              rectWidth: rectWidth,
              rectHeight: rectHeight,
              maskColor: Colors.black.withValues(alpha: 0.65),
            ),
          ),
        ),

        // 2. Animated Scanning Line
        Positioned(
          top: verticalOffset,
          left: horizontalOffset,
          child: RepaintBoundary(
            child: SizedBox(
              width: rectWidth,
              height: rectHeight,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      Positioned(
                        top: _animation.value * rectHeight,
                        left: 20,
                        right: 20,
                        child: child!,
                      ),
                    ],
                  );
                },
                child: const ScanningLineIndicator(),
              ),
            ),
          ),
        ),

        // 3. Frame Border
        Center(
          child: Container(
            width: rectWidth,
            height: rectHeight,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),

        // 4. Instructional Text
        // Explicitly white to ensure legibility over the camera feed
        Positioned(
          top: verticalOffset - 50,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              "Align document within frame",
              style: textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The actual glowy line that moves up and down
class ScanningLineIndicator extends StatelessWidget {
  const ScanningLineIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.8),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.0),
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

class HolePainter extends CustomPainter {
  final double rectWidth;
  final double rectHeight;
  final Color maskColor;

  HolePainter({
    required this.rectWidth,
    required this.rectHeight,
    required this.maskColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = maskColor;

    RRect roundedRect = RRect.fromLTRBR(
      (size.width - rectWidth) / 2,
      (size.height - rectHeight) / 2,
      (size.width + rectWidth) / 2,
      (size.height + rectHeight) / 2,
      const Radius.circular(30),
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(roundedRect),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant HolePainter oldDelegate) {
    return oldDelegate.rectWidth != rectWidth ||
        oldDelegate.rectHeight != rectHeight ||
        oldDelegate.maskColor != maskColor;
  }
}
