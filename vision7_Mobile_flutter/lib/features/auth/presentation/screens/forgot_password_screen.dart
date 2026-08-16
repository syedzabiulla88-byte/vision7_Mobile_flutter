import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/app_mode.dart';
import '../../../../shared/providers/mode_provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/custom_text_theme.dart';
import '../../../../core/theme/app_colors.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final t = lang.t;
    final mode = context.watch<ModeProvider>();
    final isAcademy = mode.mode == AppMode.academy;
    final surface = isAcademy ? AppColors.academySurface : AppColors.cream;
    final textOnSurface = isAcademy ? AppColors.cream : AppColors.black;
    final textMuted = isAcademy ? AppColors.cream.withValues(alpha: 0.7) : AppColors.muted;
    final inputFill = isAcademy ? AppColors.academyInputFill : Colors.white;
    final inputBorder = isAcademy ? AppColors.gold : AppColors.grayBorder;
    final accent = isAcademy ? AppColors.gold : AppColors.black;
    final buttonTextColor = isAcademy ? AppColors.navy : AppColors.cream;

    return Scaffold(
      backgroundColor: surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: Icon(Icons.arrow_back_ios, color: accent),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                t('auth.forgotPasswordTitle', fallback: 'Forgot Password?'),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(color: textOnSurface),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                t('auth.forgotPasswordSubtitle',
                    fallback: 'Enter your email and we\'ll send you a reset link'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textMuted),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(child: _ForgotPasswordForm(
                textMuted: textMuted,
                inputFill: inputFill,
                inputBorder: inputBorder,
                accent: accent,
                buttonTextColor: buttonTextColor,
                isAcademy: isAcademy,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _ForgotPasswordForm extends StatefulWidget {
  final Color textMuted;
  final Color inputFill;
  final Color inputBorder;
  final Color accent;
  final Color buttonTextColor;
  final bool isAcademy;

  const _ForgotPasswordForm({
    required this.textMuted,
    required this.inputFill,
    required this.inputBorder,
    required this.accent,
    required this.buttonTextColor,
    required this.isAcademy,
  });

  @override
  State<_ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<_ForgotPasswordForm> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_clearError);
  }

  @override
  void dispose() {
    _emailController.removeListener(_clearError);
    _emailController.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_emailError != null) setState(() => _emailError = null);
  }

  bool _validate() {
    final email = _emailController.text.trim();
    final t = context.read<LanguageProvider>().t;

    if (email.isEmpty) {
      setState(() => _emailError = t('auth.validation.emailRequired', fallback: 'Email is required'));
      return false;
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      setState(() => _emailError = t('auth.validation.emailInvalid', fallback: 'Invalid email address'));
      return false;
    }
    setState(() => _emailError = null);
    return true;
  }

  Future<void> _handleSubmit() async {
    if (!_validate()) return;
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().forgotPassword(_emailController.text.trim());
      if (mounted) {
        setState(() {
          _isLoading = false;
          _sent = true;
        });
      }
    } on Exception {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().t;
    final authError = context.watch<AuthProvider>().error;
    final textFieldFill = widget.inputFill;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: widget.inputBorder, width: 1.2),
    );

    if (_sent) {
      return Column(
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: AppColors.gold),
          const SizedBox(height: AppSpacing.lg),
          Text(
            t('auth.resetLinkSent', fallback: 'Reset link sent!'),
            style: Theme.of(context).textTheme.h3.copyWith(color: widget.isAcademy ? AppColors.cream : AppColors.black),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            t('auth.resetLinkSentSubtitle',
                fallback: 'Check your email for reset instructions'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: widget.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/login'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: widget.accent,
                foregroundColor: widget.buttonTextColor,
              ),
              child: Text(t('auth.backToLogin', fallback: 'Back to Login')),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (authError != null) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    authError.replaceFirst('Exception: ', ''),
                    style: const TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                ),
                GestureDetector(
                  onTap: () => context.read<AuthProvider>().clearError(),
                  child: const Icon(Icons.close, color: AppColors.error, size: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        Text(t('auth.email', fallback: 'Email'), style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleSubmit(),
          decoration: InputDecoration(
            filled: true,
            fillColor: textFieldFill,
            hintText: t('auth.emailHint', fallback: 'your@email.com'),
            hintStyle: TextStyle(color: widget.isAcademy ? AppColors.cream.withValues(alpha: 0.5) : AppColors.muted),
            errorText: _emailError,
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(borderSide: BorderSide(color: widget.accent, width: 2)),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: widget.accent,
              foregroundColor: widget.buttonTextColor,
              disabledBackgroundColor: widget.accent.withValues(alpha: 0.5),
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.buttonTextColor,
                    ),
                  )
                : Text(
                    t('auth.sendResetLink', fallback: 'Send Reset Link'),
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16, color: widget.buttonTextColor),
                  ),
          ),
        ),
      ],
    );
  }
}
