import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/app_mode.dart';
import '../../../../shared/providers/mode_provider.dart';
import '../../../../core/constants/spacing.dart';
import '../widgets/auth_social_buttons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../legal/presentation/screens/legal_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
              const SizedBox(height: AppSpacing.xxl),
              Text(
                t('auth.createAccount', fallback: 'Create Account'),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(color: textOnSurface),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                t('auth.registerSubtitle', fallback: 'Join Vision7 today'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textMuted),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(child: _RegisterForm(
                textMuted: textMuted,
                textOnSurface: textOnSurface,
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

class _RegisterForm extends StatefulWidget {
  final Color textMuted;
  final Color textOnSurface;
  final Color inputFill;
  final Color inputBorder;
  final Color accent;
  final Color buttonTextColor;
  final bool isAcademy;

  const _RegisterForm({
    required this.textMuted,
    required this.textOnSurface,
    required this.inputFill,
    required this.inputBorder,
    required this.accent,
    required this.buttonTextColor,
    required this.isAcademy,
  });

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _agreedToTerms = false;
  bool _showAgreementError = false;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_clearNameError);
    _emailController.addListener(_clearEmailError);
    _passwordController.addListener(_clearPasswordError);
    _confirmPasswordController.addListener(_clearConfirmError);
  }

  @override
  void dispose() {
    _nameController.removeListener(_clearNameError);
    _emailController.removeListener(_clearEmailError);
    _passwordController.removeListener(_clearPasswordError);
    _confirmPasswordController.removeListener(_clearConfirmError);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _clearNameError() {
    if (_nameError != null) setState(() => _nameError = null);
  }

  void _clearEmailError() {
    if (_emailError != null) setState(() => _emailError = null);
  }

  void _clearPasswordError() {
    if (_passwordError != null) setState(() => _passwordError = null);
  }

  void _clearConfirmError() {
    if (_confirmPasswordError != null) setState(() => _confirmPasswordError = null);
  }

  bool _validate() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    final t = context.read<LanguageProvider>().t;

    setState(() {
      // Name
      if (name.isEmpty) {
        _nameError = t('auth.validation.nameRequired', fallback: 'Name is required');
      } else if (name.split(' ').length < 2) {
        _nameError = t(
          'auth.validation.fullNameRequired',
          fallback: 'Please enter your full name',
        );
      } else {
        _nameError = null;
      }

      // Email
      if (email.isEmpty) {
        _emailError = t('auth.validation.emailRequired', fallback: 'Email is required');
      } else if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
        _emailError = t('auth.validation.emailInvalid', fallback: 'Invalid email address');
      } else {
        _emailError = null;
      }

      // Password
      if (password.isEmpty) {
        _passwordError = t('auth.validation.passwordRequired', fallback: 'Password is required');
      } else if (password.length < 8) {
        _passwordError = t(
          'auth.validation.passwordMinLength',
          fallback: 'Password must be at least 8 characters',
        );
      } else {
        _passwordError = null;
      }

      // Confirm password
      if (confirm.isEmpty) {
        _confirmPasswordError = t(
          'auth.validation.confirmPasswordRequired',
          fallback: 'Please confirm your password',
        );
      } else if (confirm != password) {
        _confirmPasswordError = t(
          'auth.validation.passwordMismatch',
          fallback: 'Passwords do not match',
        );
      } else {
        _confirmPasswordError = null;
      }
    });

    return _nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null;
  }

  Future<void> _handleRegister() async {
    if (!_validate()) return;
    if (!_agreedToTerms) {
      setState(() => _showAgreementError = true);
      return;
    }
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success) {
      await Future.wait([
        auth.acceptConsent('terms', LegalVersions.terms),
        auth.acceptConsent('privacy', LegalVersions.privacy),
      ]);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().t;
    final authError = context.watch<AuthProvider>().error;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: widget.inputBorder, width: 1.2),
    );

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      children: [
        // Name
        Text(t('auth.fullName', fallback: 'Full Name'), style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _nameController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: t('auth.nameHint', fallback: 'Enter your full name'),
            hintStyle: TextStyle(color: widget.isAcademy ? AppColors.cream.withValues(alpha: 0.5) : AppColors.muted),
            filled: true,
            fillColor: widget.inputFill,
            errorText: _nameError,
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(borderSide: BorderSide(color: widget.accent, width: 2)),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Email
        Text(t('auth.email', fallback: 'Email'), style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: t('auth.emailHint', fallback: 'your@email.com'),
            hintStyle: TextStyle(color: widget.isAcademy ? AppColors.cream.withValues(alpha: 0.5) : AppColors.muted),
            filled: true,
            fillColor: widget.inputFill,
            errorText: _emailError,
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(borderSide: BorderSide(color: widget.accent, width: 2)),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Password
        Text(t('auth.password', fallback: 'Password'), style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: t('auth.passwordHint', fallback: 'Enter password'),
            hintStyle: TextStyle(color: widget.isAcademy ? AppColors.cream.withValues(alpha: 0.5) : AppColors.muted),
            filled: true,
            fillColor: widget.inputFill,
            errorText: _passwordError,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: widget.isAcademy ? AppColors.cream.withValues(alpha: 0.7) : AppColors.muted,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(borderSide: BorderSide(color: widget.accent, width: 2)),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Confirm Password
        Text(
          t('auth.confirmPassword', fallback: 'Confirm Password'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleRegister(),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(color: widget.isAcademy ? AppColors.cream.withValues(alpha: 0.5) : AppColors.muted),
            filled: true,
            fillColor: widget.inputFill,
            errorText: _confirmPasswordError,
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(borderSide: BorderSide(color: widget.accent, width: 2)),
          ),
        ),

        // Auth error banner
        if (authError != null) ...[
          const SizedBox(height: AppSpacing.sm),
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
                    authError,
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
        ],

        const SizedBox(height: AppSpacing.lg),

        // Terms & Privacy agreement
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _agreedToTerms,
                onChanged: (v) => setState(() {
                  _agreedToTerms = v ?? false;
                  if (_agreedToTerms) _showAgreementError = false;
                }),
                activeColor: widget.accent,
                checkColor: widget.buttonTextColor,
                side: BorderSide(color: widget.inputBorder),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _agreedToTerms = !_agreedToTerms;
                  if (_agreedToTerms) _showAgreementError = false;
                }),
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(color: widget.textMuted, fontSize: 13, height: 1.4),
                    children: [
                      TextSpan(text: t('auth.agreeToPrefix', fallback: 'I agree to the ')),
                      TextSpan(
                        text: t('profile.termsOfService', fallback: 'Terms of Service'),
                        style: TextStyle(color: widget.accent, fontWeight: FontWeight.w600),
                        recognizer: TapGestureRecognizer()..onTap = () => context.push('/terms'),
                      ),
                      TextSpan(text: t('auth.agreeToMiddle', fallback: ' and ')),
                      TextSpan(
                        text: t('profile.privacyPolicy', fallback: 'Privacy Policy'),
                        style: TextStyle(color: widget.accent, fontWeight: FontWeight.w600),
                        recognizer: TapGestureRecognizer()..onTap = () => context.push('/privacy'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_showAgreementError) ...[
          const SizedBox(height: 4),
          Text(
            t('auth.mustAgreeToTerms', fallback: 'Please accept the Terms of Service and Privacy Policy to continue'),
            style: const TextStyle(color: AppColors.error, fontSize: 12),
          ),
        ],

        const SizedBox(height: AppSpacing.lg),

        // Sign Up button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleRegister,
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
                    t('auth.signUp', fallback: 'Sign Up'),
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16, color: widget.buttonTextColor),
                  ),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Social sign-in
        AuthSocialButtons(accent: widget.accent, textPrimary: widget.textOnSurface),

        const SizedBox(height: AppSpacing.md),
        Center(
          child: TextButton(
            onPressed: () => context.go('/login'),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: t('auth.haveAccount', fallback: 'Already have an account? '),
                    style: TextStyle(color: widget.textMuted),
                  ),
                  TextSpan(
                    text: t('auth.signIn', fallback: 'Sign In'),
                    style: TextStyle(fontWeight: FontWeight.w700, color: widget.accent),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
