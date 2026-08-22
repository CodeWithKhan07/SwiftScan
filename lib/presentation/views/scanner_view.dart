import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../controllers/scanner_controller.dart';
import '../widgets/app_animations.dart';

class ScannerView extends GetView<ScannerController> {
  const ScannerView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      fit: StackFit.expand,
      children: [
        // Camerawesome owns preview lifecycle while the route is active.
        CameraAwesomeBuilder.custom(
          saveConfig: SaveConfig.photo(),
          sensorConfig: SensorConfig.single(
            aspectRatio: CameraAspectRatios.ratio_16_9,
          ),
          builder: (cameraState, preview) => cameraState.when(
            onPhotoMode: (state) {
              controller.attachCamera(state);
              return const SizedBox.expand();
            },
            onPreparingCamera: (_) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
        ),
        const IgnorePointer(child: _ScannerOverlay()),
        ScannerControls(controller: controller),
      ],
    ),
  );
}

/// Reactive scanner controls kept separate from the native camera preview.
class ScannerControls extends StatelessWidget {
  const ScannerControls({super.key, required this.controller});

  final ScannerController controller;

  @override
  Widget build(BuildContext context) => SafeArea(
    // The camera route is already constrained above Android's navigation bar.
    // Ignoring its occasionally stale bottom inset prevents giant overflows.
    bottom: false,
    child: Obx(() {
      // Read every observable in this callback so GetX tracks this subtree.
      final mode = controller.mode.value;
      final flashOn = controller.flashOn.value;
      final busy = controller.isCapturing.value;
      final batchCount = controller.batchPaths.length;

      return Column(
        children: [
          _TopControls(
            flashOn: flashOn,
            busy: busy,
            onClose: busy ? null : controller.close,
            onAutoScan: controller.autoScan,
            onFlash: controller.toggleFlash,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _ModeSelector(
              selectedMode: mode,
              enabled: !busy,
              onChanged: controller.setMode,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _ScanInstruction(mode: mode, batchCount: batchCount),
          ),
          const SizedBox(height: 16),
          // Fixed padding avoids duplicate or stale MediaQuery bottom insets.
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: _CaptureControls(
              mode: mode,
              batchCount: batchCount,
              busy: busy,
              onGallery: controller.pickFromGallery,
              onCapture: controller.capture,
              onAutoScan: controller.autoScan,
              onFinishBatch: controller.finishBatch,
            ),
          ),
        ],
      );
    }),
  );
}

class _ScanInstruction extends StatelessWidget {
  const _ScanInstruction({required this.mode, required this.batchCount});

  final ScanMode mode;
  final int batchCount;

  @override
  Widget build(BuildContext context) {
    final (arabic, english) = switch (mode) {
      ScanMode.invoice => (
        'ضع الفاتورة داخل الإطار',
        'Place invoice inside the frame',
      ),
      ScanMode.document => (
        'ضع المستند داخل الإطار',
        'Place document inside the frame',
      ),
      ScanMode.batch => ('$batchCount صفحات', '$batchCount pages'),
    };

    // Separate directions keep counters and punctuation stable in RTL mode.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          arabic,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.25,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          english,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textDirection: TextDirection.ltr,
          style: TextStyle(
            color: Colors.white.withValues(alpha: .82),
            fontSize: 13.5,
            height: 1.25,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TopControls extends StatelessWidget {
  const _TopControls({
    required this.flashOn,
    required this.busy,
    required this.onClose,
    required this.onAutoScan,
    required this.onFlash,
  });

  final bool flashOn;
  final bool busy;
  final VoidCallback? onClose;
  final VoidCallback onAutoScan;
  final VoidCallback onFlash;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Row(
      children: [
        _RoundControl(icon: Icons.close_rounded, onTap: onClose),
        const Spacer(),
        _RoundControl(
          icon: Icons.auto_awesome_outlined,
          label: 'Auto',
          onTap: busy ? null : onAutoScan,
        ),
        const SizedBox(width: 8),
        _RoundControl(
          icon: flashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
          onTap: busy ? null : onFlash,
        ),
      ],
    ),
  );
}

class _CaptureControls extends StatelessWidget {
  const _CaptureControls({
    required this.mode,
    required this.batchCount,
    required this.busy,
    required this.onGallery,
    required this.onCapture,
    required this.onAutoScan,
    required this.onFinishBatch,
  });

  final ScanMode mode;
  final int batchCount;
  final bool busy;
  final VoidCallback onGallery;
  final VoidCallback onCapture;
  final VoidCallback onAutoScan;
  final VoidCallback onFinishBatch;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _RoundControl(
        icon: Icons.photo_library_outlined,
        onTap: busy ? null : onGallery,
      ),
      AppPressScale(
        enabled: !busy,
        pressedScale: .92,
        child: Semantics(
          label: 'Capture / التقاط',
          button: true,
          enabled: !busy,
          child: GestureDetector(
            onTap: busy ? null : onCapture,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: busy ? 68 : 74,
              height: busy ? 68 : 74,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: busy ? .55 : 1),
                  width: 3,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: busy ? .65 : 1),
                ),
                child: const Center(
                  child: SizedBox.square(
                    dimension: 48,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      if (mode == ScanMode.batch && batchCount > 0)
        _RoundControl(
          icon: Icons.check_rounded,
          label: '$batchCount',
          onTap: busy ? null : onFinishBatch,
        )
      else
        _RoundControl(
          icon: Icons.document_scanner_outlined,
          label: 'Auto',
          onTap: busy ? null : onAutoScan,
        ),
    ],
  );
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.selectedMode,
    required this.enabled,
    required this.onChanged,
  });

