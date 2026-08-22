import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/config/app_config.dart';
import '../../app/routes/app_routes.dart';
import '../../core/localization/app_language.dart';
import 'app_locale_controller.dart';
import 'app_setup_controller.dart';

class OnboardingController extends GetxController {
  OnboardingController(this._setup, this._locale);

  static const pageCount = 3;

  final AppSetupController _setup;
  final AppLocaleController _locale;
  final pageController = PageController();

  final currentPage = 0.obs;
  final country = Rxn<AppCountryOption>();
  final primaryLanguage = AppLanguage.english.obs;
  final secondaryLanguage = AppLanguage.arabic.obs;
  final secondaryLanguageEnabled = false.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();
  bool _languageWasChosen = false;

  List<AppLanguage> get languages => _locale.availableLanguages;
  bool get isKsaSelected => country.value?.code == 'SA';
  bool get canFinish => country.value != null && !isSaving.value;

  @override
  void onInit() {
    super.onInit();
    // Preserve an existing language preference during onboarding migrations.
    primaryLanguage.value = _locale.primaryLanguage.value;
    secondaryLanguage.value = _locale.secondaryLanguage.value;
    secondaryLanguageEnabled.value = _locale.secondaryLanguageEnabled.value;
  }

  void onPageChanged(int index) => currentPage.value = index;

  void selectCountry(AppCountryOption? selected) {
    if (selected == null) return;
    country.value = selected;
    errorMessage.value = null;
    if (!_languageWasChosen && selected.code == 'SA') {
      // Saudi setup starts with the requested Arabic + English default.
      primaryLanguage.value = AppLanguage.arabic;
      secondaryLanguage.value = AppLanguage.english;
      secondaryLanguageEnabled.value = true;
    } else if (selected.code != 'SA') {
      secondaryLanguageEnabled.value = false;
    }
  }

  void selectPrimaryLanguage(AppLanguage? selected) {
    if (selected == null) return;
    _languageWasChosen = true;
    primaryLanguage.value = selected;
    if (secondaryLanguage.value == selected) {
      secondaryLanguage.value = selected == AppLanguage.english
          ? AppLanguage.arabic
          : AppLanguage.english;
    }
  }

  void selectSecondaryLanguage(AppLanguage? selected) {
    if (selected == null || selected == primaryLanguage.value) return;
    _languageWasChosen = true;
    secondaryLanguage.value = selected;
  }

  void toggleSecondaryLanguage(bool enabled) {
    if (!isKsaSelected) return;
    _languageWasChosen = true;
    secondaryLanguageEnabled.value = enabled;
  }

  Future<void> next() async {
    if (currentPage.value < pageCount - 1) {
      await pageController.nextPage(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    await complete();
  }

  Future<void> back() async {
    if (currentPage.value == 0) return;
    await pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> complete() async {
    final selectedCountry = country.value;
    if (selectedCountry == null) {
      errorMessage.value = 'Choose your country to continue.';
      return;
    }
    if (isSaving.value) return;

    isSaving.value = true;
    errorMessage.value = null;
    try {
      await _setup.saveCountry(selectedCountry);
      await _locale.applyOnboardingSelection(
        primary: primaryLanguage.value,
        secondary: secondaryLanguage.value,
        secondaryEnabled: isKsaSelected && secondaryLanguageEnabled.value,
      );
      await _setup.markOnboardingCompleted();
      Get.offAllNamed<void>(AppRoutes.shell);
    } catch (_) {
      // Keep setup resumable and expose a retry instead of silently proceeding.
      errorMessage.value = 'Setup could not be saved. Please try again.';
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
