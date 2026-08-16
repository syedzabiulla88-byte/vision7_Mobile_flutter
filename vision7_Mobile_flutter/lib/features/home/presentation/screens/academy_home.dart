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
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  t('academy.home.title'),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: AppSpacing.xl),
                IntrinsicHeight(
                  child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: PillarCard(
                        label: t('academy.pillar.coaching'),
                        subtitle: t('academy.pillar.coaching.subtitle'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: PillarCard(
                        label: t('academy.pillar.development'),
                        subtitle: t('academy.pillar.development.subtitle'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: PillarCard(
                        label: t('academy.pillar.competition'),
                        subtitle: t('academy.pillar.competition.subtitle'),
                      ),
                    ),
                  ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.cream.withValues(alpha: 0),
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
                        t('academy.home.aboutText', fallback: '2026/27'),
                        style: Theme.of(context).textTheme.h2.copyWith(color: AppColors.gold),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.push('/enquiry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.navy,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            t('common.enquireNow', fallback: 'Enquire Now'),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
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
                Column(
                  children: [
                    QuickLinkItem(
                      label: t('academy.quickLink.facilities'),
                      route: '/academy/facilities',
                      icon: Icons.stadium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    QuickLinkItem(
                      label: t('academy.quickLink.coaches'),
                      route: '/academy/coaches',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: AppSpacing.md),
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
  final String label;
  final String? subtitle;

  const PillarCard({
    super.key,
    required this.label,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: 0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.caption.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w800,
                  fontSize: 9.5,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.caption.copyWith(
                    fontSize: 10,
                    color: AppColors.white,
                  ),
              textAlign: TextAlign.left,
            ),
          ],
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
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cream.withValues(alpha: 0),
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
            const SizedBox(width: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
