import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'app/di/service_locator.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'core/constants/app_constants.dart';
import 'core/localization/app_translations.dart';
import 'core/theme/app_theme.dart';
import 'presentation/controllers/ads_controller.dart';
import 'presentation/controllers/app_lock_controller.dart';
import 'presentation/controllers/app_locale_controller.dart';
import 'presentation/controllers/app_shell_controller.dart';
import 'presentation/controllers/app_setup_controller.dart';
import 'presentation/widgets/app_animations.dart';
import 'presentation/widgets/lock_overlay.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  Get.put<AppShellController>(sl<AppShellController>(), permanent: true);
  Get.put<AppSetupController>(sl<AppSetupController>(), permanent: true);
  Get.put<AppLockController>(sl<AppLockController>(), permanent: true);
  Get.put<AppLocaleController>(sl<AppLocaleController>(), permanent: true);
  Get.put<AdsController>(sl<AdsController>(), permanent: true);
  runApp(const FatoraLensApp());
}

class FatoraLensApp extends StatelessWidget {
  const FatoraLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<AppShellController>();
    final lock = Get.find<AppLockController>();
    final locale = Get.find<AppLocaleController>();
    final setup = Get.find<AppSetupController>();
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: shell.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
      translations: AppTranslations(),
      locale: locale.locale,
      fallbackLocale: const Locale('en', 'US'),
      supportedLocales: AppTranslations.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      // New installations enter setup directly; returning users retain the
      // synchronized splash-to-home transition.
      initialRoute: setup.needsOnboarding
          ? AppRoutes.onboarding
          : AppRoutes.splash,
      getPages: AppPages.pages,
      defaultTransition: Transition.cupertino,
      transitionDuration: AppMotion.route,
      builder: (context, child) => Obx(() {
        final routedContent = child ?? const SizedBox.expand();

        // Pass the Navigator directly through during normal use. The previous
        // permanent Stack shrink-wrapped routed Scaffolds on the Android frame.
        final content = lock.locked.value
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(child: routedContent),
                  Positioned.fill(child: LockOverlay(controller: lock)),
                ],
              )
            : routedContent;

        return Directionality(
          textDirection: locale.isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: content,
        );
      }),
    );
  }
}
