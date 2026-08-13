import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Light theme text (default — Leisure mode with white/cream surfaces)
  static TextStyle get hero => GoogleFonts.playfairDisplay(
        fontSize: 48,
        height: 56 / 48,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      );
  static TextStyle get h1 => GoogleFonts.playfairDisplay(
        fontSize: 36,
        height: 44 / 36,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      );
  static TextStyle get h2 => GoogleFonts.playfairDisplay(
        fontSize: 28,
        height: 36 / 28,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      );
  static TextStyle get h3 => GoogleFonts.montserrat(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      );
  static TextStyle get h4 => GoogleFonts.montserrat(
        fontSize: 16,
        height: 22 / 16,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      );
  static TextStyle get body => GoogleFonts.montserrat(
        fontSize: 15,
        height: 22 / 15,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
      );
  static TextStyle get bodySmall => GoogleFonts.montserrat(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
      );
  static TextStyle get label => GoogleFonts.montserrat(
        fontSize: 10,
        height: 14 / 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
        color: AppColors.muted,
      );
  static TextStyle get button => GoogleFonts.montserrat(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: AppColors.text,
      );
  static TextStyle get caption => GoogleFonts.montserrat(
        fontSize: 11,
        height: 16 / 11,
        fontWeight: FontWeight.w400,
        color: AppColors.muted,
      );

  // Dark theme text (Academy mode — navy surfaces)
  static TextStyle get heroDark => GoogleFonts.playfairDisplay(
        fontSize: 48,
        height: 56 / 48,
        fontWeight: FontWeight.w800,
        color: AppColors.textOnDark,
      );
  static TextStyle get h1Dark => GoogleFonts.playfairDisplay(
        fontSize: 36,
        height: 44 / 36,
        fontWeight: FontWeight.w700,
        color: AppColors.textOnDark,
      );
  static TextStyle get h2Dark => GoogleFonts.playfairDisplay(
        fontSize: 28,
        height: 36 / 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textOnDark,
      );
  static TextStyle get h3Dark => GoogleFonts.montserrat(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnDark,
      );
  static TextStyle get h4Dark => GoogleFonts.montserrat(
        fontSize: 16,
        height: 22 / 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnDark,
      );
  static TextStyle get bodyDark => GoogleFonts.montserrat(
        fontSize: 15,
        height: 22 / 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textOnDark,
      );
  static TextStyle get bodySmallDark => GoogleFonts.montserrat(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textOnDark,
      );
  static TextStyle get labelDark => GoogleFonts.montserrat(
        fontSize: 10,
        height: 14 / 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
        color: AppColors.mutedOnDark,
      );
  static TextStyle get buttonDark => GoogleFonts.montserrat(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: AppColors.textOnDark,
      );
  static TextStyle get captionDark => GoogleFonts.montserrat(
        fontSize: 11,
        height: 16 / 11,
        fontWeight: FontWeight.w400,
        color: AppColors.mutedOnDark,
      );

  // Arabic variants (light theme)
  static TextStyle get arabicBody => GoogleFonts.cairo(
        fontSize: 15,
        height: 24 / 15,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
      );
  static TextStyle get arabicHeading => GoogleFonts.cairo(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      );
  static TextStyle get arabicBodyDark => GoogleFonts.cairo(
        fontSize: 15,
        height: 24 / 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textOnDark,
      );
  static TextStyle get arabicHeadingDark => GoogleFonts.cairo(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textOnDark,
      );
}
