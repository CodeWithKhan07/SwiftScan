import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../core/resources/theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Define colors based on state and theme
    final Color primaryBg = AppColors.primary;
    final Color secondaryBg = isDark
        ? theme.cardColor
        : Colors.black.withValues(alpha: 0.05);

    // Content color (Text, Icon, and Loader)
    final Color contentColor = isPrimary
        ? Colors.white
        : (isDark ? AppColors.darkTextHeader : AppColors.textHeader);

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? primaryBg : secondaryBg,
        foregroundColor: contentColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: !isPrimary && isDark
              ? BorderSide(color: Colors.white.withValues(alpha: 0.1))
              : BorderSide.none,
        ),
        disabledBackgroundColor: isPrimary
            ? primaryBg.withValues(alpha: 0.5)
            : secondaryBg.withValues(alpha: 0.3),
      ),
      child: isLoading
          ? Center(
              child: SizedBox(
                height: 40, // Increased box size for the ripple effect
                width: 40,
                child: SpinKitRipple(
                  color: contentColor, // Dynamic color based on button style
                  size: 35.0,
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 20,
                    color: contentColor.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: contentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}
