import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/custom_text_theme.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../core/theme/app_colors.dart';

class AcademyEventsScreen extends StatelessWidget {
  const AcademyEventsScreen({super.key});

  static final _events = [
    {'titleKey': 'academy.events.tournament', 'titleFallback': 'Summer Tournament', 'date': 'Aug 20, 2026', 'type': 'Competition', 'icon': Icons.emoji_events, 'color': AppColors.gold},
    {'titleKey': 'academy.events.camp', 'titleFallback': 'Training Camp', 'date': 'Sep 5-10, 2026', 'type': 'Camp', 'icon': Icons.hiking, 'color': AppColors.success},
    {'titleKey': 'academy.events.showcase', 'titleFallback': 'Talent Showcase', 'date': 'Oct 15, 2026', 'type': 'Scouting', 'icon': Icons.visibility, 'color': AppColors.info},
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().t;
    final cardBg = AppColors.cream.withValues(alpha: 0.1);
    final textColor = AppColors.cream;
    final mutedColor = AppColors.cream.withValues(alpha: 0.6);

    return Scaffold(
      backgroundColor: AppColors.academyNavy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.arrow_back_ios, color: textColor),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(t('academy.events.title', fallback: 'Events'), style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: AppSpacing.md),
              Text(
                t('academy.events.subtitle', fallback: 'Tournaments, camps, and showcases'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: mutedColor),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView.separated(
                  itemCount: _events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final e = _events[index];
                    return InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: (e['color'] as Color).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(e['icon'] as IconData, color: e['color'] as Color, size: 22),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                t(e['titleKey'] as String, fallback: e['titleFallback'] as String),
                                style: Theme.of(context).textTheme.h4,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                e['type'] as String,
                                style: Theme.of(context).textTheme.caption.copyWith(
                                  color: mutedColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
