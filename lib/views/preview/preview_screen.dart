import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/enums/request_state.dart';
import '../../core/resources/theme/app_theme.dart';
import '../widgets/preview_screen_widgets.dart';
import 'preview_controller.dart';

class PreviewScreen extends GetView<PreviewController> {
  const PreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cropController = CropController();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _PreviewAppBar(
        controller: controller,
        cropController: cropController,
      ),
      body: Obx(() {
        final bytes = controller.imageBytes.value;
        if (bytes == null) {
          return const Center(child: SpinKitRipple(color: AppColors.primary));
        }
        return Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Obx(
                    () => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      child: controller.isCropping.value
                          ? CropView(
                              key: const ValueKey('crop'),
                              bytes: bytes,
                              cropController: cropController,
                              controller: controller,
                            )
                          : PreviewView(
                              key: const ValueKey('preview'),
                              controller: controller,
                            ),
                    ),
                  ),
                ),
                BottomActionBar(
                  controller: controller,
                  cropController: cropController,
                ),
              ],
            ),
            Obx(
              () => controller.processState.value == RequestState.loading
                  ? OcrProcessingOverlay(onCancel: controller.cancelProcessing)
                  : const SizedBox.shrink(),
            ),
          ],
        );
      }),
    );
  }
}

class _PreviewAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _PreviewAppBar({
    required this.controller,
    required this.cropController,
  });

  final PreviewController controller;
  final CropController cropController;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final headerColor = isDark
        ? AppColors.darkTextHeader
        : AppColors.textHeader;

    return AppBar(
      // Background adapts to theme
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
        ),
      ),
      leading: Obx(
        () => IconButton(
          icon: Icon(
            controller.isCropping.value
                ? Icons.close_rounded
                : Icons.arrow_back_ios_new_rounded,
            color: headerColor,
            size: 20,
          ),
          onPressed: controller.isCropping.value
              ? controller.cancelCrop
              : controller.retake,
        ),
      ),
      title: Obx(
        () => AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            controller.isCropping.value ? 'Crop Image' : 'Preview',
            key: ValueKey(controller.isCropping.value),
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: headerColor,
            ),
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        Obx(
          () => controller.isCropping.value
              ? _CropAppBarActions(
                  cropController: cropController,
                  canUndo: controller.canUndo.value,
                  canRedo: controller.canRedo.value,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _CropAppBarActions extends StatelessWidget {
  const _CropAppBarActions({
    required this.cropController,
    required this.canUndo,
    required this.canRedo,
  });

  final CropController cropController;
  final bool canUndo;
  final bool canRedo;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBarIconButton(
          icon: Icons.undo_rounded,
          enabled: canUndo,
          onTap: cropController.undo,
        ),
        AppBarIconButton(
          icon: Icons.redo_rounded,
          enabled: canRedo,
          onTap: cropController.redo,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12, left: 4),
          child: FilledButton(
            onPressed: cropController.crop,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              minimumSize: const Size(0, 34),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }
}
