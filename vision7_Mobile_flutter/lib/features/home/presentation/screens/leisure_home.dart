import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
                  child: SvgPicture.asset(
                    'assets/images/vision-logo.svg',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    colorFilter: const ColorFilter.mode(
                      AppColors.gold,
                      BlendMode.srcIn,
                    ),
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
                        title: t('home.experience.football5'),
                        subtitle: t('home.experience.football.subtitle'),
                        icon: Icons.sports_soccer,
                        isAcademy: false,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ExperienceCard(
                        title: t('home.experience.football7'),
                        subtitle: t('home.experience.football.subtitle'),
                        icon: Icons.sports_soccer,
                        isAcademy: false,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ExperienceCard(
                        title: t('home.experience.football9'),
                        subtitle: t('home.experience.football9.subtitle'),
                        icon: Icons.sports_soccer,
                        isAcademy: false,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ExperienceCard(
                        title: t('home.experience.football11'),
                        subtitle: t('home.experience.football11.subtitle'),
                        icon: Icons.sports_soccer,
                        isAcademy: false,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ExperienceCard(
                        title: t('home.experience.v7arena'),
                        subtitle: t('home.experience.football9.subtitle'),
                        icon: Icons.stadium,
                        isAcademy: false,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ExperienceCard(
                        title: t('home.experience.birthday'),
                        subtitle: t('home.experience.birthday.subtitle'),
                        icon: Icons.cake,
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