  final ScanMode selectedMode;
  final bool enabled;
  final ValueChanged<ScanMode> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: .52),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withValues(alpha: .18)),
    ),
    child: Row(
      children: [
        _item(ScanMode.invoice, 'فاتورة\nInvoice'),
        _item(ScanMode.document, 'مستند\nDocument'),
        _item(ScanMode.batch, 'متعدد\nBatch'),
      ],
    ),
  );

  Widget _item(ScanMode mode, String label) {
    final selected = selectedMode == mode;
    return Expanded(
      child: InkWell(
        onTap: enabled ? () => onChanged(mode) : null,
        borderRadius: BorderRadius.circular(11),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 52),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(
                alpha: enabled ? (selected ? 1 : .78) : .45,
              ),
              fontSize: 13,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundControl extends StatelessWidget {
  const _RoundControl({required this.icon, this.onTap, this.label});

  final IconData icon;
  final VoidCallback? onTap;
  final String? label;

  @override
  Widget build(BuildContext context) => AppPressScale(
    enabled: onTap != null,
    pressedScale: .94,
    child: Material(
      color: Colors.black.withValues(alpha: onTap == null ? .28 : .52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withValues(alpha: .18)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: label == null ? 48 : 64,
            minHeight: 48,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white.withValues(
                    alpha: onTap == null ? .45 : 1,
                  ),
                  size: 22,
                ),
                if (label != null) ...[
                  const SizedBox(width: 5),
                  Text(
                    label!,
                    style: TextStyle(
                      color: Colors.white.withValues(
                        alpha: onTap == null ? .45 : 1,
                      ),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: const _ScannerPainter(),
    child: const SizedBox.expand(),
  );
}

class _ScannerPainter extends CustomPainter {
  const _ScannerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      22,
      size.height * .18,
      size.width - 44,
      size.height * .48,
    );
    final path = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(18)));
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = Colors.black.withValues(alpha: .32));
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(18)),
      Paint()
        ..color = Colors.white.withValues(alpha: .75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    final corner = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    const length = 26.0;
    for (final points in [
      [
        Offset(rect.left, rect.top + length),
        Offset(rect.left, rect.top),
        Offset(rect.left + length, rect.top),
      ],
      [
        Offset(rect.right - length, rect.top),
        Offset(rect.right, rect.top),
        Offset(rect.right, rect.top + length),
      ],
      [
        Offset(rect.left, rect.bottom - length),
        Offset(rect.left, rect.bottom),
        Offset(rect.left + length, rect.bottom),
      ],
      [
        Offset(rect.right - length, rect.bottom),
        Offset(rect.right, rect.bottom),
        Offset(rect.right, rect.bottom - length),
      ],
    ]) {
      final cornerPath = Path()
        ..moveTo(points[0].dx, points[0].dy)
        ..lineTo(points[1].dx, points[1].dy)
        ..lineTo(points[2].dx, points[2].dy);
      canvas.drawPath(cornerPath, corner);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
