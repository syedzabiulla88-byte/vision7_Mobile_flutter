import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/custom_text_theme.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../core/theme/app_colors.dart';

class AcademyProgramsScreen extends StatelessWidget {
  const AcademyProgramsScreen({super.key});

  static final _programs = [
    {
      'titleKey': 'academy.programs.youth',
      'titleFallback': 'Youth Development',
      'descKey': 'academy.programs.youthDesc',
      'descFallback': 'Ages 6-12 — Fundamentals and fun',
      'icon': Icons.sports_soccer,
      'color': AppColors.success,
    },
    {
      'titleKey': 'academy.programs.junior',
      'titleFallback': 'Junior Academy',
      'descKey': 'academy.programs.juniorDesc',
      'descFallback': 'Ages 13-17 — Competitive training',
      'icon': Icons.fitness_center,
      'color': AppColors.gold,
    },
    {
      'titleKey': 'academy.programs.elite',
      'titleFallback': 'Elite Program',
      'descKey': 'academy.programs.eliteDesc',
      'descFallback': 'Ages 18+ — Professional pathways',
      'icon': Icons.emoji_events,
      'color': AppColors.info,
    },
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
              Text(
                t('academy.programs.title', fallback: 'Programs'),
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                t('academy.programs.subtitle', fallback: 'Choose the right program for your level'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: mutedColor,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView.separated(
                  itemCount: _programs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final p = _programs[index];
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
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: (p['color'] as Color).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(p['icon'] as IconData, color: p['color'] as Color, size: 24),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t(p['titleKey'] as String, fallback: p['titleFallback'] as String),
                                    style: Theme.of(context).textTheme.h4,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    t(p['descKey'] as String, fallback: p['descFallback'] as String),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 16, color: mutedColor),
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
