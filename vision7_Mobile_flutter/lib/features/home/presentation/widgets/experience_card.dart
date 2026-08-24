import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/custom_text_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/language_provider.dart';

class ExperienceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isAcademy;
  final bool comingSoon;

  const ExperienceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isAcademy = true,
    this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().t;
    final mode = isAcademy;
    final accent = mode ? AppColors.gold : AppColors.black;
    final cardFill = mode
        ? AppColors.cream.withValues(alpha: 0.1)
        : AppColors.black.withValues(alpha: 0.05);

    return Opacity(
      opacity: comingSoon ? 0.6 : 1,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cardFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accent.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 28, color: accent),
                if (comingSoon)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      t('common.soon', fallback: 'SOON'),
                      style: TextStyle(color: accent, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: mode ? AppColors.cream : AppColors.black,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.caption.copyWith(
                color: mode ? AppColors.cream.withValues(alpha: 0.55) : AppColors.black.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
