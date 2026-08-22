import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../controllers/app_lock_controller.dart';
import 'app_components.dart';

class LockOverlay extends StatelessWidget {
  const LockOverlay({super.key, required this.controller});
  final AppLockController controller;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: AppColors.accentSurface(context),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.onAccentSurface(context),
                  size: 34,
                ),
              ),
              const SizedBox(height: 20),
              BilingualText(
                'فاتورة لينس مقفل',
                'FatoraLens is locked',
                align: TextAlign.center,
                arStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                enStyle: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: controller.authenticating.value
                    ? null
                    : controller.unlock,
                icon: const Icon(Icons.fingerprint_rounded),
                label: const Text('فتح التطبيق   Unlock'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
