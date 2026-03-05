import 'package:flutter/material.dart';

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
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? const Color(0xFF6366F1) : Colors.white10,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
        disabledBackgroundColor: isPrimary
            ? const Color(0xFF6366F1).withValues(alpha: 0.5)
            : Colors.white10.withValues(alpha: 0.05),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 20,
                    color: isPrimary ? Colors.white : Colors.white70,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(label, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
    );
  }
}
