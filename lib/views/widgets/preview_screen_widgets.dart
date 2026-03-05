import 'dart:async';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '../../core/enums/request_state.dart';
import '../../core/resources/theme/app_theme.dart';
import '../preview/preview_controller.dart';
import 'common_widgets.dart';

class AppBarIconButton extends StatelessWidget {
  const AppBarIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: enabled
            ? AppColors.textHeader
            : AppColors.textBody.withValues(alpha: 0.3),
        size: 22,
      ),
      onPressed: enabled ? onTap : null,
      splashRadius: 22,
    );
  }
}

class CropCornerDot extends StatelessWidget {
  const CropCornerDot({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }
}

class PreviewView extends StatelessWidget {
  const PreviewView({super.key, required this.controller});

  final PreviewController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final displayBytes =
          controller.croppedBytes.value ?? controller.imageBytes.value;

      return Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(child: DotGridBackground()),

          if (displayBytes != null) ImagePreviewCard(bytes: displayBytes),

          Positioned(
            top: 16,
            child: controller.croppedBytes.value != null
                ? const AppBadge(
                    icon: Icons.check_circle_rounded,
                    label: 'Crop applied',
                    color: AppColors.success,
                  )
                : const AppBadge(
                    icon: Icons.info_outline_rounded,
                    label: 'Pinch to zoom  ·  use Crop to adjust',
                    color: AppColors.primary,
                  ),
          ),
        ],
      );
    });
  }
}

class CropView extends StatelessWidget {
  const CropView({
    super.key,
    required this.bytes,
    required this.cropController,
    required this.controller,
  });

  final Uint8List bytes;
  final CropController cropController;
  final PreviewController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: const Color(0xFFF1F3F9)),
        Crop(
          image: bytes,
          controller: cropController,
          onCropped: (result) {
            switch (result) {
              case CropSuccess(:final croppedImage):
                controller.onCropped(croppedImage);
              case CropFailure(:final cause):
                controller.onCropError(cause);
            }
          },
          onStatusChanged: controller.onCropStatusChanged,
          onHistoryChanged: controller.onHistoryChanged,
          baseColor: const Color(0xFFF1F3F9),
          maskColor: Colors.black.withValues(alpha: 0.45),
          cornerDotBuilder: (size, _) => CropCornerDot(size: size),
          interactive: true,
          progressIndicator: const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),

        // Veil while the crop widget initialises
        Obx(
          () => !controller.isCropReady.value
              ? Container(
                  color: const Color(0xFFF1F3F9),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    super.key,
    required this.controller,
    required this.cropController,
  });

  final PreviewController controller;
  final CropController cropController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.isCropping.value
          ? const SizedBox.shrink()
          : ActionBarContent(controller: controller),
    );
  }
}

class ActionBarContent extends StatelessWidget {
  const ActionBarContent({super.key, required this.controller});

  final PreviewController controller;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + bottomPadding),
      child: Row(
        children: [
          IconLabelButton(
            icon: Icons.refresh_rounded,
            label: 'RETAKE',
            onTap: controller.retake,
          ),
          const SizedBox(width: 10),
          Obx(
            () => IconLabelButton(
              icon: Icons.crop_rounded,
              label: 'CROP',
              onTap: controller.enterCropMode,
              active: controller.croppedBytes.value != null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: ScanButton(controller: controller)),
        ],
      ),
    );
  }
}

class ScanButton extends StatelessWidget {
  const ScanButton({super.key, required this.controller});

  final PreviewController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Obx(
      () => SizedBox(
        height: 52,
        child: FilledButton.icon(
          onPressed: controller.processState.value == RequestState.loading
              ? null
              : controller.finalizeAndProcess,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: controller.processState.value == RequestState.loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Icon(Icons.document_scanner_rounded, size: 18),
          label: Text(
            'DONE & SCAN',
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class ImagePreviewCard extends StatelessWidget {
  const ImagePreviewCard({
    super.key,
    required this.bytes,
    this.padding = const EdgeInsets.fromLTRB(24, 20, 24, 12),
    this.borderRadius = 16,
    this.minScale = 0.8,
    this.maxScale = 5.0,
  });

  final Uint8List bytes;
  final EdgeInsets padding;
  final double borderRadius;
  final double minScale;
  final double maxScale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: InteractiveViewer(
            minScale: minScale,
            maxScale: maxScale,
            child: Image.memory(
              bytes,
              fit: BoxFit.contain,
              key: ValueKey(bytes.length),
            ),
          ),
        ),
      ),
    );
  }
}

class OcrProcessingOverlay extends StatefulWidget {
  const OcrProcessingOverlay({super.key, this.onCancel});

  final VoidCallback? onCancel;

  @override
  State<OcrProcessingOverlay> createState() => _OcrProcessingOverlayState();
}

class _OcrProcessingOverlayState extends State<OcrProcessingOverlay> {
  static const _slangs = [
    'Squinting at your pixels... 🔍',
    'Teaching robots to read... 🤖',
    'Decoding the matrix... 💻',
    'Bribing the text gremlins... 👾',
    'Almost got it, no cap... 🧢',
    'Big brain OCR moment... 🧠',
    'Wrangling characters... 🤠',
    'Cooking up your text... 🍳',
    'Running at full drip... 💧',
    'Slay, scan, repeat... ✨',
  ];

  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1800), (_) {
      if (mounted) setState(() => _index = (_index + 1) % _slangs.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return RepaintBoundary(
      child: Container(
        color: Colors.white.withValues(alpha: 0.88),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.onCancel != null)
              Positioned(
                top: 48,
                right: 24,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 32,
                    color: AppColors.textHeader,
                  ),
                  onPressed: widget.onCancel,
                ),
              ),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 32,
                ),
                decoration: GlassStyles.pearlGlass,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SpinKitRipple(color: AppColors.primary),
                    const SizedBox(height: 20),
                    Text(
                      'Reading Text...',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: Text(
                        _slangs[_index],
                        key: ValueKey(_index),
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textBody,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
