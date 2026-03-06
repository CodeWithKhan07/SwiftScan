import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/resources/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../data/models/scan_model.dart';
import '../history/history_controller.dart';
import '../widgets/common_widgets.dart';
import 'delete_dialog.dart';

class HistoryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HistoryAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CustomAppBar(
      automaticallyImplyLeading: false,
      title: Text(
        'Scan History',
        style: theme.textTheme.titleMedium?.copyWith(
          fontSize: 17,
          color: isDark ? AppColors.darkTextHeader : AppColors.textHeader,
        ),
      ),
    );
  }
}

class HistorySearch extends GetView<HistoryController> {
  const HistorySearch({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bodyColor = isDark ? AppColors.darkTextBody : AppColors.textBody;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: AppCard(
        padding: EdgeInsets.zero,
        // AppCard already uses theme.cardColor from our previous fix
        child: TextField(
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          onChanged: (v) => controller.searchQuery.value = v,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            color: isDark ? AppColors.darkTextHeader : AppColors.textHeader,
          ),
          decoration: InputDecoration(
            hintText: 'Search documents, dates...',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              color: bodyColor.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: bodyColor.withValues(alpha: 0.4),
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}

class ScanGroup extends StatelessWidget {
  const ScanGroup({super.key, required this.label, required this.items});

  final String label;
  final List<ScanModel> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPinnedGroup = label == 'PINNED';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              if (isPinnedGroup) ...[
                const Icon(
                  Icons.push_pin_rounded,
                  size: 13,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isPinnedGroup
                      ? AppColors.primary
                      : (isDark ? AppColors.darkTextBody : AppColors.textBody),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        ...items.map((scan) => RepaintBoundary(child: ScanCard(scan: scan))),
      ],
    );
  }
}

class ScanCard extends GetView<HistoryController> {
  const ScanCard({super.key, required this.scan});

  final ScanModel scan;

  Future<void> _handleDelete(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteScanDialog(title: scan.title),
    );

    if (confirmed == true) {
      controller.deleteScan(scan.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final headerColor = isDark
        ? AppColors.darkTextHeader
        : AppColors.textHeader;
    final bodyColor = isDark ? AppColors.darkTextBody : AppColors.textBody;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Slidable(
        key: Key(scan.id),
        // Slide actions use alpha backgrounds to blend with dark mode
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.22,
          children: [
            CustomSlidableAction(
              onPressed: (_) => controller.togglePin(scan),
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    scan.isPinned
                        ? Icons.push_pin_outlined
                        : Icons.push_pin_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scan.isPinned ? 'Unpin' : 'Pin',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.22,
          children: [
            CustomSlidableAction(
              onPressed: _handleDelete,
              backgroundColor: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Delete',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => Get.toNamed(RouteNames.scanDetail, arguments: scan),
          child: AppCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ScanThumbnail(imagePath: scan.imagePath),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (scan.isPinned) ...[
                            const Icon(
                              Icons.push_pin_rounded,
                              size: 12,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              scan.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: headerColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('h:mm a').format(scan.dateTime),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 11,
                              color: bodyColor.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        scan.rawText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: bodyColor,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: bodyColor.withValues(alpha: 0.3),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ScanThumbnail extends StatelessWidget {
  const ScanThumbnail({super.key, required this.imagePath});
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final file = File(imagePath);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 58,
        height: 58,
        child: file.existsSync()
            ? Image.file(
                file,
                fit: BoxFit.cover,
                cacheWidth: 116,
                cacheHeight: 116,
                errorBuilder: (_, _, ___) => const ThumbnailFallback(),
              )
            : const ThumbnailFallback(),
      ),
    );
  }
}

class ThumbnailFallback extends StatelessWidget {
  const ThumbnailFallback({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      // Background adjusts to dark mode
      color: isDark
          ? AppColors.primary.withValues(alpha: 0.1)
          : const Color(0xFFEEF2FF),
      child: const Center(
        child: Icon(Icons.article_outlined, color: AppColors.primary, size: 26),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final headerColor = isDark
        ? AppColors.darkTextHeader
        : AppColors.textHeader;
    final bodyColor = isDark ? AppColors.darkTextBody : AppColors.textBody;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.document_scanner_outlined,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No documents found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: headerColor,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Your scanned documents will appear here for easy access.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: bodyColor.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
