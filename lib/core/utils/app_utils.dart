import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppUtils {
  static List<BoxShadow> get _shadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 12,
      offset: const Offset(0, 5),
    ),
  ];

  static void showMsg({required String title, required String msg}) {
    _buildSnackbar(
      title: title,
      msg: msg,
      icon: Icons.info_outline_rounded,
      accentColor: const Color(0xFF6366F1), // Indigo
    );
  }

  static void showError({required String msg}) {
    _buildSnackbar(
      title: "Error",
      msg: msg,
      icon: Icons.error_outline_rounded,
      accentColor: Colors.redAccent,
    );
  }

  static void showSuccess({required String msg}) {
    _buildSnackbar(
      title: "Success",
      msg: msg,
      icon: Icons.check_circle_outline_rounded,
      accentColor: Colors.green.shade600,
    );
  }

  /// Private helper to maintain UI consistency across all types
  static void _buildSnackbar({
    required String title,
    required String msg,
    required IconData icon,
    required Color accentColor,
  }) {
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFFCFCFD),
      // Crisp Off-White
      colorText: Colors.black87,
      titleText: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      messageText: Text(
        msg,
        style: const TextStyle(color: Colors.black87, fontSize: 13),
      ),
      borderRadius: 16,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      duration: const Duration(seconds: 3),
      boxShadows: _shadow,
      icon: Icon(icon, color: accentColor, size: 24),
      leftBarIndicatorColor: accentColor,
      // The "pop" of color
      mainButton: TextButton(
        onPressed: () => Get.back(),
        child: const Text(
          "Dismiss",
          style: TextStyle(color: Colors.black45, fontSize: 12),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      borderWidth: 1,
      borderColor: Colors.black.withValues(alpha: 0.05),
      shouldIconPulse: false,
    );
  }
}
