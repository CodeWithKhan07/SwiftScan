import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/resources/theme/app_theme.dart';
import '../scanner/scan_controller.dart';
import 'main_controller.dart';

class MainScreen extends GetView<MainController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      // Use theme background for the scaffold
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: controller.pages,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20, left: 25, right: 25),
          child: Container(
            height: 75,
            decoration: BoxDecoration(
              // Background adapts: White for light, Deep Navy/Card color for dark
              color: isDark
                  ? theme.cardColor.withValues(alpha: 0.98)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : Colors.black).withValues(
                    alpha: 0.1,
                  ),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withValues(
                  alpha: 0.05,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPillItem(
                  context: context,
                  index: 1,
                  icon: Icons.history_rounded,
                  label: "History",
                ),
                GestureDetector(
                  onTap: () {
                    if (controller.currentIndex.value == 0) {
                      Get.find<ScannerController>().takePicture();
                    } else {
                      controller.currentIndex.value = 0;
                    }
                  },
                  child: Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                _buildPillItem(
                  context: context,
                  index: 2,
                  icon: Icons.settings_rounded,
                  label: "Settings",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPillItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Unselected color adapts to dark mode visibility
    final unselectedColor = isDark
        ? AppColors.darkTextBody
        : const Color(0xFF94A3B8);
    final selectedColor = AppColors.primary;

    return InkWell(
      onTap: () => controller.currentIndex.value = index,
      borderRadius: BorderRadius.circular(20),
      child: Obx(() {
        bool isSelected = controller.currentIndex.value == index;
        final activeColor = isSelected ? selectedColor : unselectedColor;

        return SizedBox(
          width: 80,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: activeColor, size: 26),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: activeColor,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
