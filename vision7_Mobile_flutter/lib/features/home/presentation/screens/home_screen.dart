import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/custom_text_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/auth_provider.dart';
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
              color: mode.isAcademy ? AppColors.gold : AppColors.black,
            ),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      drawer: const _AppDrawer(),
      body: mode.isAcademy ? AcademyHome() : LeisureHome(),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final mode = context.watch<ModeProvider>();
    final user = context.watch<AuthProvider>().user;
    final t = lang.t;
    final isAcademy = mode.isAcademy;
    final bg = isAcademy ? AppColors.academyNavy : AppColors.cream;
    final textPrimary = isAcademy ? AppColors.academyWhite : AppColors.black;
    final textMuted = isAcademy
        ? AppColors.academyWhite.withValues(alpha: 0.55)
        : AppColors.text.withValues(alpha: 0.6);
    final divider = isAcademy
        ? AppColors.academyWhite.withValues(alpha: 0.1)
        : AppColors.black.withValues(alpha: 0.08);

    return Drawer(
      backgroundColor: bg,
      // Same scroll-safe wrapper as the login screen: this Column's Spacer()
      // pushes the version label to the bottom when there's room, but a
      // plain Column+Spacer has no fallback when the nav items don't fit a
      // shorter screen (confirmed on an iPhone-compat window on iPad) —
      // LayoutBuilder+ConstrainedBox+IntrinsicHeight keeps that behaviour
      // while scrolling instead of overflowing when they don't.
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile header
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isAcademy ? AppColors.cream.withValues(alpha: 0.1) : AppColors.black.withValues(alpha: 0.06),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.5), width: 1.5),
                      image: user?.profilePhoto != null
                          ? DecorationImage(image: NetworkImage(user!.profilePhoto!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: user?.profilePhoto == null
                        ? Icon(Icons.person, size: 26, color: textMuted)
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      user?.name ?? t('profile.guestUser', fallback: 'Guest User'),
                      style: Theme.of(context).textTheme.h4.copyWith(color: textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
              icon: Icons.calendar_month_outlined,
              label: t('bookings.title', fallback: 'My Bookings'),
              isActive: false,
              onTap: () {
                Navigator.of(context).pop();
                context.push('/bookings');
              },
              isAcademy: isAcademy,
              textPrimary: textPrimary,
              textMuted: textMuted,
            ),
            _DrawerItem(
              icon: Icons.notifications_outlined,
              label: t('profile.notifications', fallback: 'Notifications'),
              isActive: false,
              onTap: () {
                Navigator.of(context).pop();
                context.push('/notifications');
              },
              isAcademy: isAcademy,
              textPrimary: textPrimary,
              textMuted: textMuted,
            ),
            _DrawerItem(
              icon: Icons.person_outline,
              label: t('profile.title', fallback: 'Profile'),
              isActive: false,
              onTap: () {
                Navigator.of(context).pop();
                context.push('/profile');
              },
              isAcademy: isAcademy,
              textPrimary: textPrimary,
              textMuted: textMuted,
            ),
            _DrawerItem(
              icon: Icons.settings_outlined,
              label: t('settings.title', fallback: 'Settings'),
              isActive: false,
              onTap: () {
                // No dedicated Settings screen exists yet — Profile already
                // hosts Language/Mode toggles, so route there for now.
                Navigator.of(context).pop();
                context.push('/profile');
              },
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
              ),
            );
          },
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
        ? (isAcademy ? AppColors.gold.withValues(alpha: 0.12) : AppColors.black.withValues(alpha: 0.06))
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
