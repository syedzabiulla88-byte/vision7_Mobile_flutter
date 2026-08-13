import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/custom_text_theme.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../core/theme/app_colors.dart';

class AcademyHome extends StatelessWidget {
  const AcademyHome({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final t = lang.t;

    return Scaffold(
      backgroundColor: AppColors.academyNavy,
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
                    width: 220,
                    height: 220,
                    fit: BoxFit.contain,
                    colorFilter: const ColorFilter.mode(
                      AppColors.gold,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  t('academy.home.title'),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  t('academy.home.subtitle'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  t('academy.home.pillars', fallback: 'Our Pillars'),
                  style: Theme.of(context).textTheme.h3,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: PillarCard(
                        icon: Icons.school,
                        label: t('academy.pillar.coaching'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: PillarCard(
                        icon: Icons.track_changes,
                        label: t('academy.pillar.development'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: PillarCard(
                        icon: Icons.emoji_events,
                        label: t('academy.pillar.competition'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.cream.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('academy.about.title'),
                        style: Theme.of(context).textTheme.h4,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        t('academy.home.aboutText', fallback: 'Vision7 Academy provides world-class football training for youth and amateur players. Our curriculum is designed by certified coaches with international experience.'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  t('academy.home.quickLinks', fallback: 'Quick Links'),
                  style: Theme.of(context).textTheme.h3,
                ),
                const SizedBox(height: AppSpacing.md),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  children: [
                    QuickLinkItem(
                      label: t('academy.quickLink.programs'),
                      route: '/academy/programs',
                      icon: Icons.sports_soccer,
                    ),
                    QuickLinkItem(
                      label: t('academy.quickLink.facilities'),
                      route: '/academy/facilities',
                      icon: Icons.stadium,
                    ),
                    QuickLinkItem(
                      label: t('academy.quickLink.coaches'),
                      route: '/academy/coaches',
                      icon: Icons.person,
                    ),
                    QuickLinkItem(
                      label: t('academy.quickLink.events'),
                      route: '/academy/events',
                      icon: Icons.event,
                    ),
                    QuickLinkItem(
                      label: t('academy.quickLink.contact'),
                      route: '/academy/contact',
                      icon: Icons.contact_mail,
                    ),
                    QuickLinkItem(
                      label: t('academy.quickLink.register'),
                      route: '/academy/register',
                      icon: Icons.app_registration,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PillarCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const PillarCard({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: AppColors.gold),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class QuickLinkItem extends StatelessWidget {
  final String label;
  final String route;
  final IconData icon;

  const QuickLinkItem({
    super.key,
    required this.label,
    required this.route,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cream.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: AppSpacing.md),
            Icon(icon, size: 20, color: AppColors.gold),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.cream,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
