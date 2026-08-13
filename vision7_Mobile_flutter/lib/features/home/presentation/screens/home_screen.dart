import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/providers/mode_provider.dart';
import '../widgets/mode_toggle.dart';
import '../widgets/language_toggle.dart';
import 'academy_home.dart';
import 'leisure_home.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _drawerIndex = 0;

  Widget _bodyForIndex(int index) {
    switch (index) {
      case 1:
        return AcademyHome();
      case 2:
        return LeisureHome();
      default:
        return AcademyHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ModeProvider>();

    return Scaffold(
      backgroundColor: mode.isAcademy ? AppColors.academyNavy : AppColors.cream,
      appBar: AppBar(
        backgroundColor: mode.isAcademy ? AppColors.academyNavy : AppColors.cream,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(
              Icons.menu_rounded,
              color: mode.isAcademy ? AppColors.academyWhite : AppColors.navy,
            ),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      drawer: _AppDrawer(
        selectedIndex: _drawerIndex,
        onSelect: (index) {
          setState(() => _drawerIndex = index);
          Navigator.of(context).pop();
        },
      ),
      body: _bodyForIndex(_drawerIndex),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final mode = context.watch<ModeProvider>();
    final t = lang.t;
    final isAcademy = mode.isAcademy;
    final bg = isAcademy ? AppColors.academyNavy : AppColors.cream;
    final textPrimary = isAcademy ? AppColors.academyWhite : AppColors.navy;
    final textMuted = isAcademy
        ? AppColors.academyWhite.withValues(alpha: 0.55)
        : AppColors.text.withValues(alpha: 0.6);
    final divider = isAcademy
        ? AppColors.academyWhite.withValues(alpha: 0.1)
        : AppColors.navy.withValues(alpha: 0.08);

    return Drawer(
      backgroundColor: bg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Brand header
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    'assets/images/vision-logo.svg',
                    height: 28,
                    colorFilter: const ColorFilter.mode(
                      AppColors.gold,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    t('app.tagline', fallback: 'Play. Train. Elevate.'),
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: divider, thickness: 1),

            const SizedBox(height: AppSpacing.md),

            // Language toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      t('settings.language', fallback: 'Language'),
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  LanguageToggle(),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Mode toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      t('settings.mode', fallback: 'Mode'),
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  ModeToggle(),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),
            Divider(height: 1, color: divider, thickness: 1),

            const SizedBox(height: AppSpacing.sm),

            // Navigation items
            _DrawerItem(
              icon: Icons.home_outlined,
              label: t('home.title', fallback: 'Home'),
              isActive: selectedIndex == 0 || selectedIndex == 1,
              onTap: () => onSelect(1),
              isAcademy: isAcademy,
              textPrimary: textPrimary,
              textMuted: textMuted,
            ),
            _DrawerItem(
              icon: Icons.diamond_outlined,
              label: t('leisure.title', fallback: 'Leisure'),
              isActive: selectedIndex == 2,
              onTap: () => onSelect(2),
              isAcademy: isAcademy,
              textPrimary: textPrimary,
              textMuted: textMuted,
            ),
            _DrawerItem(
              icon: Icons.calendar_month_outlined,
              label: t('bookings.title', fallback: 'My Bookings'),
              isActive: false,
              onTap: () {},
              isAcademy: isAcademy,
              textPrimary: textPrimary,
              textMuted: textMuted,
            ),
            _DrawerItem(
              icon: Icons.person_outline,
              label: t('profile.title', fallback: 'Profile'),
              isActive: false,
              onTap: () {},
              isAcademy: isAcademy,
              textPrimary: textPrimary,
              textMuted: textMuted,
            ),
            _DrawerItem(
              icon: Icons.settings_outlined,
              label: t('settings.title', fallback: 'Settings'),
              isActive: false,
              onTap: () {},
              isAcademy: isAcademy,
              textPrimary: textPrimary,
              textMuted: textMuted,
            ),

            const Spacer(),

            // Version
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'Vision7 v1.0.0',
                style: TextStyle(
                  color: textMuted.withValues(alpha: 0.4),
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.isAcademy,
    required this.textPrimary,
    required this.textMuted,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isAcademy;
  final Color textPrimary;
  final Color textMuted;

  @override
  Widget build(BuildContext context) {
    final fill = isActive
        ? (isAcademy ? AppColors.gold.withValues(alpha: 0.12) : AppColors.navy.withValues(alpha: 0.06))
        : null;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 2,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive
                  ? AppColors.gold
                  : textMuted,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.gold : textPrimary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
