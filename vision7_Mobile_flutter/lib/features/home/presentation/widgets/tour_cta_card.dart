import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/custom_text_theme.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../core/theme/app_colors.dart';

class TourCtaCard extends StatelessWidget {
  const TourCtaCard({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().t;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gold, AppColors.goldDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('home.bookATour', fallback: 'Book a Tour'),
                  style: Theme.of(context).textTheme.h3.copyWith(
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  t('home.tourSubtitle', fallback: 'See our facilities in person'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.text.withAlpha((0.7 * 255).round()),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push('/tour-booking'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cream,
              foregroundColor: AppColors.gold,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(t('common.bookNow', fallback: 'Book Now')),
          ),
        ],
      ),
    );
  }
}
