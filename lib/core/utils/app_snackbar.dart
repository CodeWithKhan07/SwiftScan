import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

abstract final class AppSnackbar {
  static void success(String message) =>
      _show(message, AppColors.success, Icons.check_circle_outline_rounded);
  static void error(String message) =>
      _show(message, AppColors.error, Icons.error_outline_rounded);
  static void info(String message) =>
      _show(message, AppColors.primary, Icons.info_outline_rounded);

  static void _show(String message, Color color, IconData icon) {
    Get.rawSnackbar(
      messageText: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      icon: Icon(icon, color: Colors.white),
      backgroundColor: color,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}
