import 'package:flutter/material.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/custom_text_theme.dart';
import '../../../../core/theme/app_colors.dart';

class FocusAreaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isAcademy;

  const FocusAreaItem({
    super.key,
    required this.icon,
    required this.label,
    this.isAcademy = true,
  });

  @override
  Widget build(BuildContext context) {
    final cardFill = isAcademy
        ? AppColors.cream.withValues(alpha: 0.1)
        : AppColors.navy.withValues(alpha: 0.07);
    final textColor = isAcademy ? AppColors.cream : AppColors.navy;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: AppColors.gold),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.caption.copyWith(color: textColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
