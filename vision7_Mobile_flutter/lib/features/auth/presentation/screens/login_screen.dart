import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../shared/providers/app_mode.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/providers/mode_provider.dart';
import '../widgets/auth_social_buttons.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modeProvider = Provider.of<ModeProvider>(context, listen: false);
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);

    return ListenableBuilder(
      listenable: Listenable.merge([langProvider, modeProvider]),
      builder: (context, child) {
        final mode = context.watch<ModeProvider>();
        final isAcademy = mode.isAcademy;

        final accent = isAcademy ? AppColors.gold : AppColors.black;
        final bgColor = isAcademy ? AppColors.navy : AppColors.cream;
        final textPrimary = isAcademy ? AppColors.cream : AppColors.black;
        final textMuted =
            isAcademy ? AppColors.cream.withValues(alpha: 0.7) : AppColors.black.withValues(alpha: 0.55);
        final chipBg = isAcademy
            ? AppColors.cream.withValues(alpha: 0.12)
            : AppColors.black.withValues(alpha: 0.08);
        final inputFill = isAcademy
            ? AppColors.cream.withValues(alpha: 0.1)
            : AppColors.black.withValues(alpha: 0.05);

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  // Language toggle
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ToggleChip(
                          label: 'EN',
                          isActive: langProvider.lang == AppLanguage.en,
                          activeColor: accent,
                          activeTextColor: isAcademy ? AppColors.navy : AppColors.cream,
                          onTap: () => langProvider.setLanguage(AppLanguage.en),
                        ),
                        _ToggleChip(
                          label: 'عربي',
                          isActive: langProvider.lang == AppLanguage.ar,
                          activeColor: accent,
                          activeTextColor: isAcademy ? AppColors.navy : AppColors.cream,
                          onTap: () => langProvider.setLanguage(AppLanguage.ar),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Mode toggle
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ModeChip(
                          label: 'Academy',
                          icon: Icons.school_rounded,
                          isActive: mode.isAcademy,
                          activeColor: AppColors.gold,
                          activeTextColor: AppColors.navy,
                          onTap: () => mode.setMode(AppMode.academy),
                        ),
                        _ModeChip(
                          label: 'Leisure',
                          icon: Icons.diamond_rounded,
                          isActive: mode.isLeisure,
                          activeColor: AppColors.black,
                          activeTextColor: AppColors.cream,
                          onTap: () => mode.setMode(AppMode.leisure),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Welcome heading
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      langProvider.t('auth.loginTitle', fallback: 'Welcome Back'),
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      langProvider.t('auth.loginSubtitle', fallback: 'Sign in to continue'),
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Login form
                  _LoginForm(
                    accent: accent,
                    buttonTextColor: isAcademy ? AppColors.navy : AppColors.cream,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                    inputFill: inputFill,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Social login
                  AuthSocialButtons(
                    accent: accent,
                    textPrimary: textPrimary,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Register link
                  Center(
                    child: TextButton(
                      onPressed: () => context.push('/register'),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  langProvider.t('auth.noAccount', fallback: "Don't have an account? "),
                              style: TextStyle(color: textMuted),
                            ),
                            TextSpan(
                              text: langProvider.t('auth.signUp', fallback: 'Sign Up'),
                              style: TextStyle(fontWeight: FontWeight.w700, color: accent),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm({
    required this.accent,
    required this.buttonTextColor,
    required this.textPrimary,
    required this.textMuted,
    required this.inputFill,
  });

  final Color accent;
  final Color buttonTextColor;
  final Color textPrimary;
  final Color textMuted;
  final Color inputFill;

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  String? _authError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!value.contains('@')) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> _handleLogin() async {
    setState(() {
      _emailError = _validateEmail(_emailController.text);
      _passwordError = _validatePassword(_passwordController.text);
      _authError = null;
    });

    if (_emailError != null || _passwordError != null) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted && authProvider.isAuthenticated) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _authError = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_authError != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.error, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _authError!.replaceFirst('Exception: ', ''),
                    style: TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _authError = null),
                  child: Icon(Icons.close, color: AppColors.error, size: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        Text(
          langProvider.t('auth.email', fallback: 'Email'),
          style: TextStyle(color: widget.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: langProvider.t('auth.emailHint', fallback: 'your@email.com'),
            errorText: _emailError,
            filled: true,
            fillColor: widget.inputFill,
            hintStyle: TextStyle(color: widget.textMuted),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: widget.accent, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        Text(
          langProvider.t('auth.password', fallback: 'Password'),
          style: TextStyle(color: widget.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleLogin(),
          decoration: InputDecoration(
            hintText: langProvider.t('auth.passwordHint', fallback: 'Enter password'),
            errorText: _passwordError,
            filled: true,
            fillColor: widget.inputFill,
            hintStyle: TextStyle(color: widget.textMuted),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: widget.accent, width: 1.5),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: widget.textMuted,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: () => context.push('/forgot-password'),
            child: Text(
              langProvider.t('auth.forgotPassword', fallback: 'Forgot Password?'),
              style: TextStyle(color: widget.accent),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: widget.accent,
              disabledBackgroundColor: widget.accent.withValues(alpha: 0.5),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    langProvider.t('auth.signIn', fallback: 'Sign In'),
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16, color: widget.buttonTextColor),
                  ),
          ),
        ),
      ],
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.activeTextColor,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final Color activeColor;
  final Color activeTextColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor : AppColors.muted.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? activeColor : AppColors.muted.withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? activeTextColor : AppColors.muted.withValues(alpha: 0.6),
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.activeTextColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final Color activeTextColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor : AppColors.muted.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? activeColor : AppColors.muted.withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? activeTextColor : AppColors.muted,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeTextColor : AppColors.muted.withValues(alpha: 0.6),
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
