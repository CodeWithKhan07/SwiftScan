import 'package:flutter/material.dart';

import '../../core/resources/theme/app_theme.dart';

class DeleteScanDialog extends StatelessWidget {
  const DeleteScanDialog({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Delete Scan?',
        // Using titleMedium from your AppTheme
        style: textTheme.titleMedium,
      ),
      content: Text(
        '"$title" will be permanently removed.',
        style: textTheme.bodyMedium?.copyWith(height: 1.5),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(foregroundColor: AppColors.textBody),
          child: Text(
            'Cancel',
            // Using labelLarge for button text
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textBody,
            ),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: Text(
            'Delete',
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
