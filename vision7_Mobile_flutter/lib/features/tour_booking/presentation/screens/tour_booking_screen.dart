import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/custom_text_theme.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/providers/mode_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/tour_repository.dart';
import '../../domain/tour_models.dart';

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

  int _selectedDayIndex = 2;
  String _selectedTime = '';
  bool _isSubmitting = false;
  bool _isLoadingAvailability = true;
  List<TourSlot> _availableSlots = [];

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailability() async {
    setState(() => _isLoadingAvailability = true);
    try {
      final repo = context.read<TourRepository>();
      // Use today's date as default
      final today = DateTime.now();
      final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final availability = await repo.getAvailability(dateStr);
      final slots = availability.slots.where((s) => s.booked == 0).toList();
      if (mounted) {
        setState(() {
          _availableSlots = slots;
          if (slots.isNotEmpty && _selectedTime.isEmpty) {
            _selectedTime = slots.first.time;
          }
          _isLoadingAvailability = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAvailability = false);
      }
    }
  }

  String get _selectedDateLabel {
    final today = DateTime.now();
    final date = today.add(Duration(days: _selectedDayIndex - 2));
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time slot'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = context.read<TourRepository>();
      final today = DateTime.now();
      final selectedDate = today.add(Duration(days: _selectedDayIndex - 2));
      final dateStr = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

      await repo.book({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'date': dateStr,
        'timeSlot': _selectedTime,
      });

      if (mounted) {
        final t = context.read<LanguageProvider>().t;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t(
              'tour.confirmed',
              fallback: 'Tour booked for $_selectedDateLabel at $_selectedTime',
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
    final cardBg = isAcademy ? AppColors.cream.withValues(alpha: 0.1) : AppColors.white;
    final mutedColor = isAcademy ? AppColors.cream.withValues(alpha: 0.6) : AppColors.muted;

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
                      icon: const Icon(Icons.arrow_back_ios, color: AppColors.cream),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  t('tour.title', fallback: 'Book a Tour'),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  t('tour.subtitle', fallback: 'Schedule a visit to our facilities'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: mutedColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('tour.selectDate', fallback: 'Select Date'),
                          style: Theme.of(context).textTheme.h4,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(5, (i) {
                              final isSelected = _selectedDayIndex == i;
                              final today = DateTime.now();
                              final date = today.add(Duration(days: i - 2));
                              final dayLabel = t('calendar.day.${date.weekday}', fallback: '');
                              final dateLabel = '${date.day}';

                              return Padding(
                                padding: EdgeInsets.only(
                                  right: i < 4 ? AppSpacing.sm : 0,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    setState(() => _selectedDayIndex = i);
                                    _loadAvailabilityForDate(date);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 60,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.gold : cardBg,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          dayLabel,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isSelected ? AppColors.cream : mutedColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          dateLabel,
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: isSelected ? AppColors.cream : AppColors.cream,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          t('tour.selectTime', fallback: 'Select Time'),
                          style: Theme.of(context).textTheme.h4,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (_isLoadingAvailability)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2),
                            ),
                          )
                        else if (_availableSlots.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              t('tour.noSlots', fallback: 'No time slots available'),
                              style: TextStyle(color: mutedColor),
                            ),
                          )
                        else
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: _availableSlots.map((slot) {
                              final isSelected = _selectedTime == slot.time;
                              return InkWell(
                                onTap: () => setState(() => _selectedTime = slot.time),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.gold : cardBg,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    slot.time,
                                    style: TextStyle(
                                      color: isSelected ? AppColors.cream : AppColors.cream,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: AppSpacing.lg),
                        _TourInput(
                          controller: _nameController,
                          label: t('tour.name', fallback: 'Full Name'),
                          hint: t('tour.hint.name', fallback: 'Enter your full name'),
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
                        _TourInput(
                          controller: _phoneController,
                          label: t('tour.phone', fallback: 'Phone Number'),
                          hint: '+966 5XX XXX XXXX',
                          keyboardType: TextInputType.phone,
                          icon: Icons.phone_outlined,
                          isAcademy: isAcademy,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return t('validation.required', fallback: 'Required');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _TourInput(
                          controller: _emailController,
                          label: t('tour.email', fallback: 'Email'),
                          hint: 'your@email.com',
                          keyboardType: TextInputType.emailAddress,
                          icon: Icons.email_outlined,
                          isAcademy: isAcademy,
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
                            onPressed: _isSubmitting ? null : _submit,
                            child: _isSubmitting
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: isAcademy ? AppColors.academyNavy : AppColors.text,
                                    ),
                                  )
                                : Text(t('tour.confirm', fallback: 'Confirm Tour Booking')),
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

  Future<void> _loadAvailabilityForDate(DateTime date) async {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    setState(() => _isLoadingAvailability = true);
    try {
      final repo = context.read<TourRepository>();
      final availability = await repo.getAvailability(dateStr);
      final slots = availability.slots.where((s) => s.booked == 0).toList();
      if (mounted) {
        setState(() {
          _availableSlots = slots;
          _selectedTime = slots.isNotEmpty ? slots.first.time : '';
          _isLoadingAvailability = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAvailability = false);
      }
    }
  }
}

class _TourInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool isAcademy;

  const _TourInput({
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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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
