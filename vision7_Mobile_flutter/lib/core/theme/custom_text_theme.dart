import 'package:flutter/material.dart';
import 'app_text_styles.dart';

// These getters shadow-name real TextTheme styles (h1/h2/h3/h4/hero/body/label/button/caption)
// that AppTheme.buildTheme already colors correctly per Academy/Leisure mode. Reuse that
// mode-correct color here instead of the static AppTextStyles color, which is light-mode only.
extension CustomTextTheme on TextTheme {
  TextStyle get h3 => AppTextStyles.h3.copyWith(color: titleLarge?.color);
  TextStyle get h4 => AppTextStyles.h4.copyWith(color: titleMedium?.color);
  TextStyle get hero => AppTextStyles.hero.copyWith(color: displayLarge?.color);
  TextStyle get h1 => AppTextStyles.h1.copyWith(color: headlineLarge?.color);
  TextStyle get h2 => AppTextStyles.h2.copyWith(color: headlineMedium?.color);
  TextStyle get body => AppTextStyles.body.copyWith(color: bodyLarge?.color);
  TextStyle get label => AppTextStyles.label.copyWith(color: labelLarge?.color);
  TextStyle get button => AppTextStyles.button.copyWith(color: labelLarge?.color);
  TextStyle get caption => AppTextStyles.caption.copyWith(color: labelSmall?.color);
}
