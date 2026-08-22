import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../config/app_config.dart';
import '../../presentation/controllers/account_controller.dart';
import '../../presentation/controllers/app_shell_controller.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../../presentation/controllers/conversion_controller.dart';
import '../../presentation/controllers/document_controller.dart';
import '../../presentation/controllers/editor_controller.dart';
import '../../presentation/controllers/home_controller.dart';
import '../../presentation/controllers/invoice_detail_controller.dart';
import '../../presentation/controllers/invoices_controller.dart';
import '../../presentation/controllers/onboarding_controller.dart';
import '../../presentation/controllers/qr_controller.dart';
import '../../presentation/controllers/scanner_controller.dart';
import '../../presentation/controllers/splash_controller.dart';
import '../../presentation/controllers/subscription_controller.dart';
import '../../presentation/controllers/tools_controller.dart';
import '../../presentation/views/app_shell_view.dart';
import '../../presentation/views/auth_view.dart';
import '../../presentation/views/conversion_view.dart';
import '../../presentation/views/document_view.dart';
import '../../presentation/views/editor_view.dart';
import '../../presentation/views/invoice_detail_view.dart';
import '../../presentation/views/onboarding_view.dart';
import '../../presentation/views/qr_view.dart';
import '../../presentation/views/scanner_view.dart';
import '../../presentation/views/splash_view.dart';
import '../../presentation/views/subscription_view.dart';
import '../../presentation/widgets/app_animations.dart';
import '../di/service_locator.dart';
import 'app_routes.dart';

abstract final class AppPages {
  static final pages = <GetPage<dynamic>>[
    _page<OnboardingController>(AppRoutes.onboarding, OnboardingView.new),
    GetPage<dynamic>(
      name: AppRoutes.splash,
      page: SplashView.new,
      // The splash controller must be created eagerly because the static
      // splash UI does not read GetView.controller to trigger a lazy factory.
      binding: BindingsBuilder(() {
        // Pre-bind shell tabs so SplashView can render the complete home page
        // underneath its outgoing layer before navigation is committed.
        _bindShell();
        Get.put<SplashController>(sl<SplashController>());
      }),
      customTransition: AppRouteTransition(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.shell,
      page: AppShellView.new,
      binding: BindingsBuilder(_bindShell),
      // SplashView already cross-fades to this identical, pre-rendered shell.
      transition: Transition.noTransition,
    ),
    _page<ScannerController>(AppRoutes.scanner, ScannerView.new),
    _page<EditorController>(AppRoutes.editor, EditorView.new),
    _page<DocumentController>(AppRoutes.document, DocumentView.new),
    _page<InvoiceDetailController>(AppRoutes.invoice, InvoiceDetailView.new),
    GetPage<dynamic>(
      name: AppRoutes.qr,
      page: QrView.new,
      binding: BindingsBuilder(() => Get.lazyPut<QrController>(() => sl())),
      middlewares: [_KsaFeatureMiddleware()],
      customTransition: AppRouteTransition(),
    ),
    _page<ConversionController>(AppRoutes.conversion, ConversionView.new),
    _page<AuthController>(AppRoutes.auth, AuthView.new),
    _page<SubscriptionController>(AppRoutes.subscription, SubscriptionView.new),
  ];

  static GetPage<dynamic> _page<T extends GetxController>(
    String name,
    Widget Function() view,
  ) => GetPage<dynamic>(
    name: name,
    page: view,
    binding: BindingsBuilder(() => Get.lazyPut<T>(() => sl<T>())),
    customTransition: AppRouteTransition(),
  );

  static void _bindShell() {
    if (!Get.isRegistered<AppShellController>()) {
      Get.put<AppShellController>(sl<AppShellController>(), permanent: true);
    }
    _lazy<HomeController>(fenix: true);
    _lazy<InvoicesController>(fenix: true);
    _lazy<ToolsController>(fenix: true);
    _lazy<AccountController>(fenix: true);
  }

  static void _lazy<T extends GetxController>({bool fenix = false}) {
    if (!Get.isRegistered<T>()) {
      Get.lazyPut<T>(() => sl<T>(), fenix: fenix);
    }
  }
}

class _KsaFeatureMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) => AppConfig.supportsZatca
      ? null
      : const RouteSettings(name: AppRoutes.shell);
}
