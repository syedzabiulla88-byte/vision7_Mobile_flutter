import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/spacing.dart';
import '../../shared/providers/language_provider.dart';
import '../../shared/providers/mode_provider.dart';
import '../../shared/providers/app_mode.dart';
import '../../core/theme/app_colors.dart';


enum AppButtonVariant { primary, secondary, outline, ghost }
enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool fullWidth;
  final Widget? icon;

  const AppButton({
    super.key,
    required this.title,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.isLoading = false,
    this.fullWidth = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final modeProvider = context.watch<ModeProvider>();
    final isAcademy = modeProvider.isAcademy;

    Color? backgroundColor;
    Color? foregroundColor;
    BorderSide? side;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = isAcademy ? AppColors.gold : AppColors.gold;
        foregroundColor = AppColors.dark;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = AppColors.darkLight;
        foregroundColor = AppColors.cream;
        break;
      case AppButtonVariant.outline:
        backgroundColor = null;
        foregroundColor = AppColors.gold;
        side = const BorderSide(color: AppColors.gold);
        break;
      case AppButtonVariant.ghost:
        backgroundColor = null;
        foregroundColor = AppColors.mutedOnDark;
        break;
    }

    final height = switch (size) {
      AppButtonSize.sm => 36.0,
      AppButtonSize.md => 48.0,
      AppButtonSize.lg => 56.0,
    };

    final fontSize = switch (size) {
      AppButtonSize.sm => 13.0,
      AppButtonSize.md => 14.0,
      AppButtonSize.lg => 16.0,
    };

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          side: side,
          padding: EdgeInsets.symmetric(
            horizontal: size == AppButtonSize.sm ? 16 : 24,
            vertical: 0,
          ),
          minimumSize: Size(0, height),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: TextStyle(
            fontFamily: lang.lang == AppLanguage.ar ? 'Cairo' : null,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        child: isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.text))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(title),
                ],
              ),
      ),
    );
  }
}
