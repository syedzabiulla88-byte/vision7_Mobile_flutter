import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import '../../shared/providers/app_mode.dart';

class AppTheme {
  static ThemeData buildTheme(AppMode mode, AppLanguage lang) {
    final isAcademy = mode == AppMode.academy;

    final colorScheme = isAcademy
        ? const ColorScheme.dark(
            primary: AppColors.academyGold,
            secondary: AppColors.academyGoldDark,
            surface: AppColors.academyNavy,
            onSurface: AppColors.academyWhite,
            onPrimary: AppColors.academyNavy,
            error: AppColors.error,
          )
        : const ColorScheme.light(
            primary: AppColors.gold,
            secondary: AppColors.goldDark,
            surface: AppColors.cream,
            onSurface: AppColors.text,
            onPrimary: AppColors.text,
            error: AppColors.error,
          );

    final fontFamily = lang == AppLanguage.ar ? 'Cairo' : null;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: isAcademy ? AppColors.academyNavy : AppColors.cream,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1.copyWith(color: isAcademy ? AppColors.textOnDark : AppColors.text),
        headlineLarge: AppTextStyles.h1.copyWith(color: isAcademy ? AppColors.textOnDark : AppColors.text),
        headlineMedium: AppTextStyles.h2.copyWith(color: isAcademy ? AppColors.textOnDark : AppColors.text),
        headlineSmall: AppTextStyles.h3.copyWith(color: isAcademy ? AppColors.textOnDark : AppColors.text),
        titleLarge: AppTextStyles.h3.copyWith(color: isAcademy ? AppColors.textOnDark : AppColors.text),
        titleMedium: AppTextStyles.h4.copyWith(color: isAcademy ? AppColors.textOnDark : AppColors.text),
        titleSmall: AppTextStyles.h4.copyWith(color: isAcademy ? AppColors.textOnDark : AppColors.text),
        bodyLarge: AppTextStyles.body.copyWith(color: isAcademy ? AppColors.textOnDark : AppColors.text),
        bodyMedium: AppTextStyles.body.copyWith(color: isAcademy ? AppColors.textOnDark : AppColors.text),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: isAcademy ? AppColors.textOnDark : AppColors.text),
        labelLarge: AppTextStyles.label.copyWith(color: isAcademy ? AppColors.textOnDark : AppColors.text),
        labelMedium: AppTextStyles.label.copyWith(color: isAcademy ? AppColors.textOnDark : AppColors.text),
        labelSmall: AppTextStyles.caption.copyWith(color: isAcademy ? AppColors.mutedOnDark : AppColors.muted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isAcademy ? AppColors.academyNavy : AppColors.white,
        foregroundColor: isAcademy ? AppColors.academyWhite : AppColors.text,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: isAcademy ? AppColors.academyWhite : AppColors.text,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isAcademy ? AppColors.academyNavy : AppColors.white,
        selectedItemColor: isAcademy ? AppColors.academyGold : AppColors.gold,
        unselectedItemColor: isAcademy ? AppColors.academyWhite : AppColors.muted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.warmLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.montserrat(
          fontSize: 14,
          color: AppColors.muted,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isAcademy ? AppColors.academyGold : AppColors.gold,
          foregroundColor: isAcademy ? AppColors.academyNavy : AppColors.text,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isAcademy ? AppColors.academyGold : AppColors.gold,
          side: BorderSide(color: isAcademy ? AppColors.academyGold : AppColors.gold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isAcademy ? AppColors.academyGold : AppColors.gold,
          textStyle: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.warm,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

