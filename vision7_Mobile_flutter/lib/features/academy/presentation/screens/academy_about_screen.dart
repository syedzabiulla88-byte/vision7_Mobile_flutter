import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/custom_text_theme.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../core/theme/app_colors.dart';

class AcademyAboutScreen extends StatelessWidget {
  const AcademyAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().t;
    final isAcademy = true;

    final title = t('academy.about.title', fallback: 'About Academy');
    final subtitle = t('academy.about.subtitle', fallback: 'Premier football academy in Riyadh');
    final intro = t('academy.about.intro', fallback: 'Vision7 Academy is dedicated to developing young football talent through world-class coaching, state-of-the-art facilities, and a structured development pathway.');
    final missionTitle = t('academy.about.missionTitle', fallback: 'Our Mission');
    final missionText = t('academy.about.mission', fallback: 'To nurture the next generation of football champions by combining technical excellence with character development.');
    final statsTitle = t('academy.about.stats', fallback: 'By the Numbers');

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
                style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        intro,
                        style: Theme.of(context).textTheme.body.copyWith(color: AppColors.grayMedium),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(statsTitle, style: Theme.of(context).textTheme.h3),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.md,
                        children: [
                          _StatCard(icon: Icons.people, value: '500+', label: t('academy.about.players', fallback: 'Players'), isAcademy: isAcademy),
                          _StatCard(icon: Icons.sports_soccer, value: '12', label: t('academy.about.coaches', fallback: 'Coaches'), isAcademy: isAcademy),
                          _StatCard(icon: Icons.emoji_events, value: '25+', label: t('academy.about.trophies', fallback: 'Trophies'), isAcademy: isAcademy),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(missionTitle, style: Theme.of(context).textTheme.h3),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        missionText,
                        style: Theme.of(context).textTheme.body.copyWith(color: AppColors.grayMedium),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isAcademy;

  const _StatCard({required this.icon, required this.value, required this.label, this.isAcademy = false});

  @override
  Widget build(BuildContext context) {
    final cardBg = isAcademy ? AppColors.cream.withValues(alpha: 0.1) : AppColors.white;
    return Container(
      width: 120,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: AppColors.gold),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: Theme.of(context).textTheme.h3.copyWith(color: AppColors.gold)),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.caption),
        ],
      ),
    );
  }
}
