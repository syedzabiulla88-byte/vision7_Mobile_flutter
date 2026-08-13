import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/custom_text_theme.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../core/theme/app_colors.dart';

class AcademyFacilitiesScreen extends StatelessWidget {
  const AcademyFacilitiesScreen({super.key});

  static final _facilities = [
    {'nameKey': 'academy.facilities.pitch', 'nameFallback': 'Full-size Pitch', 'descKey': 'academy.facilities.pitchDesc', 'descFallback': 'Professional-grade natural grass pitch', 'icon': Icons.sports_soccer},
    {'nameKey': 'academy.facilities.futsal', 'nameFallback': 'Futsal Court', 'descKey': 'academy.facilities.futsalDesc', 'descFallback': 'Indoor court for technical drills', 'icon': Icons.sports_basketball},
    {'nameKey': 'academy.facilities.gym', 'nameFallback': 'Training Gym', 'descKey': 'academy.facilities.gymDesc', 'descFallback': 'Strength and conditioning equipment', 'icon': Icons.fitness_center},
    {'nameKey': 'academy.facilities.recovery', 'nameFallback': 'Recovery Zone', 'descKey': 'academy.facilities.recoveryDesc', 'descFallback': 'Physiotherapy and ice bath area', 'icon': Icons.spa},
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().t;
    final cardBg = AppColors.cream.withValues(alpha: 0.1);

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
                    icon: Icon(Icons.arrow_back_ios, color: AppColors.cream),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                t('academy.facilities.title', fallback: 'Academy Facilities'),
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                t('academy.facilities.subtitle', fallback: 'World-class training facilities'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.cream.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                  ),
                  itemCount: _facilities.length,
                  itemBuilder: (context, index) {
                    final f = _facilities[index];
                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(f['icon'] as IconData, size: 32, color: AppColors.gold),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            t(f['nameKey'] as String, fallback: f['nameFallback'] as String),
                            style: Theme.of(context).textTheme.h4,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t(f['descKey'] as String, fallback: f['descFallback'] as String),
                            style: Theme.of(context).textTheme.caption,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
