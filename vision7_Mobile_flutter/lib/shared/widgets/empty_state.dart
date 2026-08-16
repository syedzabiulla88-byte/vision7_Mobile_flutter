import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/spacing.dart';
import '../../core/theme/custom_text_theme.dart';
import '../../shared/providers/language_provider.dart';
import '../../core/theme/app_colors.dart';


class EmptyState extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final VoidCallback? action;
  final String? actionLabel;

  const EmptyState({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().t;

    return Semantics(
      label: title,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              if (icon != null)
                Icon(icon, size: 48, color: AppColors.mutedOnDark),
              const SizedBox(height: AppSpacing.md),
              Text(title, style: Theme.of(context).textTheme.h4),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(subtitle ?? '', style: Theme.of(context).textTheme.bodySmall),
              ],
              if (action != null) ...[
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: action,
                  child: Text(actionLabel ?? t('common.bookNow', fallback: 'Book Now')),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
