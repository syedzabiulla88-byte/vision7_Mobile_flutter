import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeVariant variant;
  final AppBadgeSize size;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.default_,
    this.size = AppBadgeSize.md,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = {
      AppBadgeVariant.default_: isDark ? AppColors.darkLight : AppColors.warm,
      AppBadgeVariant.gold: AppColors.gold,
      AppBadgeVariant.success: AppColors.success,
      AppBadgeVariant.error: AppColors.error,
    };

    final textColors = {
      AppBadgeVariant.default_: AppColors.cream,
      AppBadgeVariant.gold: AppColors.text,
      AppBadgeVariant.success: AppColors.text,
      AppBadgeVariant.error: AppColors.white,
    };

    final fontSize = size == AppBadgeSize.sm ? 11.0 : 13.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size == AppBadgeSize.sm ? 8.0 : 12.0,
        vertical: size == AppBadgeSize.sm ? 4.0 : 6.0,
      ),
      decoration: BoxDecoration(
        color: colors[variant],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColors[variant],
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

enum AppBadgeVariant { default_, gold, success, error }
enum AppBadgeSize { sm, md }
