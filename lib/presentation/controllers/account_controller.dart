import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/localization/app_language.dart';
import '../../core/utils/app_snackbar.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/document_usecases.dart';
import '../../domain/usecases/entitlement_usecases.dart';
import '../../domain/usecases/preference_usecases.dart';
import '../../domain/usecases/security_usecases.dart';
import 'app_lock_controller.dart';
import 'app_locale_controller.dart';
import 'base/entitlement_controller.dart';
import 'app_shell_controller.dart';

class AccountController extends EntitlementController {
  AccountController(
    this._auth,
    EntitlementUseCases entitlements,
    this._documents,
    this._preferences,
    this._security,
    this._shell,
    this._appLock,
    this._locale,
  ) : super(entitlements);

  final AuthUseCases _auth;
  final DocumentUseCases _documents;
  final PreferenceUseCases _preferences;
  final SecurityUseCases _security;
  final AppShellController _shell;
  final AppLockController _appLock;
  final AppLocaleController _locale;

  final isSyncing = false.obs;
  final biometricEnabled = false.obs;
  final biometricSupported = false.obs;
  final firebaseAvailable = false.obs;

  @override
  void onInit() {
    super.onInit();
    firebaseAvailable.value = _auth.firebaseAvailable;
    _loadSecurity();
  }

  Future<void> _loadSecurity() async {
    biometricEnabled.value = await _preferences.isBiometricLockEnabled();
    biometricSupported.value = await _security.isSupported();
  }

  bool get isAnonymous => _auth.isAnonymous;

  String get accountLabel =>
      isAnonymous ? 'Guest / ضيف' : 'Signed in / تم تسجيل الدخول';

  void openAuth() => Get.toNamed(AppRoutes.auth);
  void openSubscription() => Get.toNamed(AppRoutes.subscription);

  Future<void> syncAll() => _runPremiumCloudAction(
    _documents.syncAll,
    'Cloud sync complete / اكتملت المزامنة',
  );

  Future<void> restoreCloud() => _runPremiumCloudAction(
    _documents.restoreFromCloud,
    'Cloud documents restored / تمت استعادة المستندات',
  );

  Future<void> _runPremiumCloudAction(
    Future<Object?> Function() action,
    String successMessage,
  ) async {
    if (!entitlement.value.isPremium) {
      openSubscription();
      return;
    }
    if (isSyncing.value) return;

    isSyncing.value = true;
    try {
      await action();
      AppSnackbar.success(successMessage);
    } catch (error) {
      AppSnackbar.error(
        'Cloud operation unavailable / العملية السحابية غير متاحة: $error',
      );
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> toggleBiometric(bool enabled) async {
    if (enabled && !await _security.authenticate()) return;

    biometricEnabled.value = enabled;
    await _preferences.setBiometricLockEnabled(enabled);

    await _appLock.refreshPreference();
  }

  RxBool get isDarkMode => _shell.isDarkMode;
  Rx<AppLanguage> get language => _locale.language;
  Rx<AppLanguage> get primaryLanguage => _locale.primaryLanguage;
  Rx<AppLanguage> get secondaryLanguage => _locale.secondaryLanguage;
  RxBool get secondaryLanguageEnabled => _locale.secondaryLanguageEnabled;
  String get languageSelectionLabel => _locale.languageSelectionLabel;
  List<AppLanguage> get availableLanguages => _locale.availableLanguages;

  Future<void> toggleTheme(bool enabled) => _shell.toggleTheme(enabled);
  Future<void> setLanguage(AppLanguage value) => _locale.setLanguage(value);
  Future<void> setPrimaryLanguage(AppLanguage value) =>
      _locale.setPrimaryLanguage(value);
  Future<void> setSecondaryLanguage(AppLanguage value) =>
      _locale.setSecondaryLanguage(value);
  Future<void> setSecondaryLanguageEnabled(bool enabled) =>
      _locale.setSecondaryLanguageEnabled(enabled);

  Future<void> clearLocalData() async {
    await _documents.clear();
    AppSnackbar.success('Local data cleared / تم مسح البيانات المحلية');
  }

  Future<void> signOut() async {
    await _auth.signOut();
    update();
    AppSnackbar.success('Signed out / تم تسجيل الخروج');
  }

  Future<void> deleteAccount() async {
    try {
      await _documents.clear();
      await _auth.deleteAccount();
      update();
      AppSnackbar.success('Account deleted / تم حذف الحساب');
    } catch (error) {
      AppSnackbar.error('Account deletion failed / تعذر حذف الحساب: $error');
    }
  }
}
