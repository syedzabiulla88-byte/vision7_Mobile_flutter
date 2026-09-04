import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/custom_text_theme.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../booking/domain/booking.dart';
import '../../../explore/domain/facility.dart';
import '../../../../shared/providers/mode_provider.dart';
import '../../../../core/theme/app_colors.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().t;
    final lang = context.watch<LanguageProvider>().lang;
    final mode = context.watch<ModeProvider>();
    final isAcademy = mode.isAcademy;
    final cardBg = isAcademy ? AppColors.cream.withValues(alpha: 0.1) : AppColors.white;
    final textColor = isAcademy ? AppColors.cream : AppColors.text;
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;

    final Facility? facility = extra?['facility'];
    final DateTime? date = extra?['date'];
    final String? time = extra?['time'];
    final int? guests = extra?['guests'];
    final Booking? booking = extra?['booking'];

    final facilityName = facility?.getName(lang) ??
        t('booking.confirmation.facility', fallback: 'Facility');
    final dateStr = date != null ? _formatDate(date, t) : '';
    final total = booking?.totalPrice ?? (facility != null && time != null
        ? (facility.pricePerSlot ?? 0) *
            ((guests ?? 1) * ((facility.slotDuration).toDouble() / 60))
        : 0.0);

    return Scaffold(
      backgroundColor: isAcademy ? AppColors.academyNavy : AppColors.cream,
      // Scroll-safe wrapper (see login_screen.dart) — this Column's Spacer()
      // has no fallback when the confirmation card + both buttons don't fit
      // a shorter screen.
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - AppSpacing.lg * 2,
                ),
                child: IntrinsicHeight(
                  child: Column(
            children: [
              const SizedBox(height: AppSpacing.xxl),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, size: 40, color: textColor),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                t('booking.confirmed', fallback: 'Booking Confirmed!'),
                style: Theme.of(context).textTheme.h2,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                t('booking.confirmation.message', fallback: 'Your booking has been confirmed.'),
                style: Theme.of(context).textTheme.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _DetailRow(label: t('booking.facility', fallback: 'Facility'), value: facilityName, isAcademy: isAcademy),
                    const SizedBox(height: AppSpacing.sm),
                    _DetailRow(label: t('booking.date', fallback: 'Date'), value: dateStr, isAcademy: isAcademy),
                    const SizedBox(height: AppSpacing.sm),
                    _DetailRow(label: t('booking.time', fallback: 'Time'), value: time ?? '', isAcademy: isAcademy),
                    if (booking != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _DetailRow(
                        label: t('booking.id', fallback: 'Booking ID'),
                        value: booking.id,
                        isAcademy: isAcademy,
                      ),
                    ],
                    if (total > 0) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _DetailRow(
                        label: t('booking.total', fallback: 'Total'),
                        value: 'SAR ${total.toStringAsFixed(0)}',
                        isAcademy: isAcademy,
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined),
                  label: Text(t('common.share', fallback: 'Share Booking')),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/bookings'),
                  child: Text(t('common.viewBookings', fallback: 'View My Bookings')),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date, String Function(String, {String? fallback}) t) {
    return '${date.day} ${t('calendar.month.${date.month}', fallback: '')} ${date.year}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isAcademy;

  const _DetailRow({required this.label, required this.value, this.isAcademy = false});

  @override
  Widget build(BuildContext context) {
    final rowMuted = isAcademy ? AppColors.cream.withValues(alpha: 0.6) : AppColors.muted;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: rowMuted),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isAcademy ? AppColors.cream : AppColors.text,
          ),
        ),
      ],
    );
  }
}
