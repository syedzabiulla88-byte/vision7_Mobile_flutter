import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/custom_text_theme.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/mode_provider.dart';
import '../../../../shared/providers/app_mode.dart';
import '../../domain/profile_models.dart';
import '../../domain/me_repository.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  String? _error;
  Profile? _profile;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = context.read<MeRepository>();
      final profile = await repo.getProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        title: Text(
          context.read<LanguageProvider>().t('auth.logout', fallback: 'Logout'),
          style: const TextStyle(color: AppColors.cream),
        ),
        content: Text(
          context.read<LanguageProvider>().t('auth.logoutConfirm', fallback: 'Are you sure you want to logout?'),
          style: const TextStyle(color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.read<LanguageProvider>().t('common.cancel', fallback: 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              context.read<LanguageProvider>().t('auth.logout', fallback: 'Logout'),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthProvider>().logout();
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().t;
    final lang = context.watch<LanguageProvider>().lang;
    final mode = context.watch<ModeProvider>();
    final isAcademy = mode.isAcademy;
    final textColor = isAcademy ? AppColors.cream : AppColors.text;
    final mutedColor = isAcademy ? AppColors.cream.withValues(alpha: 0.6) : AppColors.muted;
    final whiteColor = isAcademy ? AppColors.cream.withValues(alpha: 0.1) : AppColors.white;

    final displayName = _profile?.name ?? t('profile.guestUser', fallback: 'Guest User');
    final displayEmail = _profile?.email ?? '';
    final memberSince = _profile?.memberSince != null
        ? _formatMemberSince(_profile!.memberSince!)
        : null;

    return Scaffold(
      backgroundColor: mode.isAcademy ? AppColors.academyNavy : AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('profile.title', fallback: 'Profile'),
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView(
                  children: [
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator(color: AppColors.gold))
                    else if (_error != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        child: Center(
                          child: Column(
                            children: [
                              Text(t('profile.failedToLoad', fallback: 'Failed to load profile'), style: const TextStyle(color: AppColors.error)),
                              TextButton(
                                onPressed: _loadData,
                                child: Text(t('common.retry', fallback: 'Retry')),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (_profile != null) ...[
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: whiteColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: mutedColor,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(displayName, style: Theme.of(context).textTheme.h4.copyWith(color: textColor)),
                            Text(displayEmail, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: mutedColor)),
                            if (memberSince != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '${t('profile.memberSince', fallback: 'Member since')} $memberSince',
                                  style: Theme.of(context).textTheme.caption.copyWith(color: mutedColor),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    _ProfileMenuItem(
                      icon: Icons.person_outline,
                      label: t('profile.editProfile', fallback: 'Edit Profile'),
                      onTap: () {},
                    ),
                    _ProfileMenuItem(
                      icon: Icons.bookmark_border,
                      label: t('profile.myBookings', fallback: 'My Bookings'),
                      onTap: () => context.push('/bookings'),
                    ),
                    _ProfileMenuItem(
                      icon: mode.isAcademy ? Icons.sports_soccer : Icons.card_membership,
                      label: mode.isAcademy
                          ? t('academy.register', fallback: 'Academy Registration')
                          : t('profile.membership', fallback: 'Membership'),
                      onTap: () => context.push('/membership'),
                    ),
                    _ProfileMenuItem(
                      icon: Icons.receipt_long_outlined,
                      label: t('profile.invoices', fallback: 'Invoices'),
                      onTap: () => context.push('/invoices'),
                    ),
                    _ProfileMenuItem(
                      icon: Icons.notifications_outlined,
                      label: t('profile.notifications', fallback: 'Notifications'),
                      onTap: () => context.push('/notifications'),
                    ),
                    _ProfileMenuItem(
                      icon: Icons.language,
                      label: t('profile.language', fallback: 'Language'),
                      trailing: lang == AppLanguage.ar
                          ? t('profile.languageOptionEn', fallback: 'English')
                          : t('profile.languageOptionAr', fallback: 'العربية'),
                      onTap: () {
                        context.read<LanguageProvider>().setLanguage(lang == AppLanguage.ar ? AppLanguage.en : AppLanguage.ar);
                      },
                    ),
                    _ProfileMenuItem(
                      icon: mode.isAcademy ? Icons.sports_soccer : Icons.fitness_center,
                      label: mode.isAcademy
                          ? t('academy.title', fallback: 'Academy Mode')
                          : t('profile.mode', fallback: 'Switch to Academy'),
                      onTap: () {
                        mode.setMode(mode.isAcademy ? AppMode.leisure : AppMode.academy);
                      },
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => _showLogoutDialog(context),
                        child: Text(
                          t('auth.logout', fallback: 'Logout'),
                          style: const TextStyle(color: AppColors.error),
                        ),
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

  String? _formatMemberSince(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final t = context.read<LanguageProvider>().t;
      final monthName = t('calendar.month.${date.month}', fallback: '');
      if (monthName.isEmpty) return null;
      return '${date.day} $monthName ${date.year}';
    } catch (_) {
      return null;
    }
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ModeProvider>();
    final isAcademy = mode.isAcademy;
    final textColor = isAcademy ? AppColors.cream : AppColors.text;
    final mutedColor = isAcademy ? AppColors.cream.withValues(alpha: 0.6) : AppColors.muted;
    final dividerColor = isAcademy ? AppColors.cream.withValues(alpha: 0.2) : AppColors.white;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: dividerColor)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: mutedColor),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textColor)),
            ),
            if (trailing != null)
              Text(trailing!, style: Theme.of(context).textTheme.caption.copyWith(color: mutedColor)),
            Icon(Icons.chevron_right, size: 20, color: mutedColor),
          ],
        ),
      ),
    );
  }
}
