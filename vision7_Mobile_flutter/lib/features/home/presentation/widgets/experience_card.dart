import 'package:flutter/material.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/custom_text_theme.dart';
import '../../../../core/theme/app_colors.dart';

class ExperienceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isAcademy;

  const ExperienceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isAcademy = true,
  });

  @override
  Widget build(BuildContext context) {
    final mode = isAcademy;
    final cardFill = mode
        ? AppColors.cream.withValues(alpha: 0.1)
        : AppColors.navy.withValues(alpha: 0.07);

    return Container(
      width: 140,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: AppColors.gold),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: mode ? AppColors.cream : AppColors.navy,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.caption.copyWith(
              color: mode ? AppColors.cream.withValues(alpha: 0.55) : AppColors.navy.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
