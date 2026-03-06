import 'package:flutter/material.dart';

import '../../core/resources/theme/app_theme.dart';

class DeleteScanDialog extends StatelessWidget {
  const DeleteScanDialog({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      // Uses theme's cardColor or dialogTheme background
      backgroundColor: theme.cardColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isDark
            ? BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1)
            : BorderSide.none,
      ),
      title: Text(
        'Delete Scan?',
        style: theme.textTheme.titleMedium?.copyWith(
          color: isDark ? AppColors.darkTextHeader : AppColors.textHeader,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        '"$title" will be permanently removed.',
        style: theme.textTheme.bodyMedium?.copyWith(
          height: 1.5,
          color: isDark ? AppColors.darkTextBody : AppColors.textBody,
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: isDark
                ? AppColors.darkTextBody
                : AppColors.textBody,
          ),
          child: Text(
            'Cancel',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextBody : AppColors.textBody,
            ),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 0,
          ),
          child: Text(
            'Delete',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
