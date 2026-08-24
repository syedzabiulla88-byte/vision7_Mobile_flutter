import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
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

  // serverClientId must match the backend's GOOGLE_CLIENT_ID env var (the
  // "Web application" OAuth client the backend verifies the token's `aud`
  // claim against) — without it, iOS mints a token audienced to the app's
  // own iOS client ID, which the backend rejects as an audience mismatch.
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    serverClientId: '157792846935-gmg8cv8ukests7kjsmniv9j0hjmieobr.apps.googleusercontent.com',
  );

  void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleGoogle(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    if (!context.mounted) return;
    final t = context.read<LanguageProvider>().t;

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null || !context.mounted) return; // user cancelled — not an error

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      if (idToken == null) {
        if (context.mounted) {
          _showError(context, t('auth.googleFailed', fallback: 'Google sign-in failed. Please try again.'));
        }
        return;
      }
      if (!context.mounted) return;

      final success = await auth.googleLogin(idToken);
      if (!context.mounted) return;
      if (success) {
        context.go('/home');
      } else {
        _showError(context, auth.error ?? t('auth.googleFailed', fallback: 'Google sign-in failed. Please try again.'));
      }
    } on Exception catch (e) {
      debugPrint('Google sign-in error: $e');
      _showError(context, t('auth.googleFailed', fallback: 'Google sign-in failed. Please try again.'));
    }
  }

  Future<void> _handleApple(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    if (!context.mounted) return;
    final t = context.read<LanguageProvider>().t;

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (!context.mounted) return;

      final Map<String, dynamic> userPayload = <String, dynamic>{
        if (credential.givenName != null && credential.familyName != null)
          'name': '${credential.givenName} ${credential.familyName}'
        else if (credential.givenName != null)
          'name': credential.givenName,
        if (credential.email != null) 'email': credential.email,
      };

      final success = await auth.appleLogin(
        credential.identityToken!,
        user: userPayload.isEmpty ? null : userPayload,
      );
      if (!context.mounted) return;
      if (success) {
        context.go('/home');
      } else {
        _showError(context, auth.error ?? t('auth.appleFailed', fallback: 'Apple sign-in failed. Please try again.'));
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return; // user cancelled — not an error
      debugPrint('Apple sign-in error: $e');
      _showError(context, t('auth.appleFailed', fallback: 'Apple sign-in failed. Please try again.'));
    } on Exception catch (e) {
      debugPrint('Apple sign-in error: $e');
      _showError(context, t('auth.appleFailed', fallback: 'Apple sign-in failed. Please try again.'));
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
