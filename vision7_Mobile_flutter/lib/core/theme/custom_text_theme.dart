import 'package:flutter/material.dart';
import 'app_text_styles.dart';

extension CustomTextTheme on TextTheme {
  TextStyle get h3 => AppTextStyles.h3;
  TextStyle get h4 => AppTextStyles.h4;
  TextStyle get hero => AppTextStyles.hero;
  TextStyle get h1 => AppTextStyles.h1;
  TextStyle get h2 => AppTextStyles.h2;
  TextStyle get body => AppTextStyles.body;
  TextStyle get bodySmall => AppTextStyles.bodySmall;
  TextStyle get label => AppTextStyles.label;
  TextStyle get button => AppTextStyles.button;
  TextStyle get caption => AppTextStyles.caption;
  TextStyle get displayLarge => AppTextStyles.h1;
}
