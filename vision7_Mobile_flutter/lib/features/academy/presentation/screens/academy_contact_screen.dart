import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../core/theme/app_colors.dart';

class AcademyContactScreen extends StatelessWidget {
  const AcademyContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().t;
    final isAcademy = true;
    final textColor = AppColors.cream;

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
              Text(t('academy.contact.title', fallback: 'Contact Us'), style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: AppSpacing.md),
              Text(
                t('academy.contact.subtitle', fallback: 'Get in touch with our academy team'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.cream.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: Column(
                  children: [
                    _ContactRow(icon: Icons.phone_outlined, label: '+966 XX XXX XXXX', isAcademy: isAcademy),
                    const SizedBox(height: AppSpacing.lg),
                    _ContactRow(icon: Icons.email_outlined, label: 'academy@vision7.sa', isAcademy: isAcademy),
                    const SizedBox(height: AppSpacing.lg),
                    _ContactRow(icon: Icons.location_on_outlined, label: 'Vision7 Sports Complex, Riyadh', isAcademy: isAcademy),
                    const SizedBox(height: AppSpacing.lg),
                    _ContactRow(
                      icon: Icons.access_time_outlined,
                      label: t('academy.contact.hours', fallback: 'Sun-Thu: 8AM - 10PM'),
                      isAcademy: isAcademy,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.phone, size: 18),
                        label: Text(t('academy.contact.call', fallback: 'Call Us')),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.email_outlined, size: 18),
                        label: Text(t('academy.contact.email', fallback: 'Send Email')),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isAcademy;

  const _ContactRow({required this.icon, required this.label, this.isAcademy = false});

  @override
  Widget build(BuildContext context) {
    final cardBg = isAcademy ? AppColors.cream.withValues(alpha: 0.1) : AppColors.white;
    final textColor = isAcademy ? AppColors.cream : AppColors.text;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.gold),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textColor))),
        ],
      ),
    );
  }
}
