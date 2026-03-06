import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/resources/theme/app_theme.dart';

class CustomSnackbar extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color accentColor;

  const CustomSnackbar({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.accentColor,
  });

  /// Static helper to trigger the GetX snackbar with this UI
  void show() {
    final context = Get.context;
    if (context == null) return;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.rawSnackbar(
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isDark ? theme.cardColor : const Color(0xFFFCFCFD),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      borderRadius: 16,
      duration: const Duration(seconds: 3),
      borderColor: (isDark ? Colors.white : Colors.black).withValues(
        alpha: 0.08,
      ),
      borderWidth: 1,
      leftBarIndicatorColor: accentColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      messageText: this, // Pass this widget instance as the content
      mainButton: TextButton(
        onPressed: () => Get.back(),
        child: Text(
          "Dismiss",
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextBody.withValues(alpha: 0.4)
                : Colors.black45,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: accentColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextHeader : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                message,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextBody : Colors.black87,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
