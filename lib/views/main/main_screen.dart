import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../scanner/scan_controller.dart';
import 'main_controller.dart';

class MainScreen extends GetView<MainController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
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
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPillItem(
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
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),

                // Right Item: Settings
                _buildPillItem(
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
    required int index,
    required IconData icon,
    required String label,
  }) {
    return InkWell(
      onTap: () => controller.currentIndex.value = index,
      borderRadius: BorderRadius.circular(20),
      child: Obx(() {
        bool isSelected = controller.currentIndex.value == index;
        return SizedBox(
          width: 80,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF6366F1)
                    : const Color(0xFF94A3B8),
                size: 26,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
