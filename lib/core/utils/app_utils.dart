import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../resources/theme/app_theme.dart';

class AppUtils {
  static List<BoxShadow> _shadow(bool isDark) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
      blurRadius: 12,
      offset: const Offset(0, 5),
    ),
  ];

  static void showMsg({required String title, required String msg}) {
    _buildSnackbar(
      title: title,
      msg: msg,
      icon: Icons.info_outline_rounded,
      accentColor: AppColors.primary,
    );
  }

  static void showError({required String msg}) {
    _buildSnackbar(
      title: "Error",
      msg: msg,
      icon: Icons.error_outline_rounded,
      accentColor: AppColors.error,
    );
  }

  static void showSuccess({required String msg}) {
    _buildSnackbar(
      title: "Success",
      msg: msg,
      icon: Icons.check_circle_outline_rounded,
      accentColor: AppColors.success,
    );
  }

  /// Private helper to maintain UI consistency across all types
  static void _buildSnackbar({
    required String title,
    required String msg,
    required IconData icon,
    required Color accentColor,
  }) {
    final context = Get.context;
    if (context == null) return;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Resolve dynamic colors based on theme
    final bgColor = isDark ? theme.cardColor : const Color(0xFFFCFCFD);
    final titleColor = isDark ? AppColors.darkTextHeader : Colors.black;
    final bodyColor = isDark ? AppColors.darkTextBody : Colors.black87;
    final borderColor = (isDark ? Colors.white : Colors.black).withValues(
      alpha: 0.08,
    );

    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: bgColor,
      colorText: bodyColor,
      titleText: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      messageText: Text(msg, style: TextStyle(color: bodyColor, fontSize: 13)),
      borderRadius: 16,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      duration: const Duration(seconds: 3),
      boxShadows: _shadow(isDark),
      icon: Icon(icon, color: accentColor, size: 24),
      leftBarIndicatorColor: accentColor,
      mainButton: TextButton(
        onPressed: () => Get.back(),
        child: Text(
          "Dismiss",
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextBody.withValues(alpha: 0.5)
                : Colors.black45,
            fontSize: 12,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      borderWidth: 1,
      borderColor: borderColor,
      shouldIconPulse: false,
    );
  }
}
