import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../domain/enquiry_repository.dart';
import '../../../../shared/providers/mode_provider.dart';
import '../../../../core/theme/app_colors.dart';

class EnquiryScreen extends StatefulWidget {
  final String? packageName;

  const EnquiryScreen({super.key, this.packageName});

  @override
  State<EnquiryScreen> createState() => _EnquiryScreenState();
}

class _EnquiryScreenState extends State<EnquiryScreen> {
  final _formKey = GlobalKey<FormState>();

  // Personal information
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();

  // Player details
  String? _enquiringFor;
  final _playerNameController = TextEditingController();
  final _playerAgeController = TextEditingController();
  DateTime? _dateOfBirth;
  String? _gender;
  String? _currentLevel;
  String? _preferredProgram;
  final _preferredDaysTimesController = TextEditingController();
  String? _goal;
  final _medicalNotesController = TextEditingController();
  String? _howDidYouHear;
  final _messageController = TextEditingController();

  bool _isSubmitting = false;

  static const _enquiringForOptions = [
    'myself',
    'my child',
    'my team',
    'my company',
  ];

  static const _genderOptions = ['male', 'female', 'other'];

  static const _currentLevelOptions = [
    'beginner',
    'intermediate',
    'advanced',
    'professional',
  ];

  static const _programOptions = [
    'football',
    'padel',
    'tennis',
    'basketball',
    'fitness',
    'multi-sport',
  ];

  static const _goalOptions = [
    'fitness',
    'competition',
    'skill development',
    'recreation',
    'professional career',
  ];

  static const _howDidYouHearOptions = [
    'social media',
    'friend/family',
    'search engine',
    'advertisement',
    'event',
    'other',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _playerNameController.dispose();
    _playerAgeController.dispose();
    _preferredDaysTimesController.dispose();
    _medicalNotesController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 10, now.month, now.day),
      firstDate: DateTime(now.year - 60),
      lastDate: DateTime(now.year - 3),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.gold,
              onPrimary: AppColors.navy,
              surface: AppColors.academyNavy,
              onSurface: AppColors.cream,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
      final age = now.year - picked.year -
          ((now.month < picked.month ||
                  (now.month == picked.month && now.day < picked.day))
              ? 1
              : 0);
      _playerAgeController.text = age.toString();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final platform = Platform.isIOS ? 'iOS' : 'Android';
      final mode = context.read<ModeProvider>();
      final repo = context.read<EnquiryRepository>();

      // Capture only filled fields into details (avoids empty-string noise in CRM)
      final details = <String, dynamic>{
        if (_enquiringFor != null) 'enquiringFor': _enquiringFor,
        if (_playerNameController.text.trim().isNotEmpty)
          'playerName': _playerNameController.text.trim(),
        if (_playerAgeController.text.trim().isNotEmpty)
          'playerAge': int.tryParse(_playerAgeController.text.trim()),
        if (_dateOfBirth != null)
          'dateOfBirth': _dateOfBirth!.toIso8601String().split('T').first,
        if (_gender != null) 'gender': _gender,
        if (_currentLevel != null) 'currentLevel': _currentLevel,
        if (_preferredProgram != null) 'preferredProgram': _preferredProgram,
        if (_preferredDaysTimesController.text.trim().isNotEmpty)
          'preferredDaysTimes': _preferredDaysTimesController.text.trim(),
        if (_goal != null) 'goal': _goal,
        if (_medicalNotesController.text.trim().isNotEmpty)
          'medicalNotes': _medicalNotesController.text.trim(),
        if (_howDidYouHear != null) 'howDidYouHear': _howDidYouHear,
        if (_cityController.text.trim().isNotEmpty)
          'city': _cityController.text.trim(),
      };

      final interestLabel = widget.packageName ??
          _preferredProgram ??
          _enquiringFor ??
          (_cityController.text.trim().isNotEmpty ? _cityController.text.trim() : 'general');

