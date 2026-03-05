import 'package:get/get.dart';
import 'package:swiftscan/core/bindings/app_bindings.dart';
import 'package:swiftscan/views/auth/auth_gate_screen.dart';
import 'package:swiftscan/views/history/history_screen.dart';
import 'package:swiftscan/views/main/main_screen.dart';
import 'package:swiftscan/views/preview/preview_screen.dart';
import 'package:swiftscan/views/scanner/scanner_screen.dart';
import 'package:swiftscan/views/settings/settings_screen.dart';
import 'package:swiftscan/views/splash/splash_screen.dart';

import '../../views/scandetails/scan_detail_screen.dart';
import '../../views/translation/translation_screen.dart';

class RouteNames {
  static const String splash = '/splash';
  static const String authGate = '/auth-gate';
  static const String main = '/main';
  static const String scanner = '/scanner';
  static const String history = '/history';
  static const String preview = '/preview';
  static const String scanDetail = '/scan-detail';
  static const String settings = '/settings';
  static const String translation = '/translation';
}

class AppRoutes {
  static final appRoutes = [
    GetPage(
      name: RouteNames.splash,
      page: () => SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: RouteNames.authGate,
      page: () => const AuthGateScreen(),
    ),
    GetPage(
      name: RouteNames.main,
      page: () => MainScreen(),
      binding: HomeBindings(),
    ),
    GetPage(name: RouteNames.scanner, page: () => ScannerScreen()),
    GetPage(name: RouteNames.history, page: () => HistoryScreen()),
    GetPage(
      name: RouteNames.preview,
      page: () => PreviewScreen(),
      binding: PreviewBindings(),
    ),
    GetPage(
      name: RouteNames.scanDetail,
      page: () => ScanDetailScreen(),
      binding: ScanDetailBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: RouteNames.settings,
      page: () => SettingsScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: RouteNames.translation,
      page: () => TranslationScreen(),
      binding: TranslationBinding(),
      transition: Transition.cupertino,
    ),
  ];
}
