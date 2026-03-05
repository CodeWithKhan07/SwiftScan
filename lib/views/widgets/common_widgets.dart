import 'package:flutter/material.dart';

import '../../core/resources/theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
  });

  final Widget title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      leading: leading,
      title: title,
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: Colors.black.withValues(alpha: 0.06)),
      ),
    );
  }
}

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.margin,
  });

  final IconData icon;
  final String label;
  final Color color;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    // Accessing theme text style
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: margin ?? const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.22), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 6),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class IconLabelButton extends StatelessWidget {
  const IconLabelButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.height = 52,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = active ? AppColors.primary : AppColors.textBody;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: height,
        constraints: const BoxConstraints(minWidth: 58),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.07)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? AppColors.primary.withValues(alpha: 0.35)
                : Colors.black.withValues(alpha: 0.08),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DotGridBackground extends StatelessWidget {
  const DotGridBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: CustomPaint(painter: _DotGridPainter()));
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 24.0;
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.07)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.5;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 52,
            color: AppColors.textBody.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.textBody.withValues(alpha: 0.4),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textBody.withValues(alpha: 0.3),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
