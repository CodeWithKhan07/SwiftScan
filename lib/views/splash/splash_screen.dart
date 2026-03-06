import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/resources/theme/app_theme.dart';
import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Dynamic Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        theme.scaffoldBackgroundColor,
                        theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
                      ]
                    : [const Color(0xFFFDFDFD), const Color(0xFFF5F7FA)],
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 2. Logo Container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? theme.cardColor : Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(
                          alpha: isDark ? 0.2 : 0.1,
                        ),
                        blurRadius: 60,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.document_scanner_rounded,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 32),

                // 3. App Title
                Text(
                  "SwiftScan",
                  style: theme.textTheme.displayLarge?.copyWith(
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextHeader
                        : const Color(0xFF1E1B4B),
                  ),
                ),
              ],
            ),
          ),

          // 4. Loading Indicator Section
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildThickProgressBar(context),
                  const SizedBox(height: 20),
                  Text(
                    "INITIALIZING",
                    style: theme.textTheme.bodyMedium!.copyWith(
                      letterSpacing: 4.0,
                      color: isDark
                          ? AppColors.darkTextBody
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThickProgressBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 200,
      height: 12,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: LinearProgressIndicator(
          backgroundColor: isDark
              ? Colors.black.withValues(alpha: 0.2)
              : const Color(0xFFF1F5F9),
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 12,
        ),
      ),
    );
  }
}
