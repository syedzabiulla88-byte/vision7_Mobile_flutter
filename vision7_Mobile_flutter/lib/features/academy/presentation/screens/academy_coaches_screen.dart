import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/custom_text_theme.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../core/theme/app_colors.dart';

class AcademyCoachesScreen extends StatelessWidget {
  const AcademyCoachesScreen({super.key});

  static final _coaches = [
    {'name': 'Ahmed Al-Rashid', 'role': 'Head Coach', 'exp': '15 years', 'icon': Icons.person},
    {'name': 'Marco Silva', 'role': 'Youth Coach', 'exp': '10 years', 'icon': Icons.person},
    {'name': 'Omar Hassan', 'role': 'Goalkeeper Coach', 'exp': '8 years', 'icon': Icons.person},
    {'name': 'Khalid Mansour', 'role': 'Fitness Coach', 'exp': '12 years', 'icon': Icons.person},
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().t;
    final cardBg = AppColors.cream.withValues(alpha: 0.1);

    final title = t('academy.coaches.title', fallback: 'Our Coaches');
    final subtitle = t('academy.coaches.subtitle', fallback: 'Certified, experienced coaching staff');
    final roleLabel = t('academy.coaches.role', fallback: 'Role');
    final expLabel = t('academy.coaches.experience', fallback: 'Experience');

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
                    icon: const Icon(Icons.arrow_back_ios, color: AppColors.cream),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(title, style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView.separated(
                  itemCount: _coaches.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final c = _coaches[index];
                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.person, size: 28, color: AppColors.gold),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c['name'] as String, style: Theme.of(context).textTheme.h4),
                                const SizedBox(height: 2),
                                Text('$roleLabel: ${c['role']}', style: Theme.of(context).textTheme.caption),
                                Text('$expLabel: ${c['exp']}', style: Theme.of(context).textTheme.caption.copyWith(color: AppColors.muted)),
                              ],
                            ),
                          ),
                        ],
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
