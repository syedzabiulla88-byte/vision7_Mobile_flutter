import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/custom_text_theme.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/providers/mode_provider.dart';
import '../../../../shared/providers/app_mode.dart';
import '../../domain/membership_repository.dart';
import '../../domain/membership_models.dart';
import '../../../../core/theme/app_colors.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  bool _isLoadingPlans = true;
  bool _isLoadingMembership = true;
  String? _error;
  List<MembershipPlan> _plans = [];
  UserMembership? _activeMembership;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingPlans = true;
      _isLoadingMembership = true;
      _error = null;
    });
    try {
      final planRepo = context.read<MembershipPlanRepository>();
      final membershipRepo = context.read<UserMembershipRepository>();
      final plans = await planRepo.listPublic();
      final memberships = await membershipRepo.listMine();
      final active = memberships.isNotEmpty ? memberships.first : null;
      if (mounted) {
        setState(() {
          _plans = plans;
          _activeMembership = active;
          _isLoadingPlans = false;
          _isLoadingMembership = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoadingPlans = false;
          _isLoadingMembership = false;
        });
      }
    }
  }

  void _selectPayment(MembershipPlan plan) {
    context.push('/enquiry');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().t;
    final l = context.watch<LanguageProvider>().lang;
    final mode = context.watch<ModeProvider>();
    final isAcademy = mode.isAcademy;
    final mutedColor = isAcademy ? AppColors.cream.withValues(alpha: 0.6) : AppColors.muted;

    return Scaffold(
      backgroundColor: isAcademy ? AppColors.academyNavy : AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('membership.title', fallback: 'Membership'),
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_error != null)
                Center(
                  child: Column(
                    children: [
                      Text(t('membership.loadFailed', fallback: 'Failed to load membership data'), style: const TextStyle(color: AppColors.error)),
                      TextButton(onPressed: _loadData, child: Text(t('common.retry', fallback: 'Retry'))),
                    ],
                  ),
                )
              else if (_isLoadingMembership)
                const Center(child: CircularProgressIndicator(color: AppColors.gold))
              else
                _ActiveMembershipCard(membership: _activeMembership, lang: l, t: t, isAcademy: isAcademy),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t('membership.availablePlans', fallback: 'Available Plans'),
                    style: Theme.of(context).textTheme.h3,
                  ),
                  TextButton.icon(
                    onPressed: () => context.push('/invoices'),
                    icon: Icon(Icons.history, size: 18, color: mutedColor),
                    label: Text(
                      t('membership.history', fallback: 'History'),
                      style: TextStyle(color: mutedColor, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: _isLoadingPlans
                    ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                    : _plans.isEmpty
                        ? Center(
                            child: Text(
                              t('membership.noPlans', fallback: 'No plans available'),
                              style: TextStyle(color: mutedColor),
                            ),
                          )
                        : ListView(
                            children: _plans.map((plan) {
                              final isActive = _activeMembership?.planId == plan.id;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                child: MembershipPlanCard(
                                  plan: plan,
                                  lang: l,
                                  t: t,
                                  isActive: isActive,
                                  isAcademy: isAcademy,
                                  onUpgrade: isActive
                                      ? null
                                      : () => _selectPayment(plan),
                                ),
                              );
                            }).toList(),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveMembershipCard extends StatelessWidget {
  final UserMembership? membership;
  final AppLanguage lang;
  final String Function(String, {String? fallback}) t;
  final bool isAcademy;

  const _ActiveMembershipCard({
    required this.membership,
    required this.lang,
    required this.t,
    required this.isAcademy,
  });

  @override
  Widget build(BuildContext context) {
    final planLabel = t('membership.activePlan', fallback: 'Active Plan');
    final planTitle = membership?.planName ?? t('membership.plan.gold', fallback: 'Gold Membership');
    final cardBg = isAcademy ? AppColors.cream : AppColors.white;
    final mutedColor = isAcademy ? AppColors.muted : AppColors.muted;

    if (membership == null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.card_membership, color: AppColors.gold, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(planLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: mutedColor)),
                  const SizedBox(height: 2),
                  Text(
                    t('membership.noActive', fallback: 'No active membership'),
                    style: Theme.of(context).textTheme.h4,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.card_membership, color: AppColors.gold, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(planLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: mutedColor)),
                const SizedBox(height: 2),
                Text(planTitle, style: Theme.of(context).textTheme.h4),
                if (membership!.endDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '${t('membership.validUntil', fallback: 'Valid until')} ${membership!.endDate}',
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MembershipPlanCard extends StatelessWidget {
  final MembershipPlan plan;
  final AppLanguage lang;
  final String Function(String, {String? fallback}) t;
  final bool isActive;
  final bool isAcademy;
  final VoidCallback? onUpgrade;

  const MembershipPlanCard({
    super.key,
    required this.plan,
    required this.lang,
    required this.t,
    required this.isActive,
    required this.isAcademy,
    this.onUpgrade,
  });

  String get _name => lang == AppLanguage.ar && plan.nameAr != null ? plan.nameAr! : plan.name;

  @override
  Widget build(BuildContext context) {
    final cardBg = isAcademy ? AppColors.cream : AppColors.white;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: isActive ? Border.all(color: AppColors.gold, width: 1.5) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(_name, style: Theme.of(context).textTheme.h4),
              ),
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    t('membership.active', fallback: 'Active'),
                    style: const TextStyle(color: AppColors.text, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          if (plan.description != null && plan.description!.isNotEmpty)
            Text(
              lang == AppLanguage.ar && plan.descriptionAr != null ? plan.descriptionAr! : plan.description!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
          const SizedBox(height: AppSpacing.sm),
          if (plan.benefits.isNotEmpty) ...plan.benefits.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.check, size: 16, color: AppColors.gold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(f, style: Theme.of(context).textTheme.bodySmall),
                ),
              ],
            ),
          )),
          const SizedBox(height: AppSpacing.sm),
          if (!isActive)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onUpgrade,
                child: Text(t('common.enquireNow', fallback: 'Enquire Now')),
              ),
            ),
        ],
      ),
    );
  }

}
