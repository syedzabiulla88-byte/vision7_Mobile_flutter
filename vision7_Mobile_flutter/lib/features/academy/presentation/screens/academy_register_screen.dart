import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../core/theme/app_colors.dart';

class AcademyRegisterScreen extends StatefulWidget {
  const AcademyRegisterScreen({super.key});

  @override
  State<AcademyRegisterScreen> createState() => _AcademyRegisterScreenState();
}

class _AcademyRegisterScreenState extends State<AcademyRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _parentController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _programController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _parentController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _programController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<LanguageProvider>().t(
            'academy.register.success',
            fallback: 'Registration submitted successfully!',
          )),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().t;
    final isAcademy = true;
    final textColor = AppColors.cream;
    final mutedColor = AppColors.cream.withValues(alpha: 0.6);

    return Scaffold(
      backgroundColor: AppColors.academyNavy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(Icons.arrow_back_ios, color: textColor),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  t('academy.register.title', fallback: 'Register for Academy'),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  t('academy.register.subtitle', fallback: 'Start your academy journey'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: mutedColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _AcademyInput(
                          controller: _nameController,
                          label: t('academy.register.playerName', fallback: 'Player Name'),
                          hint: t('academy.register.hint.fullName', fallback: 'Full name'),
                          icon: Icons.person_outlined,
                          isAcademy: isAcademy,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return t('validation.required', fallback: 'Required');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _AcademyInput(
                          controller: _parentController,
                          label: t('academy.register.parentName', fallback: 'Parent/Guardian Name'),
                          hint: t('academy.register.hint.parentName', fallback: 'Enter parent/guardian name'),
                          icon: Icons.supervisor_account_outlined,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return t('validation.required', fallback: 'Required');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _AcademyInput(
                          controller: _phoneController,
                          label: t('academy.register.phone', fallback: 'Phone Number'),
                          hint: '+966 5XX XXX XXXX',
                          keyboardType: TextInputType.phone,
                          icon: Icons.phone_outlined,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return t('validation.required', fallback: 'Required');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _AcademyInput(
                          controller: _ageController,
                          label: t('academy.register.age', fallback: 'Player Age'),
                          hint: t('academy.register.hint.age', fallback: 'Age'),
                          keyboardType: TextInputType.number,
                          icon: Icons.cake_outlined,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return t('validation.required', fallback: 'Required');
                            }
                            final age = int.tryParse(v);
                            if (age == null || age < 5 || age > 25) {
                              return t('validation.ageRange', fallback: 'Age must be 5-25');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _AcademyInput(
                          controller: _programController,
                          label: t('academy.register.program', fallback: 'Program'),
                          hint: t('academy.register.hint.program', fallback: 'Select program'),
                          icon: Icons.sports_soccer_outlined,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return t('validation.required', fallback: 'Required');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.academyNavy,
                                    ),
                                  )
                                : Text(t('academy.register.submit', fallback: 'Submit Registration')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AcademyInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool isAcademy;

  const _AcademyInput({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.isAcademy = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isAcademy ? AppColors.cream : AppColors.text;
    final fillColor = isAcademy ? AppColors.cream.withValues(alpha: 0.1) : AppColors.white;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppColors.gold),
        prefixIconColor: AppColors.gold,
        fillColor: fillColor,
        filled: true,
        labelStyle: TextStyle(color: isAcademy ? AppColors.cream : AppColors.text),
        hintStyle: TextStyle(color: isAcademy ? AppColors.cream.withValues(alpha: 0.4) : AppColors.muted),
      ),
      style: TextStyle(color: textColor),
    );
  }
}
