import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/resources/theme/app_theme.dart';
import '../scandetails/scandetail_controller.dart';
import '../widgets/common_widgets.dart';

class ScanDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ScanDetailAppBar({super.key, required this.controller});

  final ScanDetailController controller;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CustomAppBar(
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.textHeader,
          size: 20,
        ),
        onPressed: () => Get.back(),
      ),
      title: Column(
        children: [
          Text(
            controller.scan.title,
            style: textTheme.titleMedium?.copyWith(fontSize: 15),
          ),
          Text(
            DateFormat('MMM d, yyyy · h:mm a').format(controller.scan.dateTime),
            style: textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: AppColors.textBody,
            ),
          ),
        ],
      ),
      actions: [
        Obx(
          () => controller.isDeleting.value
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.error,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 22,
                  ),
                  onPressed: () => controller.promptDelete(context),
                ),
        ),
      ],
    );
  }
}

class ViewToggle extends StatelessWidget {
  const ViewToggle({super.key, required this.controller});

  final ScanDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final showImage = controller.showImage.value;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            ToggleTab(
              label: 'Image',
              icon: Icons.image_outlined,
              active: showImage,
              onTap: () => controller.showImage.value = true,
            ),
            ToggleTab(
              label: 'Text',
              icon: Icons.subject_rounded,
              active: !showImage,
              onTap: () => controller.showImage.value = false,
            ),
          ],
        ),
      );
    });
  }
}

class ToggleTab extends StatelessWidget {
  const ToggleTab({
    super.key,
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: active ? Colors.white : AppColors.textBody,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: textTheme.labelMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : AppColors.textBody,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageView extends StatelessWidget {
  const ImageView({super.key, required this.controller});

  final ScanDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ViewToggle(controller: controller),
        Expanded(
          child: Stack(
            children: [
              const Positioned.fill(child: DotGridBackground()),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: controller.imageExists
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              blurRadius: 30,
                              offset: const Offset(0, 12),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: InteractiveViewer(
                            minScale: 0.8,
                            maxScale: 6.0,
                            child: Image.file(
                              File(controller.scan.imagePath),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      )
                    : const AppEmptyState(
                        icon: Icons.broken_image_outlined,
                        title: 'Image not available',
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TextView extends StatelessWidget {
  const TextView({super.key, required this.controller});

  final ScanDetailController controller;

  @override
  Widget build(BuildContext context) {
    final text = controller.scan.rawText;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        ViewToggle(controller: controller),
        if (controller.scan.category.isNotEmpty ||
            controller.scan.detectedDates.isNotEmpty)
          MetaChips(scan: controller.scan),
        Expanded(
          child: text.isEmpty
              ? const AppEmptyState(
                  icon: Icons.text_fields_rounded,
                  title: 'No text was recognised',
                )
              : Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        physics: const BouncingScrollPhysics(),
                        child: SelectableText(
                          text,
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: 15,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class MetaChips extends StatelessWidget {
  const MetaChips({super.key, required this.scan});

  final dynamic scan;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        children: [
          if (scan.category.isNotEmpty && scan.category != 'General')
            AppBadge(
              icon: Icons.label_outline_rounded,
              label: scan.category,
              color: AppColors.primary,
              margin: const EdgeInsets.only(right: 8),
            ),
          ...scan.detectedDates.map<Widget>(
            (d) => AppBadge(
              icon: Icons.calendar_today_outlined,
              label: d,
              color: AppColors.success,
              margin: const EdgeInsets.only(right: 8),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionBar extends StatelessWidget {
  const ActionBar({super.key, required this.controller});

  final ScanDetailController controller;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        border: Border(
          top: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottom),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    IconLabelButton(
                      icon: Icons.copy_rounded,
                      label: 'COPY',
                      onTap: controller.copyText,
                      height: 52,
                    ),
                    const SizedBox(width: 8),
                    IconLabelButton(
                      icon: Icons.g_translate_rounded,
                      label: 'TRANSLATE',
                      onTap: controller.translateText,
                      height: 52,
                    ),
                    const SizedBox(width: 12),
                    IconLabelButton(
                      icon: Icons.share_outlined,
                      label: 'TEXT',
                      onTap: controller.shareText,
                      height: 52,
                    ),
                    const SizedBox(width: 8),
                    if (controller.imageExists) ...[
                      IconLabelButton(
                        icon: Icons.image_outlined,
                        label: 'IMAGE',
                        onTap: controller.shareImage,
                        height: 52,
                      ),
                      const SizedBox(width: 8),
                    ],
                    IconLabelButton(
                      icon: Icons.picture_as_pdf,
                      label: 'Save As Pdf',
                      onTap: controller.exportToPdf,
                      height: 52,
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: () => Get.back(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.document_scanner_outlined, size: 18),
                label: Text(
                  'RE-SCAN',
                  style: textTheme.labelLarge?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
