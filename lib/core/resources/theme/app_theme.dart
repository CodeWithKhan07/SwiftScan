import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF6366F1);
  static const Color secondary = Color(0xFF4F46E5);
  static const Color textHeader = Color(0xFF1E1B4B);
  static const Color textBody = Color(0xFF475569);
  static const Color background = Color(0xFFF8FAFC);
  static const Color glassSurface = Color(0xB3FFFFFF);
  static const Color glassBorder = Color(0x80FFFFFF);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: Colors.white,
      ),
      textTheme: GoogleFonts.firaSansTextTheme().copyWith(
        displayLarge: GoogleFonts.firaSans(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textHeader,
        ),
        titleMedium: GoogleFonts.firaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textHeader,
        ),
        bodyLarge: GoogleFonts.firaSans(
          fontSize: 14,
          color: AppColors.textBody,
        ),
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
}

class GlassStyles {
  static BoxDecoration get pearlGlass {
    return BoxDecoration(
      color: AppColors.glassSurface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.glassBorder, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
