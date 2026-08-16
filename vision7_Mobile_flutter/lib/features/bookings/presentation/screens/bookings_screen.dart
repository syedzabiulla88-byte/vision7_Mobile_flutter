import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/custom_text_theme.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/providers/mode_provider.dart';
import '../../../../shared/providers/app_mode.dart';
import '../../../booking/domain/booking.dart';
import '../../../booking/domain/booking_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/pressable_card.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _error;
  List<Booking> _allBookings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = context.read<BookingRepository>();
      final bookings = await repo.listMyBookings();
      if (mounted) {
        setState(() {
          _allBookings = bookings;
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

  Future<void> _cancelBooking(Booking booking) async {
    final t = context.read<LanguageProvider>().t;
    final isAcademy = context.read<ModeProvider>().isAcademy;
    final dialogText = isAcademy ? AppColors.cream : AppColors.text;
    final dialogMuted = isAcademy ? AppColors.cream.withValues(alpha: 0.7) : AppColors.muted;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isAcademy ? AppColors.academyNavy : AppColors.white,
        title: Text(
          t('booking.cancel.title', fallback: 'Cancel Booking'),
          style: TextStyle(color: dialogText),
        ),
        content: Text(
          t(
            'booking.cancel.confirm',
            fallback:
                'Are you sure you want to cancel this booking for ${booking.date}?',
          ),
          style: TextStyle(color: dialogMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              t('common.no', fallback: 'No'),
              style: TextStyle(color: dialogMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              t('common.yes', fallback: 'Yes'),
              style: const TextStyle(color: AppColors.errorLight),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    if (mounted) {
      final repo = context.read<BookingRepository>();
      setState(() => _isLoading = true);
      try {
        await repo.cancel(booking.id);
        setState(() => _isLoading = false);
        HapticFeedback.lightImpact();
        await _loadBookings();
      } catch (e) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<Booking> _getFilteredBookings() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _allBookings.where((b) {
      final bookingDate = DateTime.tryParse(b.date);
      if (bookingDate == null) return true;
      if (_tabController.index == 0) {
        return !bookingDate.isBefore(today) && b.status != 'cancelled';
      } else {
        return bookingDate.isBefore(today) || b.status == 'cancelled';
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ModeProvider>();
    final isAcademy = mode.isAcademy;
    final lang = context.watch<LanguageProvider>().lang;
    final t = context.read<LanguageProvider>().t;
    final bgColor = isAcademy ? AppColors.academyNavy : AppColors.cream;
    final textColor = isAcademy ? AppColors.cream : AppColors.text;
    final mutedColor = isAcademy ? AppColors.cream.withValues(alpha: 0.6) : AppColors.muted;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm,
              ),
              child: Text(
                t('bookings.title', fallback: 'My Bookings'),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(color: textColor),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Container(
                decoration: BoxDecoration(
                  color: isAcademy ? AppColors.cream.withValues(alpha: 0.15) : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  onTap: (_) => setState(() {}),
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: isAcademy ? AppColors.gold : AppColors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  padding: EdgeInsets.zero,
                  labelColor: isAcademy ? AppColors.black : AppColors.cream,
                  unselectedLabelColor: mutedColor,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  tabs: [
                    Tab(
                      child: Text(t('bookings.upcoming', fallback: 'Upcoming')),
                    ),
                    Tab(
                      child: Text(t('bookings.past', fallback: 'Past')),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: _buildBookingList(lang, t, isAcademy),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(AppLanguage lang, String Function(String, {String? fallback}) t, bool isAcademy) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: isAcademy ? AppColors.gold : AppColors.black),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: _loadBookings,
              child: Text(t('common.retry', fallback: 'Retry')),
            ),
          ],
        ),
      );
    }

    final bookings = _getFilteredBookings();
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _tabController.index == 0
                  ? Icons.calendar_today_outlined
                  : Icons.history_outlined,
              size: 48,
              color: AppColors.muted,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _tabController.index == 0
                  ? t('bookings.noUpcoming', fallback: 'No upcoming bookings')
                  : t('bookings.noPast', fallback: 'No past bookings'),
              style: const TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final b = bookings[index];
        return _BookingCard(
          booking: b,
          lang: lang,
          t: t,
          isAcademy: isAcademy,
          onCancel: () => _cancelBooking(b),
        );
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final AppLanguage lang;
  final String Function(String, {String? fallback}) t;
  final VoidCallback? onCancel;
  final bool isAcademy;

  const _BookingCard({required this.booking, required this.lang, required this.t, required this.isAcademy, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(booking.status);
    final statusLabel = _statusLabel(booking.status, lang);
    final isUpcoming = booking.status.toLowerCase() != 'cancelled';
    final cardColor = isAcademy ? AppColors.cream : AppColors.white;
    final textColor = isAcademy ? AppColors.text : AppColors.text;
    final mutedColor = isAcademy ? AppColors.muted : AppColors.muted;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: PressableCard(
      isAcademy: isAcademy,
      onTap: () => context.push('/bookings/${booking.id}'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.getName(lang),
                    style: Theme.of(context).textTheme.h4.copyWith(color: textColor),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: mutedColor),
                const SizedBox(width: 6),
                Text(
                  booking.date,
                  style: TextStyle(color: mutedColor, fontSize: 13),
                ),
                const SizedBox(width: AppSpacing.md),
                Icon(Icons.access_time_outlined, size: 14, color: mutedColor),
                const SizedBox(width: 6),
                Text(
                  booking.timeSlot,
                  style: TextStyle(color: mutedColor, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lang == AppLanguage.ar
                      ? '${t('bookings.idLabelAr', fallback: 'رقم الحجز')}: ${booking.id}'
                      : '${t('bookings.idLabelEn', fallback: 'Booking ID')}: ${booking.id}',
                  style: TextStyle(color: mutedColor, fontSize: 12),
                ),
                Text(
                  booking.formattedTotal,
                  style: TextStyle(
                    color: isAcademy ? AppColors.gold : AppColors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            if (isUpcoming && onCancel != null) ...[
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: Icon(Icons.close, size: 16, color: mutedColor),
                  label: Text(
                    t('booking.cancel.label', fallback: 'Cancel Booking'),
                    style: TextStyle(color: mutedColor, fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: mutedColor, width: 1),
                    padding: const EdgeInsets.symmetric(vertical: 8),
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

  String _statusLabel(String status, AppLanguage lang) {
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
}
