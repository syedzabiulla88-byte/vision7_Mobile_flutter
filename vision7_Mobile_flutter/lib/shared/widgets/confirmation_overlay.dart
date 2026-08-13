import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/spacing.dart';
import '../../core/theme/custom_text_theme.dart';
import '../../shared/providers/language_provider.dart';
import '../../core/theme/app_colors.dart';


class ConfirmationOverlay extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const ConfirmationOverlay({
    super.key,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().t;

    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.darkLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 32, color: AppColors.dark),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  message,
                  style: Theme.of(context).textTheme.h3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: onDismiss ?? () => context.pop(),
                  child: Text(t('common.done', fallback: 'Done')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
