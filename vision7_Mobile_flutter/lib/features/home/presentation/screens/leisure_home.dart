import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/custom_text_theme.dart';
import '../../../../shared/providers/language_provider.dart';
import '../widgets/home_header.dart';
import '../widgets/experience_card.dart';
import '../widgets/focus_area_item.dart';
import '../widgets/tour_cta_card.dart';
import '../../../../core/theme/app_colors.dart';

class LeisureHome extends StatelessWidget {
  const LeisureHome({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().t;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Center(
                  child: Image.asset(
                    'assets/images/leisure-logo-black.png',
                    width: 260,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const HomeHeader(),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  t('home.experiencesTitle'),
                  style: Theme.of(context).textTheme.h3,
                ),
                const SizedBox(height: AppSpacing.md),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ExperienceCard(
                        title: t('home.experience.padel'),
                        subtitle: t('home.experience.padel.subtitle'),
                        icon: Icons.sports_tennis,
                        isAcademy: false,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ExperienceCard(
                        title: t('home.experience.gym'),
                        subtitle: t('home.experience.gym.subtitle'),
                        icon: Icons.fitness_center,
                        isAcademy: false,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ExperienceCard(
                        title: t('home.experience.swimming'),
                        subtitle: t('home.experience.swimming.subtitle'),
                        icon: Icons.pool,
                        isAcademy: false,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ExperienceCard(
                        title: t('home.experience.wellness'),
                        subtitle: t('home.experience.wellness.subtitle'),
                        icon: Icons.spa,
                        isAcademy: false,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ExperienceCard(
                        title: t('home.experience.rooftop'),
                        subtitle: t('home.experience.comingSoon'),
                        icon: Icons.deck,
                        isAcademy: false,
                        comingSoon: true,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ExperienceCard(
                        title: t('home.experience.community'),
                        subtitle: t('home.experience.community.subtitle'),
                        icon: Icons.groups,
                        isAcademy: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  t('home.focusAreasTitle'),
                  style: Theme.of(context).textTheme.h3,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: FocusAreaItem(
                        icon: Icons.verified,
                        label: t('home.focusArea.premium'),
                        isAcademy: false,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FocusAreaItem(
                        icon: Icons.groups,
                        label: t('home.focusArea.coaches'),
                        isAcademy: false,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FocusAreaItem(
                        icon: Icons.event,
                        label: t('home.focusArea.booking'),
                        isAcademy: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                const TourCtaCard(),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
