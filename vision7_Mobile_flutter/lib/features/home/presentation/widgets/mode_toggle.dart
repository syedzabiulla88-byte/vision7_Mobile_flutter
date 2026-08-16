import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/app_mode.dart';
import '../../../../shared/providers/mode_provider.dart';

class ModeToggle extends StatelessWidget {
  const ModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ModeProvider>();
    final isAcademy = mode.isAcademy;

    final activeBg = AppColors.gold;
    final activeText = AppColors.academyNavy;
    final inactiveBg = isAcademy
        ? AppColors.academyWhite.withValues(alpha: 0.08)
        : AppColors.black.withValues(alpha: 0.06);
    final inactiveText = isAcademy
        ? AppColors.academyWhite.withValues(alpha: 0.6)
        : AppColors.black.withValues(alpha: 0.6);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: inactiveBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              button: true,
              selected: mode.isAcademy,
              child: _ModeButton(
                label: 'Academy',
                icon: Icons.school_rounded,
                isActive: mode.isAcademy,
                activeBg: activeBg,
                activeText: activeText,
                inactiveText: inactiveText,
                onTap: () => mode.setMode(AppMode.academy),
              ),
            ),
          ),
          Expanded(
            child: Semantics(
              button: true,
              selected: mode.isLeisure,
              child: _ModeButton(
                label: 'Leisure',
                icon: Icons.diamond_rounded,
                isActive: mode.isLeisure,
                activeBg: AppColors.black,
                activeText: AppColors.cream,
                inactiveText: inactiveText,
                onTap: () => mode.setMode(AppMode.leisure),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.activeBg,
    required this.activeText,
    required this.inactiveText,
    required this.onTap,
  });

  final String label;
  final IconData icon;
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? activeText : inactiveText,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? activeText : inactiveText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
