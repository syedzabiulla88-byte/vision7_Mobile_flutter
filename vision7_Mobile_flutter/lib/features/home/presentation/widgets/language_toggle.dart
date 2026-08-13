import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/app_mode.dart';
import '../../../../shared/providers/language_provider.dart';

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    final activeBg = AppColors.gold;
    final activeText = AppColors.academyNavy;
    final inactiveText =
        AppColors.academyWhite.withValues(alpha: 0.6);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: inactiveText.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: _LangButton(
              label: 'EN',
              isActive: lang.lang == AppLanguage.en,
              activeBg: activeBg,
              activeText: activeText,
              inactiveText: inactiveText,
              onTap: () => lang.setLanguage(AppLanguage.en),
            ),
          ),
          Expanded(
            child: _LangButton(
              label: 'عربي',
              isActive: lang.lang == AppLanguage.ar,
              activeBg: activeBg,
              activeText: activeText,
              inactiveText: inactiveText,
              onTap: () => lang.setLanguage(AppLanguage.ar),
            ),
          ),
        ],
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  const _LangButton({
    required this.label,
    required this.isActive,
    required this.activeBg,
    required this.activeText,
    required this.inactiveText,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final Color activeBg;
  final Color activeText;
  final Color inactiveText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? activeText : inactiveText,
          ),
        ),
      ),
    );
  }
}
