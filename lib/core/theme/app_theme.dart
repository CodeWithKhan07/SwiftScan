import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: const Color(0xFF205FC9),
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFE5EEFF),
        onPrimaryContainer: const Color(0xFF123361),
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: const Color(0xFF526070),
        outline: const Color(0xFF748092),
        outlineVariant: AppColors.border,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    final latin = _accessibleTextTheme(base.textTheme);
    return base.copyWith(
      textTheme: latin.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      dividerColor: AppColors.border,
      canvasColor: AppColors.surface,
      disabledColor: const Color(0xFF7B8491),
      splashColor: const Color(0x1A205FC9),
      highlightColor: const Color(0x0D205FC9),
      iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 24),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF205FC9),
          minimumSize: const Size(48, 52),
          side: const BorderSide(color: Color(0xFF748092)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF205FC9),
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          minimumSize: const Size.square(48),
        ),
      ),
      chipTheme: _chipTheme(
        base.colorScheme.copyWith(primary: const Color(0xFF205FC9)),
      ),
      dialogTheme: _dialogTheme(AppColors.surface),
      bottomSheetTheme: _bottomSheetTheme(AppColors.surface),
      popupMenuTheme: _popupMenuTheme(AppColors.surface, AppColors.textPrimary),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
        minTileHeight: 56,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primarySoft,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.darkPrimary,
        brightness: Brightness.dark,
        primary: const Color(0xFF91B7FF),
        onPrimary: const Color(0xFF071B35),
        primaryContainer: const Color(0xFF203A61),
        onPrimaryContainer: const Color(0xFFDCE8FF),
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        onSurfaceVariant: const Color(0xFFC1C9D6),
        outline: const Color(0xFF8D99AA),
        outlineVariant: AppColors.darkBorder,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
    );
    final latin = _accessibleTextTheme(base.textTheme);
    return base.copyWith(
      textTheme: latin.apply(
        bodyColor: AppColors.darkTextPrimary,
        displayColor: AppColors.darkTextPrimary,
      ),
      dividerColor: AppColors.darkBorder,
      canvasColor: AppColors.darkSurface,
      disabledColor: const Color(0xFF8791A0),
      splashColor: const Color(0x2691B7FF),
      highlightColor: const Color(0x1491B7FF),
      iconTheme: const IconThemeData(
        color: AppColors.darkTextSecondary,
        size: 24,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.darkPrimary,
            width: 1.6,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: const Color(0xFF071B35),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFB8CEFF),
          minimumSize: const Size(48, 52),
          side: const BorderSide(color: Color(0xFF8D99AA)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFB8CEFF),
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.darkTextSecondary,
          minimumSize: const Size.square(48),
        ),
      ),
      chipTheme: _chipTheme(
        base.colorScheme.copyWith(
          primary: const Color(0xFF91B7FF),
          onPrimary: const Color(0xFF071B35),
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,
          outline: const Color(0xFF8D99AA),
        ),
      ),
      dialogTheme: _dialogTheme(AppColors.darkSurfaceHigh),
      bottomSheetTheme: _bottomSheetTheme(AppColors.darkSurfaceHigh),
      popupMenuTheme: _popupMenuTheme(
        AppColors.darkSurfaceHigh,
        AppColors.darkTextPrimary,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.darkTextSecondary,
        textColor: AppColors.darkTextPrimary,
        minTileHeight: 56,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.darkSurfaceHigh,
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.darkTextPrimary,
      ),
    );
  }

  // Body and control labels remain readable without relying on tiny defaults.
  static TextTheme _accessibleTextTheme(TextTheme base) {
    // Platform fonts render immediately and include native Arabic fallback,
    // avoiding a late network-font swap that visibly flashes the whole UI.
    final themed = base;
    return themed.copyWith(
      bodyLarge: themed.bodyLarge?.copyWith(fontSize: 17, height: 1.45),
      bodyMedium: themed.bodyMedium?.copyWith(fontSize: 16, height: 1.45),
      bodySmall: themed.bodySmall?.copyWith(fontSize: 14, height: 1.4),
      labelLarge: themed.labelLarge?.copyWith(fontSize: 15),
      labelMedium: themed.labelMedium?.copyWith(fontSize: 14),
      labelSmall: themed.labelSmall?.copyWith(fontSize: 13),
      titleSmall: themed.titleSmall?.copyWith(fontSize: 15),
      titleMedium: themed.titleMedium?.copyWith(fontSize: 18),
    );
  }

  static ChipThemeData _chipTheme(ColorScheme colors) => ChipThemeData(
    backgroundColor: colors.surface,
    selectedColor: colors.primaryContainer,
    disabledColor: colors.onSurface.withValues(alpha: .10),
    labelStyle: TextStyle(color: colors.onSurface, fontSize: 14),
    secondaryLabelStyle: TextStyle(
      color: colors.onPrimaryContainer,
      fontSize: 14,
      fontWeight: FontWeight.w700,
    ),
    side: BorderSide(color: colors.outline),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  );

  static DialogThemeData _dialogTheme(Color surface) => DialogThemeData(
    backgroundColor: surface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  );

  static BottomSheetThemeData _bottomSheetTheme(Color surface) =>
      BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      );

  static PopupMenuThemeData _popupMenuTheme(Color surface, Color text) =>
      PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        textStyle: TextStyle(color: text, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      );
}
