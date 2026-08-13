import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/custom_text_theme.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/providers/mode_provider.dart';
import '../../../../shared/providers/app_mode.dart';
import '../../../explore/domain/facility.dart';
import '../../../explore/domain/facility_repository.dart';
import '../../../../core/theme/app_colors.dart';

class FacilityDetailScreen extends StatefulWidget {
  final String? slug;

  const FacilityDetailScreen({
    super.key,
    this.slug,
  });

  @override
  State<FacilityDetailScreen> createState() => _FacilityDetailScreenState();
}

class _FacilityDetailScreenState extends State<FacilityDetailScreen> {
  bool _isLoading = true;
  String? _error;
  Facility? _facility;

  @override
  void initState() {
    super.initState();
    _loadFacility();
  }

  Future<void> _loadFacility() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = context.read<FacilityRepository>();
      final facilities = await repo.listPublic();
      Facility? found;
      if (widget.slug != null) {
        found = facilities.where((f) => f.id == widget.slug || f.name.toLowerCase().replaceAll(' ', '-') == widget.slug).firstOrNull;
      }
      if (found == null && facilities.isNotEmpty) {
        found = facilities.first;
      }

      if (found != null) {
        try {
          await repo.getAvailability(found.id, _todayDate());
          if (mounted) {
            setState(() {
              _facility = found;
              _isLoading = false;
            });
          }
        } catch (_) {
          if (mounted) {
            setState(() {
              _facility = found;
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
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

  String _todayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().t;
    final lang = context.watch<LanguageProvider>().lang;
    final mode = context.watch<ModeProvider>();
    final isAcademy = mode.isAcademy;
    final mutedColor = isAcademy ? AppColors.cream.withValues(alpha: 0.6) : AppColors.muted;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isAcademy ? AppColors.academyNavy : AppColors.cream,
        body: SafeArea(
          child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
        ),
      );
    }

    if (_error != null || _facility == null) {
      return Scaffold(
        backgroundColor: isAcademy ? AppColors.academyNavy : AppColors.cream,
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                Text(t('facility.notFound', fallback: 'Facility not found'), style: TextStyle(color: mutedColor)),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: _loadFacility,
                  child: Text(context.read<LanguageProvider>().t('common.retry', fallback: 'Retry')),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final f = _facility!;
    final priceDisplay = f.pricePerSlot != null
        ? 'SAR ${f.pricePerSlot!.toStringAsFixed(0)}'
        : null;

    return Scaffold(
      backgroundColor: isAcademy ? AppColors.academyNavy : AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, f, lang),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.getName(lang), style: Theme.of(context).textTheme.h2),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        _InfoBadge(text: f.category, icon: Icons.category_outlined, isAcademy: isAcademy),
                        const SizedBox(width: AppSpacing.sm),
                        if (priceDisplay != null)
                          _InfoBadge(
                            text: priceDisplay,
                            icon: Icons.attach_money,
                            iconColor: AppColors.gold,
                            isAcademy: isAcademy,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _InfoBadge(
                      text: '${f.slotDuration} min slots',
                      icon: Icons.access_time_outlined,
                      isAcademy: isAcademy,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      f.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      t('facility.amenities', fallback: 'Amenities'),
                      style: Theme.of(context).textTheme.h4,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: f.amenities
                          .map((a) => AmenityBadge(label: a, isAcademy: isAcademy))
                          .toList(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (f.openTime != null && f.closeTime != null) ...[
                      Text(
                        t('facility.hours', fallback: 'Hours'),
                        style: Theme.of(context).textTheme.h4,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${f.openTime} – ${f.closeTime}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: mutedColor,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
            _buildBottomBar(context, f, t),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Facility f, AppLanguage lang) {
    final isAcademy = context.watch<ModeProvider>().isAcademy;
    return Container(
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isAcademy
              ? [AppColors.academyNavy, AppColors.academyNavy.withValues(alpha: 0.85)]
              : [AppColors.grayDark, AppColors.cream],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Icon(
                _categoryIcon(f.category),
                size: 64,
                color: AppColors.gold.withValues(alpha: 0.4),
              ),
            ),
            Positioned(
              top: 8,
              left: 4,
              child: IconButton(
                onPressed: () => context.pop(),
                icon: Icon(Icons.arrow_back_ios, color: AppColors.cream),
              ),
            ),
            Positioned(
              top: 8,
              right: 4,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.favorite_border, color: AppColors.cream),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.share_outlined, color: AppColors.cream),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      f.getName(lang),
                      style: const TextStyle(
                        color: AppColors.cream,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, Facility f, String Function(String, {String? fallback}) t) {
    final bookLabel = t('common.bookNow', fallback: 'Book Now');
    final isAcademy = context.watch<ModeProvider>().isAcademy;
    final barColor = isAcademy ? AppColors.cream : AppColors.text;
    final btnFgColor = isAcademy ? AppColors.navy : AppColors.text;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(color: barColor),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: f.bookable
              ? () => context.push('/book', extra: f)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: btnFgColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            bookLabel,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Padel':
        return Icons.sports_tennis;
      case 'Football':
        return Icons.sports_soccer;
      case 'V7 Arena':
        return Icons.stadium;
      case 'Birthday':
        return Icons.cake;
      default:
        return Icons.fitness_center;
    }
  }
}

class _InfoBadge extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? iconColor;
  final bool isAcademy;

  const _InfoBadge({required this.text, required this.icon, this.iconColor, this.isAcademy = false});

  @override
  Widget build(BuildContext context) {
    final badgeBg = isAcademy ? AppColors.cream.withValues(alpha: 0.1) : AppColors.white;
    final badgeTextColor = isAcademy ? AppColors.cream : AppColors.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor ?? AppColors.gold),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: badgeTextColor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class AmenityBadge extends StatelessWidget {
  final String label;
  final bool isAcademy;

  const AmenityBadge({super.key, required this.label, this.isAcademy = false});

  @override
  Widget build(BuildContext context) {
    final badgeBg = isAcademy ? AppColors.cream.withValues(alpha: 0.1) : AppColors.white;
    final badgeBorderColor = isAcademy ? AppColors.cream.withValues(alpha: 0.2) : AppColors.grayDark;
    final badgeTextColor = isAcademy ? AppColors.cream : AppColors.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeBorderColor),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.caption.copyWith(
          color: badgeTextColor,
        ),
      ),
    );
  }
}
