import 'package:flutter/material.dart';

/// Central place for all Remindly styling.
/// Every screen should pull colors/text styles from here instead of
/// hardcoding values, so the whole app stays consistent and elderly-friendly.
class AppColors {
  static const Color primary = Color(0xFF1E4E8C); // Deep blue
  static const Color secondary = Color(0xFF5B9BD5); // Light blue
  static const Color background = Color(0xFFF7F8FA); // Very light grey
  static const Color card = Color(0xFFFFFFFF); // White
  static const Color textPrimary = Color(0xFF212121); // Dark grey / black
  static const Color textSecondary = Color(0xFF5A5A5A);

  static const Color success = Color(0xFF2E7D32); // Completed
  static const Color warning = Color(0xFFEF6C00); // Upcoming
  static const Color overdue = Color(0xFFC62828); // Overdue
  static const Color normal = Color(0xFF1E4E8C); // Normal task (primary blue)
}

/// Text size presets. The Settings screen lets the user pick a "scale"
/// (Small / Medium / Large / Extra Large). We multiply these base sizes
/// by that scale everywhere text is shown.
class AppTextSizes {
  static const double appTitle = 30;
  static const double sectionHeading = 24;
  static const double normalText = 19;
  static const double importantTask = 22;
  static const double buttonText = 19;
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.card,
      ),
      fontFamily: 'Roboto',

      // App bar: simple, high-contrast, no clutter
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: AppTextSizes.sectionHeading,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Cards: rounded, soft shadow, generous padding handled per-widget
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),

      // Buttons: large touch targets (min 48x48dp), bold readable text
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          textStyle: const TextStyle(
            fontSize: AppTextSizes.buttonText,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          side: const BorderSide(color: AppColors.primary, width: 2),
          textStyle: const TextStyle(
            fontSize: AppTextSizes.buttonText,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: AppTextSizes.appTitle,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: AppTextSizes.sectionHeading,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: AppTextSizes.normalText,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: AppTextSizes.normalText,
          color: AppColors.textSecondary,
        ),
        titleMedium: TextStyle(
          fontSize: AppTextSizes.importantTask,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: const TextStyle(fontSize: AppTextSizes.normalText),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Color(0xFF9AA0A6),
        selectedLabelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 13),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  /// Returns a color representing task/appointment status,
  /// per the design spec: green=completed, orange=upcoming, red=overdue, blue=normal.
  static Color statusColor({
    required bool isCompleted,
    required bool isOverdue,
    required bool isUpcoming,
  }) {
    if (isCompleted) return AppColors.success;
    if (isOverdue) return AppColors.overdue;
    if (isUpcoming) return AppColors.warning;
    return AppColors.normal;
  }
}