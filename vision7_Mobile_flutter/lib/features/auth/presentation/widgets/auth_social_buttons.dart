import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';

class AuthSocialButtons extends StatelessWidget {
  const AuthSocialButtons({
    super.key,
    this.accent,
    this.textPrimary,
  });

  final Color? accent;
  final Color? textPrimary;

  Future<void> _handleGoogle(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    // For demo: prompt for a token-like input.
    // In production, integrate google_sign_in package.
    final t = context.read<LanguageProvider>().t;
    if (!context.mounted) return;

    final idToken = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: Text(t('auth.googleSignIn', fallback: 'Google Sign-In')),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: t('common.idToken', fallback: 'ID Token'),
              hintStyle: const TextStyle(color: AppColors.muted),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(t('common.cancel', fallback: 'Cancel'))),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text),
              child: Text(t('auth.signIn', fallback: 'Sign In')),
            ),
          ],
        );
      },
    );

    if (idToken != null && idToken.isNotEmpty && context.mounted) {
      final success = await auth.googleLogin(idToken);
      if (success && context.mounted) {
        context.go('/home');
      }
    }
  }

  Future<void> _handleApple(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final t = context.read<LanguageProvider>().t;
    if (!context.mounted) return;

    final idToken = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: Text(t('auth.appleSignIn', fallback: 'Apple Sign-In')),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: t('common.idToken', fallback: 'ID Token'),
              hintStyle: const TextStyle(color: AppColors.muted),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(t('common.cancel', fallback: 'Cancel'))),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text),
              child: Text(t('auth.signIn', fallback: 'Sign In')),
            ),
          ],
        );
      },
    );

    if (idToken != null && idToken.isNotEmpty && context.mounted) {
      final success = await auth.appleLogin(idToken);
      if (success && context.mounted) {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().t;
    final btnText = textPrimary ?? AppColors.cream;
    final borderColor = accent ?? AppColors.grayBorder;

    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                t('auth.orContinueWith', fallback: 'Or continue with'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.muted,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _handleGoogle(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: btnText,
                  side: BorderSide(color: borderColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: SvgPicture.asset(
                  'assets/images/google_logo.svg',
                  width: 20,
                  height: 20,
                ),
                label: Text(t('auth.google', fallback: 'Google'), style: TextStyle(color: btnText)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _handleApple(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: btnText,
                  side: BorderSide(color: borderColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: Icon(Icons.apple, size: 20, color: btnText),
                label: Text(t('auth.apple', fallback: 'Apple'), style: TextStyle(color: btnText)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
