import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../domain/enquiry_repository.dart';
import '../../../../shared/providers/mode_provider.dart';
import '../../../../core/theme/app_colors.dart';

class EnquiryScreen extends StatefulWidget {
  const EnquiryScreen({super.key});

  @override
  State<EnquiryScreen> createState() => _EnquiryScreenState();
}

class _EnquiryScreenState extends State<EnquiryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedFacility = '';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedFacility.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<LanguageProvider>().t(
            'validation.selectFacility',
            fallback: 'Please select a facility',
          )),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = context.read<EnquiryRepository>();
      await repo.submit({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'facility': _selectedFacility,
        'message': _messageController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<LanguageProvider>().t(
              'enquiry.submitted',
              fallback: 'Enquiry submitted successfully!',
            )),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<LanguageProvider>().t(
              'enquiry.error',
              fallback: 'Failed to submit enquiry. Please try again.',
            )),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().t;
    final mode = context.watch<ModeProvider>();
    final isAcademy = mode.isAcademy;
    final textColor = isAcademy ? AppColors.cream : AppColors.text;
    final mutedColor = isAcademy ? AppColors.cream.withValues(alpha: 0.6) : AppColors.muted;

    final facilityLabels = ['padel', 'football', 'v7arena', 'birthday', 'other'].map((key) {
      return t('explore.category.$key', fallback: '');
    }).toList();

    return Scaffold(
      backgroundColor: isAcademy ? AppColors.academyNavy : AppColors.cream,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
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
                  t('enquiry.title', fallback: 'Enquire Now'),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  t('enquiry.subtitle', fallback: 'Tell us about your requirements'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: mutedColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _EnquiryInput(
                          controller: _nameController,
                          label: t('enquiry.name', fallback: 'Your Name'),
                          hint: t('enquiry.hint.name', fallback: 'Enter your name'),
                          icon: Icons.person_outlined,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return t('validation.required', fallback: 'Required');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _EnquiryInput(
                          controller: _phoneController,
                          label: t('enquiry.phone', fallback: 'Phone Number'),
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
                        _EnquiryInput(
                          controller: _emailController,
                          label: t('enquiry.email', fallback: 'Email'),
                          hint: 'your@email.com',
                          keyboardType: TextInputType.emailAddress,
                          icon: Icons.email_outlined,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return t('validation.required', fallback: 'Required');
                            }
                            if (!v.contains('@')) {
                              return t('validation.emailInvalid', fallback: 'Invalid email');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          t('enquiry.facility', fallback: 'Facility Interested In'),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textColor),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ChipSelector(
                          options: facilityLabels,
                          selected: _selectedFacility,
                          isAcademy: isAcademy,
                          onChanged: (val) => setState(() => _selectedFacility = val),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _EnquiryInput(
                          controller: _messageController,
                          label: t('enquiry.message', fallback: 'Message'),
                          hint: t('enquiry.hint.message', fallback: 'Tell us more...'),
                          maxLines: 4,
                          icon: Icons.message_outlined,
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
                                      color: AppColors.navy,
                                    ),
                                  )
                                : Text(t('common.enquireNow', fallback: 'Submit Enquiry')),
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

class _EnquiryInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _EnquiryInput({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppColors.muted),
        prefixIconColor: AppColors.muted,
      ),
    );
  }
}

class ChipSelector extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;
  final bool isAcademy;

  const ChipSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.isAcademy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options.map((opt) {
        final isSelected = selected == opt;
        return InkWell(
          onTap: () => onChanged(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.gold : (isAcademy ? AppColors.cream.withValues(alpha: 0.1) : AppColors.white),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              opt,
              style: TextStyle(
                color: isSelected ? AppColors.navy : (isAcademy ? AppColors.navy : AppColors.text),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
