import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../controllers/editor_controller.dart';
import '../widgets/app_animations.dart';
import '../widgets/app_components.dart';

class EditorView extends GetView<EditorController> {
  const EditorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BilingualAppBarTitle('معاينة المستند', 'Document Preview'),
        actions: [
          IconButton(
            onPressed: controller.removeCurrentPage,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: Obx(
        () => Stack(
          children: [
            Column(
              children: [
                Expanded(child: _preview(context)),
                _pageStrip(context),
                _toolbar(context),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                    child: FilledButton.icon(
                      onPressed: controller.isProcessing.value
                          ? null
                          : controller.process,
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('متابعة   Continue'),
                    ),
                  ),
                ),
              ],
            ),
            if (controller.isProcessing.value)
              AppProcessingOverlay(label: controller.processMessage.value),
          ],
        ),
      ),
    );
  }

  Widget _preview(BuildContext context) {
    final error = controller.loadError.value;
    if (error != null) {
      // A missing or unreadable capture shows a recoverable state, not a
      // permanent spinner.
      return AppEmptyState(
        icon: Icons.broken_image_outlined,
        ar: 'تعذر تحميل هذه الصفحة',
        en: error,
        actionAr: 'إعادة المحاولة',
        actionEn: 'Retry',
        onAction: controller.retryLoadCurrent,
      );
    }
    final bytes = controller.currentBytes.value;
    if (bytes == null) return const Center(child: CircularProgressIndicator());
    if (controller.cropMode.value) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Crop(
            image: bytes,
            controller: controller.cropController,
            onCropped: controller.onCropResult,
            onStatusChanged: controller.onCropStatus,
            maskColor: Colors.black.withValues(alpha: .45),
            baseColor: Theme.of(context).scaffoldBackgroundColor,
            interactive: true,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Hero(
        tag: 'editor-page-${controller.currentIndex.value}',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Theme.of(context).dividerColor),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: InteractiveViewer(
              minScale: .8,
              maxScale: 5,
              child: Image.memory(bytes, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pageStrip(BuildContext context) => SizedBox(
    height: 78,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      scrollDirection: Axis.horizontal,
      itemCount: controller.paths.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final selected = i == controller.currentIndex.value;
        return AppPressScale(
          pressedScale: .94,
          child: GestureDetector(
            onTap: () => controller.selectPage(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 54,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : Theme.of(context).dividerColor,
                  width: selected ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: AppFileImage(path: controller.paths[i]),
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _toolbar(BuildContext context) {
    if (controller.cropMode.value) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: controller.cancelCrop,
                child: const Text('إلغاء  Cancel'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: controller.cropReady.value
                    ? controller.commitCrop
                    : null,
                child: const Text('قص  Crop'),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Phone layouts use two rows so every edit action stays visible;
          // wider layouts retain a compact single-row toolbar.
          final isWide = constraints.maxWidth >= 600;
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isWide ? 6 : 3,
            // Two bilingual labels need a stable vertical target; deriving
            // height from aspect ratio made text overflow on compact phones.
            mainAxisExtent: 86,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: [
              BilingualIconAction(
                icon: Icons.crop_rounded,
                ar: 'قص',
                en: 'Crop',
                onTap: controller.startCrop,
              ),
              BilingualIconAction(
                icon: Icons.auto_fix_high_rounded,
                ar: 'تلقائي',
                en: 'Auto',
                onTap: () => controller.applyPreset('auto'),
              ),
              BilingualIconAction(
                icon: Icons.text_fields_rounded,
                ar: 'نص واضح',
                en: 'Clear Text',
                onTap: () => controller.applyPreset('clearText'),
              ),
              BilingualIconAction(
                icon: Icons.brightness_high_outlined,
                ar: 'إزالة الظل',
                en: 'Shadows',
                onTap: () => controller.applyPreset('removeShadows'),
              ),
              BilingualIconAction(
                icon: Icons.contrast_rounded,
                ar: 'أبيض وأسود',
                en: 'B&W',
                onTap: () => controller.applyPreset('blackAndWhite'),
              ),
              BilingualIconAction(
                icon: Icons.rotate_right_rounded,
                ar: 'تدوير',
                en: 'Rotate',
                onTap: controller.rotateCurrent,
              ),
            ],
          );
        },
      ),
    );
  }
}
