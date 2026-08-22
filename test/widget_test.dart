import 'package:fatoralens/app/routes/app_routes.dart';
import 'package:fatoralens/presentation/controllers/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('splash controller replaces splash with the app shell', (
    tester,
  ) async {
    // Navigation commits exactly when the synchronized splash/shell cross-fade
    // completes, leaving no transparent waiting interval between both views.
    expect(
      SplashController.navigationDelay,
      SplashController.exitDelay + SplashController.fadeOutDuration,
    );
    // Use the production controller with lightweight route widgets so this
    // regression test isolates splash lifecycle and navigation behavior.
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.splash,
        getPages: [
          GetPage<void>(
            name: AppRoutes.splash,
            page: () => const Scaffold(body: Text('Splash')),
            binding: BindingsBuilder(
              () => Get.put<SplashController>(SplashController()),
            ),
          ),
          GetPage<void>(
            name: AppRoutes.shell,
            page: () => const Scaffold(body: Text('Shell')),
          ),
        ],
      ),
    );

    expect(find.text('Splash'), findsOneWidget);
    final controller = Get.find<SplashController>();
    expect(controller.showLoader.value, isFalse);
    expect(controller.isExiting.value, isFalse);

    // The loader appears after fade-in while the splash remains visible.
    await tester.pump(SplashController.fadeInDuration);
    expect(find.text('Splash'), findsOneWidget);
    expect(controller.showLoader.value, isTrue);
    expect(controller.isExiting.value, isFalse);

    // The handoff begins first, then commits the shell as the fade completes.
    await tester.pump(
      SplashController.exitDelay - SplashController.fadeInDuration,
    );
    expect(controller.isExiting.value, isTrue);

    await tester.pump(SplashController.fadeOutDuration);
    await tester.pumpAndSettle();
    expect(find.text('Shell'), findsOneWidget);
    expect(find.text('Splash'), findsNothing);
  });
}