      await repo.submit({
        'name': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'message': _messageController.text.trim().isEmpty
            ? '${widget.packageName != null ? '${widget.packageName} enquiry' : 'Academy enquiry'}${_preferredProgram != null ? ' — $_preferredProgram' : ''}'
            : _messageController.text.trim(),
        'source': 'App-Enquiry $platform',
        'kind': mode.isAcademy ? 'academy' : 'leisure',
        'interest': interestLabel,
        'details': {
          if (widget.packageName != null) 'package': widget.packageName,
          ...details,
        },
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<LanguageProvider>().t(
                'enquiry.submitted',
                fallback: 'Enquiry submitted successfully!',
              ),
              style: const TextStyle(color: AppColors.navy),
            ),
            backgroundColor: AppColors.gold,
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

    return Scaffold(
      backgroundColor: isAcademy ? AppColors.academyNavy : AppColors.cream,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(Icons.arrow_back_ios, color: textColor),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  t('enquiry.title', fallback: 'Enquire Now'),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  t('enquiry.subtitle', fallback: 'Tell us about your requirements'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: mutedColor),
                ),
              ),
              if (widget.packageName != null) ...[
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: (isAcademy ? AppColors.gold : AppColors.black).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: (isAcademy ? AppColors.gold : AppColors.black).withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.sell_outlined, size: 16, color: isAcademy ? AppColors.gold : AppColors.black),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${t('enquiry.regarding', fallback: 'Enquiring about')}: ',
                                  style: TextStyle(color: mutedColor, fontSize: 13),
                                ),
                                TextSpan(
                                  text: widget.packageName,
                                  style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeading(text: t('enquiry.personalInformation', fallback: 'PERSONAL INFORMATION'), color: textColor),
                      const SizedBox(height: AppSpacing.md),

                      _EnquiryInput(
                        isAcademy: isAcademy,
                        controller: _fullNameController,
                        label: t('enquiry.fullName', fallback: 'Full Name'),
                        hint: t('enquiry.hint.fullName', fallback: 'Your full name'),
                        icon: Icons.person_outlined,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? t('validation.required', fallback: 'Required')
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      _EnquiryInput(
                        isAcademy: isAcademy,
                        controller: _emailController,
                        label: t('enquiry.email', fallback: 'Email'),
                        hint: 'your.email@example.com',
                        keyboardType: TextInputType.emailAddress,
                        icon: Icons.email_outlined,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return t('validation.required', fallback: 'Required');
                          }
                          if (!v.contains('@') || !v.contains('.')) {
                            return t('validation.emailInvalid', fallback: 'Invalid email');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      _EnquiryInput(
                        isAcademy: isAcademy,
                        controller: _phoneController,
                        label: t('enquiry.phone', fallback: 'Phone *'),
                        hint: '920019777',
                        keyboardType: TextInputType.phone,
                        icon: Icons.phone_outlined,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? t('validation.required', fallback: 'Required')
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      _EnquiryDropdown(
                        isAcademy: isAcademy,
                        label: t('enquiry.language', fallback: 'Preferred Language'),
                        value: null,
                        hint: t('common.select', fallback: 'Select an option'),
                        icon: Icons.language_outlined,
                        items: const ['English', 'العربية'],
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: AppSpacing.md),

                      _EnquiryInput(
                        isAcademy: isAcademy,
                        controller: _cityController,
                        label: t('enquiry.city', fallback: 'City / Area'),
                        hint: t('enquiry.hint.city', fallback: 'e.g. Riyadh'),
                        icon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      _SectionHeading(text: t('enquiry.playerDetails', fallback: 'PLAYER DETAILS'), color: textColor),
                      const SizedBox(height: AppSpacing.md),

                      _EnquiryDropdown(
                        isAcademy: isAcademy,
                        label: t('enquiry.enquiringFor', fallback: 'Enquiring For'),
                        value: _enquiringFor,
                        hint: t('common.select', fallback: 'Select an option'),
                        icon: Icons.group_outlined,
                        items: _enquiringForOptions,
                        onChanged: (v) => setState(() => _enquiringFor = v),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      _EnquiryInput(
                        isAcademy: isAcademy,
                        controller: _playerNameController,
                        label: t('enquiry.playerName', fallback: 'Player Name'),
                        hint: t('enquiry.hint.playerName', fallback: 'Player\'s full name'),
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      _EnquiryInput(
                        isAcademy: isAcademy,
                        controller: _playerAgeController,
                        label: t('enquiry.playerAge', fallback: 'Player Age'),
                        hint: t('enquiry.hint.age', fallback: 'Age'),
                        keyboardType: TextInputType.number,
                        icon: Icons.cake_outlined,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      _EnquiryDobField(
                        isAcademy: isAcademy,
                        value: _dateOfBirth,
                        onTap: _pickDateOfBirth,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      _EnquiryDropdown(
                        isAcademy: isAcademy,
                        label: t('enquiry.gender', fallback: 'Gender'),
                        value: _gender,
                        hint: t('common.select', fallback: 'Select an option'),
                        icon: Icons.transgender_outlined,
                        items: _genderOptions,
                        onChanged: (v) => setState(() => _gender = v),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      _EnquiryDropdown(
                        isAcademy: isAcademy,
                        label: t('enquiry.currentLevel', fallback: 'Current Level'),
                        value: _currentLevel,
                        hint: t('common.select', fallback: 'Select an option'),
                        icon: Icons.bar_chart_outlined,
                        items: _currentLevelOptions,
                        onChanged: (v) => setState(() => _currentLevel = v),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      _EnquiryDropdown(
                        isAcademy: isAcademy,
                        label: t('enquiry.preferredProgram', fallback: 'Preferred Program'),
                        value: _preferredProgram,
                        hint: t('common.select', fallback: 'Select an option'),
                        icon: Icons.sports_soccer_outlined,
                        items: _programOptions,
                        onChanged: (v) => setState(() => _preferredProgram = v),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      _EnquiryInput(
                        isAcademy: isAcademy,
                        controller: _preferredDaysTimesController,
                        label: t('enquiry.preferredDays', fallback: 'Preferred Days / Times'),
                        hint: t('enquiry.hint.preferredDays',
                            fallback: 'e.g. Weekday evenings, weekend mornings'),
                        icon: Icons.schedule_outlined,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      _EnquiryDropdown(
                        isAcademy: isAcademy,
                        label: t('enquiry.goal', fallback: 'Goal'),
                        value: _goal,
                        hint: t('common.select', fallback: 'Select an option'),
                        icon: Icons.flag_outlined,
                        items: _goalOptions,
                        onChanged: (v) => setState(() => _goal = v),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      _EnquiryInput(
                        isAcademy: isAcademy,
                        controller: _medicalNotesController,
                        label: t('enquiry.medicalNotes', fallback: 'Medical Notes (optional)'),
                        hint: t('enquiry.hint.medicalNotes',
                            fallback: 'Any injuries, conditions or allergies we should know about'),
                        icon: Icons.medical_services_outlined,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      _EnquiryDropdown(
                        isAcademy: isAcademy,
                        label: t('enquiry.howDidYouHear', fallback: 'How Did You Hear About Us?'),
                        value: _howDidYouHear,
                        hint: t('common.select', fallback: 'Select an option'),
                        icon: Icons.campaign_outlined,
                        items: _howDidYouHearOptions,
                        onChanged: (v) => setState(() => _howDidYouHear = v),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      _EnquiryInput(
                        isAcademy: isAcademy,
                        controller: _messageController,
                        label: t('enquiry.message', fallback: 'Message (optional)'),
                        hint: t('enquiry.hint.message', fallback: 'Your message here...'),
                        maxLines: 4,
                        icon: Icons.message_outlined,
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
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionHeading({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w700,
        fontSize: 13,
        letterSpacing: 1.2,
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
  final bool isAcademy;

  const _EnquiryInput({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.isAcademy = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isAcademy ? AppColors.gold : AppColors.muted;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: iconColor),
        prefixIconColor: iconColor,
      ),
    );
  }
}

class _EnquiryDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final String hint;
  final IconData icon;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool isAcademy;

  const _EnquiryDropdown({
    required this.label,
    required this.value,
    required this.hint,
    required this.icon,
    required this.items,
    required this.onChanged,
    this.isAcademy = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isAcademy ? AppColors.gold : AppColors.muted;
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: iconColor),
        prefixIconColor: iconColor,
      ),
      items: items
          .map((it) => DropdownMenuItem<String>(
                value: it,
                child: Text(it),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _EnquiryDobField extends StatelessWidget {
  final DateTime? value;
  final VoidCallback onTap;
  final bool isAcademy;

  const _EnquiryDobField({
    required this.value,
    required this.onTap,
    this.isAcademy = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().t;
    final iconColor = isAcademy ? AppColors.gold : AppColors.muted;
    final textColor = isAcademy ? AppColors.cream : AppColors.text;
    final formatted = value == null
        ? 'DD/MM/YYYY'
        : '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}';

    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: t('enquiry.orDateOfBirth', fallback: 'Or Date of Birth'),
          prefixIcon: Icon(Icons.calendar_today_outlined, size: 20, color: iconColor),
          prefixIconColor: iconColor,
        ),
        child: Text(
          formatted,
          style: TextStyle(
            color: value == null ? iconColor : textColor,
          ),
        ),
      ),
    );
  }
}
