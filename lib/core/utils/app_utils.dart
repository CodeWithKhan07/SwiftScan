import 'package:flutter/material.dart';

import '../../views/widgets/custom_snackbar.dart';
import '../resources/theme/app_theme.dart';

class AppUtils {
  static void showMsg({required String title, required String msg}) {
    CustomSnackbar(
      title: title,
      message: msg,
      icon: Icons.info_outline_rounded,
      accentColor: AppColors.primary,
    ).show();
  }

  static void showError({required String msg}) {
    CustomSnackbar(
      title: "Error",
      message: msg,
      icon: Icons.error_outline_rounded,
      accentColor: AppColors.error,
    ).show();
  }

  static void showSuccess({required String msg}) {
    CustomSnackbar(
      title: "Success",
      message: msg,
      icon: Icons.check_circle_outline_rounded,
      accentColor: AppColors.success,
    ).show();
  }
}
