import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../booking/domain/booking_repository.dart';
import '../../../booking/domain/booking.dart';
import '../../../../shared/providers/mode_provider.dart';
import '../../../../core/theme/app_colors.dart';

class BookingDetailScreen extends StatefulWidget {
  final String id;

  const BookingDetailScreen({super.key, required this.id});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  bool _isLoading = true;
  String? _error;
  Booking? _booking;

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = context.read<BookingRepository>();
      final booking = await repo.getById(widget.id);
      if (mounted) {
        setState(() {
          _booking = booking;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().t;
    final lang = context.watch<LanguageProvider>().lang;
    final mode = context.watch<ModeProvider>();
    final isAcademy = mode.isAcademy;
    final cardBg = isAcademy ? AppColors.cream.withValues(alpha: 0.1) : AppColors.white;
    final textColor = isAcademy ? AppColors.cream : AppColors.text;
    final mutedColor = isAcademy ? AppColors.cream.withValues(alpha: 0.6) : AppColors.muted;

    return Scaffold(
      backgroundColor: isAcademy ? AppColors.academyNavy : AppColors.cream,
      body: SafeArea(
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
                t('booking.detail.title', fallback: 'Booking Details'),
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                )
              else if (_error != null)
                Center(
                  child: Column(
                    children: [
                      Text(
                        t('booking.detail.failedToLoad', fallback: 'Failed to load booking'),
                        style: TextStyle(color: AppColors.error),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextButton(
                        onPressed: _loadBooking,
                        child: Text(t('common.retry', fallback: 'Retry')),
                      ),
                    ],
                  ),
                )
              else if (_booking != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _BookingRow(
                        label: t('booking.facility', fallback: 'Facility'),
                        value: _booking!.getName(lang),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _BookingRow(
                        label: t('booking.date', fallback: 'Date'),
                        value: _booking!.date,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _BookingRow(
                        label: t('booking.time', fallback: 'Time'),
                        value: _booking!.timeSlot,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _BookingRow(
                        label: t('booking.guests', fallback: 'Guests'),
                        value: '${_booking!.partySize}',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _BookingRow(
                        label: t('booking.status', fallback: 'Status'),
                        value: _statusLabel(_booking!.status),
                        valueColor: _statusColor(_booking!.status),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _BookingRow(
                        label: t('booking.id', fallback: 'Booking ID'),
                        value: _booking!.id,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _BookingRow(
                        label: t('booking.total', fallback: 'Total'),
                        value: 'SAR ${_booking!.totalPrice.toStringAsFixed(0)}',
                        valueColor: AppColors.gold,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (_booking!.status == 'confirmed')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.qr_code_outlined),
                      label: Text(t('booking.qrCode', fallback: 'Show QR Code')),
                    ),
                  ),
              ] else ...[
                Expanded(
                  child: Center(
                    child: Text(
                      t('booking.notFound', fallback: 'Booking not found'),
                      style: TextStyle(color: mutedColor),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    final t = context.read<LanguageProvider>().t;
    switch (status.toLowerCase()) {
      case 'confirmed':
        return t('booking.confirmed', fallback: 'Confirmed');
      case 'pending':
        return t('booking.pending', fallback: 'Pending');
      case 'cancelled':
        return t('booking.cancelled', fallback: 'Cancelled');
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColors.success;
      case 'pending':
        return AppColors.gold;
      case 'cancelled':
        return AppColors.errorLight;
      default:
        return AppColors.muted;
    }
  }
}

class _BookingRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _BookingRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
