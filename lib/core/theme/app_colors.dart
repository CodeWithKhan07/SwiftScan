import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF2767D5);
  static const primaryDark = Color(0xFF1F4F9A);
  static const primarySoft = Color(0xFFEAF2FF);
  static const primaryPale = Color(0xFFF5F8FE);

  static const background = Color(0xFFF7F9FC);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF18212F);
  static const textSecondary = Color(0xFF667085);
  static const textMuted = Color(0xFF98A2B3);
  static const border = Color(0xFFE4E9F1);
  static const divider = Color(0xFFD5DBE5);

  static const success = Color(0xFF22A06B);
  static const successSoft = Color(0xFFEAF9F2);
  static const warning = Color(0xFFE59A24);
  static const warningSoft = Color(0xFFFFF8EB);
  static const error = Color(0xFFDC4C4C);
  static const errorSoft = Color(0xFFFEEBEB);

  static const darkBackground = Color(0xFF0F141C);
  static const darkSurface = Color(0xFF171E29);
  static const darkSurfaceHigh = Color(0xFF1E2734);
  static const darkTextPrimary = Color(0xFFF4F6FA);
  static const darkTextSecondary = Color(0xFFA7B0BF);
  static const darkBorder = Color(0xFF293445);
  static const darkPrimary = Color(0xFF5B91F5);

  // Semantic colors adapt reusable surfaces and icons to the active theme.
  static Color accent(BuildContext context) =>
      Theme.of(context).colorScheme.primary;
  static Color accentSurface(BuildContext context) =>
      Theme.of(context).colorScheme.primaryContainer;
  static Color onAccentSurface(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimaryContainer;
  static Color secondaryText(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;
  static Color subtleSurface(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHigh;
}
