import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/providers/mode_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/tour_repository.dart';
import '../../domain/tour_models.dart';

const _bgDark = Color(0xFF141414);

class TourBookingScreen extends StatefulWidget {
  const TourBookingScreen({super.key});

  @override
  State<TourBookingScreen> createState() => _TourBookingScreenState();
}

class _TourBookingScreenState extends State<TourBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedTime = '';
  bool _isFemaleWindow = true;
  bool _isSubmitting = false;
  bool _isLoadingAvailability = true;
  List<TourSlot> _availableSlots = [];

  @override
  void initState() {
    super.initState();
    _loadAvailabilityForDate(_selectedDate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String get _dateStr =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  String get _dateDisplay =>
      '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';

  // Female hours 6am–3pm, Male hours 4pm–1am (wraps past midnight).
  bool _isInGenderWindow(String time, bool female) {
    final hour = int.tryParse(time.split(':').first);
    if (hour == null) return true;
    return female ? (hour >= 6 && hour <= 15) : (hour >= 16 || hour <= 1);
  }

  List<TourSlot> get _filteredSlots =>
      _availableSlots.where((s) => _isInGenderWindow(s.time, _isFemaleWindow)).toList();

  Future<void> _loadAvailabilityForDate(DateTime date) async {
    setState(() => _isLoadingAvailability = true);
    try {
      final repo = context.read<TourRepository>();
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final availability = await repo.getAvailability(dateStr);
      final slots = availability.slots.where((s) => s.booked < s.capacity).toList();
      if (mounted) {
        setState(() {
          _availableSlots = slots;
          _selectedTime = '';
          _isLoadingAvailability = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _availableSlots = [];
          _isLoadingAvailability = false;
        });
      }
    }
  }

  Future<void> _pickDate() async {
    final isAcademy = context.read<ModeProvider>().isAcademy;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now) ? now : _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.gold,
              onPrimary: isAcademy ? AppColors.academyNavy : AppColors.black,
              surface: _bgDark,
              onSurface: AppColors.cream,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      await _loadAvailabilityForDate(picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTime.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final repo = context.read<TourRepository>();

      final nameParts = _nameController.text.trim().split(RegExp(r'\s+'));
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null;
      final isAcademy = context.read<ModeProvider>().isAcademy;

      await repo.book({
        'kind': isAcademy ? 'ACADEMY' : 'LEISURE',
        'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'date': _dateStr,
        'slot': _selectedTime,
        'platform': Platform.isIOS ? 'ios-app' : 'android-app',
        'notes': _isFemaleWindow ? 'Female session (6am–3pm)' : 'Male session (4pm–1am)',
        'details': {'gender': _isFemaleWindow ? 'Female' : 'Male'},
      });

      if (mounted) {
        final t = context.read<LanguageProvider>().t;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t(
              'tour.confirmed',
              fallback: 'Tour booked for $_dateDisplay at $_selectedTime',
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
              'tour.error',
              fallback: 'Failed to book tour. Please try again.',
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
    final accent = AppColors.gold;
    const textColor = AppColors.cream;
    final mutedColor = AppColors.cream.withValues(alpha: 0.55);
    final fieldBorder = AppColors.cream.withValues(alpha: 0.18);

    final canContinue = _selectedTime.isNotEmpty;

    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => context.pop(),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: fieldBorder),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.close, color: textColor, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.sm),
                      Container(width: 32, height: 2, color: accent),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        isAcademy
                            ? t('tour.eyebrow.academy', fallback: 'VISION7 ACADEMY')
                            : t('tour.eyebrow.leisure', fallback: 'VISION7 LEISURE'),
                        style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        isAcademy
                            ? t('tour.title.academy', fallback: 'Tour our Academy')
                            : t('tour.title', fallback: 'Tour our Leisure Club'),
                        style: const TextStyle(color: textColor, fontSize: 30, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        t(
                          'tour.subtitle',
                          fallback:
                              'See the gym, pool, padel courts and wellness spaces for yourself. Choose a day and time and our team will give you a personal walk-through.',
                        ),
                        style: TextStyle(color: mutedColor, fontSize: 15, height: 1.4),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        t('tour.step1', fallback: '1 · PICK A DATE'),
                        style: TextStyle(color: mutedColor, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: fieldBorder),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(_dateDisplay, style: const TextStyle(color: textColor, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        t('tour.availableTimes', fallback: 'AVAILABLE TIMES'),
                        style: TextStyle(color: mutedColor, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _GenderTabs(
                        isFemale: _isFemaleWindow,
                        accent: accent,
                        mutedColor: mutedColor,
                        fieldBorder: fieldBorder,
                        onChanged: (female) => setState(() => _isFemaleWindow = female),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (_isLoadingAvailability)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator(color: accent, strokeWidth: 2)),
                        )
                      else if (_filteredSlots.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            border: Border.all(color: fieldBorder),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            t('tour.noSlots', fallback: 'No time slots available for this window'),
                            style: TextStyle(color: mutedColor),
                          ),
                        )
                      else
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: AppSpacing.sm,
                          mainAxisSpacing: AppSpacing.sm,
                          childAspectRatio: 1.7,
                          children: _filteredSlots.map((slot) {
                            final left = slot.capacity - slot.booked;
                            final isSelected = _selectedTime == slot.time;
                            return InkWell(
                              onTap: () => setState(() => _selectedTime = slot.time),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? accent.withValues(alpha: 0.12) : null,
                                  border: Border.all(color: isSelected ? accent : fieldBorder, width: isSelected ? 1.5 : 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      slot.time,
                                      style: TextStyle(
                                        color: isSelected ? accent : textColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$left ${t('tour.left', fallback: 'left')}',
                                      style: TextStyle(color: mutedColor, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: AppSpacing.xl),
                      _TourInput(
                        controller: _nameController,
                        label: t('tour.name', fallback: 'Full Name'),
                        hint: t('tour.hint.name', fallback: 'Enter your full name'),
                        icon: Icons.person_outlined,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return t('validation.required', fallback: 'Required');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _TourInput(
                        controller: _phoneController,
                        label: t('tour.phone', fallback: 'Phone Number'),
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
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        t('tour.phoneHint', fallback: 'A phone number lets us confirm your visit.'),
                        style: TextStyle(color: mutedColor, fontSize: 12),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _TourInput(
                        controller: _emailController,
                        label: t('tour.email', fallback: 'Email'),
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
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (!canContinue || _isSubmitting) ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canContinue ? accent : AppColors.mutedOnDark.withValues(alpha: 0.3),
                            foregroundColor: canContinue ? AppColors.black : AppColors.cream.withValues(alpha: 0.6),
                            disabledBackgroundColor: AppColors.mutedOnDark.withValues(alpha: 0.3),
                            disabledForegroundColor: AppColors.cream.withValues(alpha: 0.6),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black),
                                )
                              : Text(
                                  canContinue
                                      ? t('tour.confirm', fallback: 'CONFIRM TOUR BOOKING')
                                      : t('tour.pickTimeToContinue', fallback: 'PICK A TIME TO CONTINUE'),
                                  style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
                                ),
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

class _GenderTabs extends StatelessWidget {
  final bool isFemale;
  final Color accent;
  final Color mutedColor;
  final Color fieldBorder;
  final ValueChanged<bool> onChanged;

  const _GenderTabs({
    required this.isFemale,
    required this.accent,
    required this.mutedColor,
    required this.fieldBorder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().t;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: fieldBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _GenderTab(
              label: t('tour.female', fallback: 'Female'),
              hours: t('tour.female.hours', fallback: '6am – 3pm'),
              selected: isFemale,
              accent: accent,
              mutedColor: mutedColor,
              onTap: () => onChanged(true),
            ),
          ),
          Expanded(
            child: _GenderTab(
              label: t('tour.male', fallback: 'Male'),
              hours: t('tour.male.hours', fallback: '4pm – 1am'),
              selected: !isFemale,
              accent: accent,
              mutedColor: mutedColor,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderTab extends StatelessWidget {
  final String label;
  final String hours;
  final bool selected;
  final Color accent;
  final Color mutedColor;
  final VoidCallback onTap;

  const _GenderTab({
    required this.label,
    required this.hours,
    required this.selected,
    required this.accent,
    required this.mutedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? accent : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.black : AppColors.cream,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              hours,
              style: TextStyle(
                color: selected ? AppColors.black.withValues(alpha: 0.7) : mutedColor,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TourInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _TourInput({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppColors.cream),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.cream.withValues(alpha: 0.06),
        labelStyle: TextStyle(color: AppColors.cream.withValues(alpha: 0.6)),
        hintStyle: TextStyle(color: AppColors.cream.withValues(alpha: 0.35)),
        prefixIcon: Icon(icon, size: 20, color: AppColors.cream.withValues(alpha: 0.6)),
        prefixIconColor: AppColors.cream.withValues(alpha: 0.6),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.cream.withValues(alpha: 0.18)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.cream.withValues(alpha: 0.18)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: AppColors.gold),
        ),
      ),
    );
  }
}
