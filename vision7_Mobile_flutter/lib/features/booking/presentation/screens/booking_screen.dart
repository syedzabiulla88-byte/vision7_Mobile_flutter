import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/custom_text_theme.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/providers/mode_provider.dart';
import '../../../explore/domain/facility.dart';
import '../../../booking/domain/booking_repository.dart';
import '../../../../core/theme/app_colors.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDate;
  String? _selectedTime;
  int _guests = 1;
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  bool get _canProceed => _selectedDate != null && _selectedTime != null;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitBooking(Facility facility) async {
    if (!_canProceed) return;
    setState(() => _isSubmitting = true);

    try {
      final repo = context.read<BookingRepository>();
      final formattedDate = _selectedDate!.toIso8601String().split('T')[0];

      final result = await repo.createPublic({
            'facilityId': facility.id,
            'date': formattedDate,
            'startTime': _selectedTime,
            'endTime': _calculateEndTime(_selectedTime!, facility.slotDuration),
            'partySize': _guests,
            'notes': _notesController.text.isEmpty ? null : _notesController.text,
            'bookingType': 'FACILITY',
          });

      if (mounted) {
        context.push('/booking-confirmation', extra: {
          'booking': result,
          'facility': facility,
          'date': _selectedDate,
          'time': _selectedTime,
          'guests': _guests,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<LanguageProvider>().t(
              'booking.error',
              fallback: 'Booking failed. Please try again.',
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

  String _calculateEndTime(String startTime, int slotDurationMin) {
    final parts = startTime.split(':');
    final hour = int.parse(parts[0]);
    final min = int.parse(parts[1]);
    final totalMin = hour * 60 + min + slotDurationMin;
    final endHour = totalMin ~/ 60;
    final endMin = totalMin % 60;
    return '${endHour.toString().padLeft(2, '0')}:${endMin.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().t;
    final lang = context.watch<LanguageProvider>().lang;
    final mode = context.watch<ModeProvider>();
    final isAcademy = mode.isAcademy;
    final cardBg = isAcademy ? AppColors.cream.withValues(alpha: 0.1) : AppColors.white;
    final textColor = isAcademy ? AppColors.cream : AppColors.text;
    final Facility? facility =
        GoRouterState.of(context).extra as Facility?;

    final facilityName = facility?.getName(lang) ??
        t('booking.defaultFacilityTitle', fallback: 'Facility Booking');
    final pricePerSlot = facility?.pricePerSlot ?? 0;
    final slotDuration = facility?.slotDuration ?? 30;

    return Scaffold(
      backgroundColor: isAcademy ? AppColors.academyNavy : AppColors.cream,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.arrow_back_ios,
                        color: textColor),
                  ),
                  Expanded(
                    child: Text(
                      t('booking.title', fallback: 'Book Facility'),
                      style: Theme.of(context).textTheme.displayLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Facility info
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: isAcademy ? AppColors.gold.withValues(alpha: 0.15) : AppColors.grayDark,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.fitness_center,
                              color: AppColors.gold,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  facilityName,
                                  style: Theme.of(context).textTheme.h4,
                                ),
                                const SizedBox(height: 2),
                                if (pricePerSlot > 0)
                                  Text(
                                    t('booking.priceFormat',
                                            fallback: 'SAR {price} / {duration}min')
                                        .replaceAll('{price}',
                                            pricePerSlot.toStringAsFixed(0))
                                        .replaceAll('{duration}',
                                            slotDuration.toString()),
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .copyWith(
                                          color: AppColors.gold,
                                        ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Date selection
                    Text(
                      t('booking.date', fallback: 'Select Date'),
                      style: Theme.of(context).textTheme.h4,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _DateSelector(
                      selectedDate: _selectedDate,
                      onSelect: (date) =>
                          setState(() => _selectedDate = date),
                      t: t,
                      isAcademy: isAcademy,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Time selection
                    Text(
                      t('booking.time', fallback: 'Select Time Slot'),
                      style: Theme.of(context).textTheme.h4,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _TimeSelector(
                      selectedTime: _selectedTime,
                      slotDuration: slotDuration,
                      onSelect: (time) =>
                          setState(() => _selectedTime = time),
                      isAcademy: isAcademy,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Number of guests
                    Text(
                      t('booking.guests', fallback: 'Number of Guests'),
                      style: Theme.of(context).textTheme.h4,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _GuestSelector(
                      guests: _guests,
                      onChanged: (n) =>
                          setState(() => _guests = n),
                      isAcademy: isAcademy,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Notes
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: t('booking.notes', fallback: 'Special requests...'),
                        hintStyle: TextStyle(
                          color: isAcademy ? AppColors.cream.withValues(alpha: 0.5) : AppColors.muted,
                        ),
                        filled: true,
                        fillColor: cardBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(color: textColor),
                    ),

                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
            // Bottom action bar
            Container(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg + MediaQuery.of(context).padding.bottom,
              ),
              color: isAcademy ? AppColors.academyNavy : AppColors.white,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canProceed && !_isSubmitting
                      ? () => _submitBooking(facility!)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.text,
                    disabledBackgroundColor: AppColors.grayDark,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.text,
                          ),
                        )
                      : Text(
                          t('booking.continue', fallback: 'Continue'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onSelect;
  final String Function(String, {String? fallback}) t;
  final bool isAcademy;

  const _DateSelector({
    required this.selectedDate,
    required this.onSelect,
    required this.t,
    this.isAcademy = false,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(14, (i) => today.add(Duration(days: i)));

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final date = days[index];
          final isSelected = selectedDate != null &&
              date.year == selectedDate!.year &&
              date.month == selectedDate!.month &&
              date.day == selectedDate!.day;

          return GestureDetector(
            onTap: () => onSelect(date),
            child: Container(
              width: 64,
              margin: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.gold
                    : isAcademy ? AppColors.cream.withValues(alpha: 0.1) : AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekDayShort(date.weekday, t),
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.cream
                          : isAcademy ? AppColors.cream.withValues(alpha: 0.6) : AppColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.cream
                          : AppColors.cream,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _monthShort(date.month, t),
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.cream
                          : isAcademy ? AppColors.cream.withValues(alpha: 0.6) : AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _weekDayShort(int weekday, String Function(String, {String? fallback}) t) {
    return t('calendar.day.$weekday', fallback: '');
  }

  String _monthShort(int month, String Function(String, {String? fallback}) t) {
    return t('calendar.month.$month', fallback: '');
  }
}

class _TimeSelector extends StatelessWidget {
  final String? selectedTime;
  final int slotDuration;
  final ValueChanged<String> onSelect;
  final bool isAcademy;

  const _TimeSelector({
    required this.selectedTime,
    required this.slotDuration,
    required this.onSelect,
    this.isAcademy = false,
  });

  @override
  Widget build(BuildContext context) {
    final slots = const [
      '16:00', '17:00', '18:00', '19:00', '20:00', '21:00', '22:00',
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: slots.map((slot) {
        final isSelected = selectedTime == slot;
        return GestureDetector(
          onTap: () => onSelect(slot),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.gold
                  : isAcademy ? AppColors.cream.withValues(alpha: 0.1) : AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? null
                  : Border.all(color: AppColors.grayDark),
            ),
            child: Text(
              slot,
              style: TextStyle(
                color: isSelected
                    ? AppColors.cream
                    : AppColors.cream,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _GuestSelector extends StatelessWidget {
  final int guests;
  final ValueChanged<int> onChanged;
  final bool isAcademy;

  const _GuestSelector({required this.guests, required this.onChanged, this.isAcademy = false});

  @override
  Widget build(BuildContext context) {
    final cardBg = isAcademy ? AppColors.cream.withValues(alpha: 0.1) : AppColors.white;
    final textColor = isAcademy ? AppColors.cream : AppColors.text;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: guests > 1 ? () => onChanged(guests - 1) : null,
            icon: Icon(Icons.remove_circle_outline,
                color: AppColors.gold),
          ),
          Text(
            '$guests',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            onPressed: guests < 50 ? () => onChanged(guests + 1) : null,
            icon: Icon(Icons.add_circle_outline,
                color: AppColors.gold),
          ),
        ],
      ),
    );
  }
}
