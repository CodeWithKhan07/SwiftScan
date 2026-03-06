import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:swiftscan/core/bindings/app_bindings.dart';
import 'package:swiftscan/core/resources/theme/app_theme.dart';
import 'package:swiftscan/core/routes/app_routes.dart';
import 'package:swiftscan/core/services/app_lock_service.dart';
import 'package:swiftscan/data/services/hive_service.dart';
import 'package:swiftscan/views/settings/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  await GetStorage.init();
  InitialBinding().dependencies();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _lockOnPause();
    } else if (state == AppLifecycleState.resumed) {
      _checkLockOnResume();
    }
  }

  void _lockOnPause() {
    if (!Get.isRegistered<AppLockService>()) return;
    final lockService = Get.find<AppLockService>();
    if (lockService.isLockEnabled.value) {
      lockService.lockApp();
    }
  }

  void _checkLockOnResume() {
    if (!Get.isRegistered<AppLockService>()) return;
    final lockService = Get.find<AppLockService>();
    if (lockService.isLockEnabled.value && !lockService.isAuthenticated.value) {
      final currentRoute = Get.currentRoute;
      if (currentRoute != RouteNames.authGate &&
          currentRoute != RouteNames.splash) {
        Get.toNamed(RouteNames.authGate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();
    return Obx(
      () => GetMaterialApp(
        getPages: AppRoutes.appRoutes,
        initialBinding: InitialBinding(),
        initialRoute: RouteNames.splash,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: settingsController.currentTheme.value,
      ),
    );
  }
}
