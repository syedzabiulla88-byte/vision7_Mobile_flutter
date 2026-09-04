import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _appVersion = '${info.version} (${info.buildNumber})');
      }
    } catch (_) {
      // Keep default version string
    }
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
    final isAcademy = context.read<ModeProvider>().isAcademy;
    final dialogText = isAcademy ? AppColors.cream : AppColors.text;
    final dialogMuted = isAcademy ? AppColors.cream.withValues(alpha: 0.7) : AppColors.muted;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isAcademy ? AppColors.academyNavy : AppColors.white,
        title: Text(
          context.read<LanguageProvider>().t('auth.logout', fallback: 'Logout'),
          style: TextStyle(color: dialogText),
        ),
        content: Text(
          context.read<LanguageProvider>().t('auth.logoutConfirm', fallback: 'Are you sure you want to logout?'),
          style: TextStyle(color: dialogMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              context.read<LanguageProvider>().t('common.cancel', fallback: 'Cancel'),
              style: TextStyle(color: dialogMuted),
            ),
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

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final isAcademy = context.read<ModeProvider>().isAcademy;
    final dialogText = isAcademy ? AppColors.cream : AppColors.text;
    final dialogMuted = isAcademy ? AppColors.cream.withValues(alpha: 0.7) : AppColors.muted;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isAcademy ? AppColors.academyNavy : AppColors.white,
        title: Text(
          context.read<LanguageProvider>().t('auth.deleteAccount', fallback: 'Delete Account'),
          style: TextStyle(color: dialogText),
        ),
        content: Text(
          context.read<LanguageProvider>().t(
                'auth.deleteAccountConfirm',
                fallback:
                    'This permanently deletes your account and personal data. This cannot be undone. Are you sure?',
              ),
          style: TextStyle(color: dialogMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              context.read<LanguageProvider>().t('common.cancel', fallback: 'Cancel'),
              style: TextStyle(color: dialogMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              context.read<LanguageProvider>().t('auth.deleteAccount', fallback: 'Delete Account'),
              style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final success = await context.read<AuthProvider>().deleteAccount();
    if (!context.mounted) return;
    if (success) {
      context.go('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LanguageProvider>().t(
                  'auth.deleteAccountFailed',
                  fallback: 'Could not delete your account. Please try again.',
                ),
          ),
        ),
      );
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
    final whiteColor = isAcademy ? AppColors.cream.withValues(alpha: 0) : AppColors.white;

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
                            _ProfileAvatar(
                              whiteColor: whiteColor,
                              mutedColor: mutedColor,
                              displayName: displayName,
                              remotePhotoUrl: _profile?.profilePhoto,
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
                      onTap: () => _showEditProfileSheet(context),
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
                      icon: Icons.qr_code_2_outlined,
                      label: t('profile.accessPass', fallback: 'Access Pass'),
                      onTap: () => context.push('/access-pass'),
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
                    _ProfileMenuItem(
                      icon: Icons.description_outlined,
                      label: t('profile.termsOfService', fallback: 'Terms of Service'),
                      onTap: () => context.push('/terms'),
                    ),
                    _ProfileMenuItem(
                      icon: Icons.privacy_tip_outlined,
                      label: t('profile.privacyPolicy', fallback: 'Privacy Policy'),
                      onTap: () => context.push('/privacy'),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: isAcademy ? AppColors.cream.withValues(alpha: 0.2) : AppColors.white)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 22, color: mutedColor),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              t('profile.version', fallback: 'Version'),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textColor),
                            ),
                          ),
                          Text(
                            _appVersion,
                            style: Theme.of(context).textTheme.caption.copyWith(color: mutedColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
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
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => _showDeleteAccountDialog(context),
                        child: Text(
                          t('auth.deleteAccount', fallback: 'Delete Account'),
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
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

  Future<void> _showEditProfileSheet(BuildContext context) async {
    final isAcademy = context.read<ModeProvider>().isAcademy;
    final textColor = isAcademy ? AppColors.cream : AppColors.text;
    final mutedColor = isAcademy ? AppColors.cream.withValues(alpha: 0.6) : AppColors.muted;
    final surfaceColor = isAcademy ? AppColors.academyNavy : AppColors.white;
    final dividerColor = isAcademy ? AppColors.cream.withValues(alpha: 0.2) : AppColors.muted.withValues(alpha: 0.2);

    final nameCtrl = TextEditingController(text: _profile?.name ?? '');
    final emailCtrl = TextEditingController(text: _profile?.email ?? '');
    final phoneCtrl = TextEditingController(text: _profile?.phone ?? '');
    final cityCtrl = TextEditingController(text: _profile?.city ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.read<LanguageProvider>().t('profile.editProfile', fallback: 'Edit Profile'),
                    style: Theme.of(sheetCtx).textTheme.h4.copyWith(color: textColor),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: nameCtrl,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: context.read<LanguageProvider>().t('profile.fullName', fallback: 'Full Name'),
                      labelStyle: TextStyle(color: mutedColor),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: dividerColor)),
                    ),
                  ),
                  TextFormField(
                    controller: emailCtrl,
                    style: TextStyle(color: textColor),
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: context.read<LanguageProvider>().t('profile.email', fallback: 'Email'),
                      labelStyle: TextStyle(color: mutedColor),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: dividerColor)),
                    ),
                  ),
                  TextFormField(
                    controller: phoneCtrl,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: context.read<LanguageProvider>().t('profile.phone', fallback: 'Phone'),
                      labelStyle: TextStyle(color: mutedColor),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: dividerColor)),
                    ),
                  ),
                  TextFormField(
                    controller: cityCtrl,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: context.read<LanguageProvider>().t('profile.city', fallback: 'City'),
                      labelStyle: TextStyle(color: mutedColor),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: dividerColor)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(sheetCtx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              context.read<LanguageProvider>().t(
                                'profile.updated',
                                fallback: 'Profile updated',
                              ),
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      child: Text(context.read<LanguageProvider>().t('common.save', fallback: 'Save')),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        );
      },
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

class _ProfileAvatar extends StatelessWidget {
  final Color whiteColor;
  final Color mutedColor;
  final String displayName;
  final String? remotePhotoUrl;

  const _ProfileAvatar({
    required this.whiteColor,
    required this.mutedColor,
    required this.displayName,
    required this.remotePhotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final initials = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();

    final hasRemote = remotePhotoUrl != null && remotePhotoUrl!.isNotEmpty;

    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: whiteColor,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gold, width: 2),
      ),
      child: ClipOval(
        child: hasRemote
            ? Image.network(
                remotePhotoUrl!,
                fit: BoxFit.cover,
                width: 96,
                height: 96,
                errorBuilder: (_, __, ___) => _initialsFallback(initials, mutedColor),
              )
            : _initialsFallback(initials, mutedColor),
      ),
    );
  }

  Widget _initialsFallback(String initials, Color mutedColor) {
    return Center(
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: TextStyle(
          color: mutedColor,
          fontSize: 36,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
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
