import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../controllers/splash_controller.dart';
import '../widgets/app_animations.dart';
import 'app_shell_view.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Match the active theme from frame one to prevent a white startup flash.
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Obx(() {
        final exiting = controller.isExiting.value;
        final reduceMotion = MediaQuery.disableAnimationsOf(context);
        final handoffDuration = reduceMotion
            ? Duration.zero
            : SplashController.fadeOutDuration;
        return Stack(
          fit: StackFit.expand,
          children: [
            // Build the shell behind the splash so data and layout are ready
            // before the cross-fade begins; there can be no blank handoff.
            ExcludeSemantics(
              excluding: !exiting,
              child: AnimatedOpacity(
                opacity: exiting ? 1 : 0,
                duration: handoffDuration,
                curve: AppMotion.emphasizedCurve,
                child: AnimatedScale(
                  scale: exiting ? 1 : .992,
                  duration: handoffDuration,
                  curve: AppMotion.emphasizedCurve,
                  child: const IgnorePointer(child: AppShellView()),
                ),
              ),
            ),
            ExcludeSemantics(
              excluding: exiting,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: exiting ? 0 : 1,
                  duration: handoffDuration,
                  curve: AppMotion.exitCurve,
                  child: ColoredBox(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: reduceMotion
                            ? Duration.zero
                            : SplashController.fadeInDuration,
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) => Opacity(
                          opacity: value.clamp(0, 1),
                          child: Transform.scale(
                            scale: .84 + (.16 * value),
                            child: child,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 82,
                              height: 82,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: .22,
                                    ),
                                    blurRadius: 28,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              // Reuse the production launcher mark so native
                              // startup and the animated Flutter splash match.
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.asset(
                                  'assets/app_logo.png',
                                  fit: BoxFit.cover,
                                  semanticLabel: AppConstants.appName,
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              AppConstants.appNameAr,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppConstants.appName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent(context),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Scan • Extract • Verify • Convert',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Reserve the loader space from the first frame, then reveal
                            // it smoothly without shifting the centered splash content.
                            AnimatedOpacity(
                              opacity: controller.showLoader.value ? 1 : 0,
                              duration: SplashController.loaderFadeDuration,
                              curve: Curves.easeInOut,
                              child: SizedBox.square(
                                dimension: 24,
                                child: CircularProgressIndicator(
                                  key: ValueKey('splashLoadingIndicator'),
                                  strokeWidth: 2.4,
                                  color: AppColors.accent(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
