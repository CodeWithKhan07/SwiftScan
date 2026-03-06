import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Light Theme Colors
  static const Color primary = Color(0xFF6366F1);
  static const Color secondary = Color(0xFF4F46E5);
  static const Color textHeader = Color(0xFF1E1B4B);
  static const Color textBody = Color(0xFF475569);
  static const Color background = Color(0xFFF8FAFC);
  static const Color glassSurface = Color(0xB3FFFFFF);
  static const Color glassBorder = Color(0x80FFFFFF);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkTextHeader = Color(0xFFF1F5F9);
  static const Color darkTextBody = Color(0xFF94A3B8);
  static const Color darkGlassSurface = Color(0x1AFFFFFF);
  static const Color darkGlassBorder = Color(0x33FFFFFF);
}

class AppTheme {
  // Common Text Theme helper to avoid repetition
  static TextTheme _buildTextTheme(
    TextTheme base,
    Color headerColor,
    Color bodyColor,
  ) {
    return GoogleFonts.firaSansTextTheme(base).copyWith(
      displayLarge: GoogleFonts.firaSans(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: headerColor,
      ),
      titleMedium: GoogleFonts.firaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: headerColor,
      ),
      titleSmall: GoogleFonts.firaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: headerColor,
      ),
      bodyLarge: GoogleFonts.firaSans(fontSize: 14, color: bodyColor),
      bodyMedium: GoogleFonts.firaSans(fontSize: 13, color: bodyColor),
      bodySmall: GoogleFonts.firaSans(fontSize: 12, color: bodyColor),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: Colors.white,
        onSurface: AppColors.textHeader,
      ),
      textTheme: _buildTextTheme(
        ThemeData.light().textTheme,
        AppColors.textHeader,
        AppColors.textBody,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.firaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textHeader,
        ),
        iconTheme: const IconThemeData(color: AppColors.textHeader),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: AppColors.primary.withValues(alpha: 0.1),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextHeader,
      ),
      textTheme: _buildTextTheme(
        ThemeData.dark().textTheme,
        AppColors.darkTextHeader,
        AppColors.darkTextBody,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.firaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextHeader,
        ),
        iconTheme: const IconThemeData(color: AppColors.darkTextHeader),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkBackground,
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.darkTextHeader,
          ),
        ),
      ),
    );
  }
}

class GlassStyles {
  static BoxDecoration pearlGlass(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? AppColors.darkGlassSurface : AppColors.glassSurface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: isDark ? AppColors.darkGlassBorder : AppColors.glassBorder,
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
