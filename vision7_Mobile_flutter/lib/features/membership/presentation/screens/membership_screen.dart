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
import '../../../../shared/widgets/pressable_card.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  bool _isLoadingMembership = true;
  String? _error;
  UserMembership? _activeMembership;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Neither mode shows a backend-driven plan list anymore (Academy uses 5
  // static cards, Leisure shows only the active membership's own details) —
  // just the current membership needs fetching.
  Future<void> _loadData() async {
    setState(() {
      _isLoadingMembership = true;
      _error = null;
    });
    try {
      final membershipRepo = context.read<UserMembershipRepository>();
      final memberships = await membershipRepo.listMine();
      final active = memberships.isNotEmpty ? memberships.first : null;
      if (mounted) {
        setState(() {
          _activeMembership = active;
          _isLoadingMembership = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoadingMembership = false;
        });
      }
    }
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t('membership.title', fallback: 'Membership'),
                    style: Theme.of(context).textTheme.displayLarge,
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
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        Center(child: CircularProgressIndicator(color: isAcademy ? AppColors.gold : AppColors.black))
                      else
                        _ActiveMembershipCard(membership: _activeMembership, lang: l, t: t, isAcademy: isAcademy),
                      if (isAcademy) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          t('membership.availablePlans', fallback: 'Available Plans'),
                          style: Theme.of(context).textTheme.h3,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ..._academyStaticPlans.map((plan) => Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: _StaticPlanCard(plan: plan, onEnquire: () => context.push('/enquiry', extra: plan.title)),
                            )),
                      ],
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
    final cardBg = isAcademy ? AppColors.cream.withValues(alpha: 0.05) : AppColors.white;
    final mutedColor = isAcademy ? AppColors.cream.withValues(alpha: 0.6) : AppColors.muted;

    if (membership == null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: (isAcademy ? AppColors.gold : AppColors.black).withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (isAcademy ? AppColors.gold : AppColors.black).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.card_membership, color: isAcademy ? AppColors.gold : AppColors.black, size: 28),
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

    final m = membership!;
    final accent = isAcademy ? AppColors.gold : AppColors.black;
    final daysRemaining = _daysUntil(m.endDate);
    final showRenewalReminder = m.status == 'active' && daysRemaining != null && daysRemaining <= 14;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.card_membership, color: accent, size: 28),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(planLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: mutedColor)),
                    const SizedBox(height: 2),
                    Text(planTitle, style: Theme.of(context).textTheme.h4),
                  ],
                ),
              ),
              _StatusBadge(status: m.status, t: t),
            ],
          ),
          if (m.startDate != null || m.endDate != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Divider(color: mutedColor.withValues(alpha: 0.3), height: 1),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                if (m.startDate != null)
                  Expanded(
                    child: _DateField(
                      label: t('membership.startDate', fallback: 'Start Date'),
                      value: _formatDate(m.startDate),
                      mutedColor: mutedColor,
                    ),
                  ),
                if (m.endDate != null)
                  Expanded(
                    child: _DateField(
                      label: t('membership.endDate', fallback: 'End Date'),
                      value: _formatDate(m.endDate),
                      mutedColor: mutedColor,
                    ),
                  ),
              ],
            ),
          ],
          if (showRenewalReminder) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8A33D).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active_outlined, size: 16, color: Color(0xFFE8A33D)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      daysRemaining == 0
                          ? t('membership.renewsToday', fallback: 'Renews today')
                          : t('membership.renewsIn', fallback: 'Renews in $daysRemaining days'),
                      style: const TextStyle(color: Color(0xFFE8A33D), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (m.familyMembers.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Divider(color: mutedColor.withValues(alpha: 0.3), height: 1),
            const SizedBox(height: AppSpacing.sm),
            Text(
              t('membership.familyMembers', fallback: 'Family Members'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: mutedColor, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            ...m.familyMembers.map((fm) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, size: 16, color: accent),
                      const SizedBox(width: 8),
                      Text(
                        fm.relation != null ? '${fm.name} (${fm.relation})' : fm.name,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  static int? _daysUntil(String? isoDate) {
    if (isoDate == null) return null;
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return null;
    final today = DateTime.now();
    final diff = DateTime(parsed.year, parsed.month, parsed.day)
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
    return diff < 0 ? null : diff;
  }

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  static String _formatDate(String? isoDate) {
    if (isoDate == null) return '—';
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return isoDate;
    return '${_monthNames[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final String Function(String, {String? fallback}) t;

  const _StatusBadge({required this.status, required this.t});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'active':
        color = const Color(0xFF3FB27F);
        label = t('membership.status.active', fallback: 'Active');
        break;
      case 'frozen':
        color = const Color(0xFF4C8FE0);
        label = t('membership.status.frozen', fallback: 'Frozen');
        break;
      case 'expired':
        color = const Color(0xFFE05A4C);
        label = t('membership.status.expired', fallback: 'Expired');
        break;
      case 'cancelled':
        color = const Color(0xFFE05A4C);
        label = t('membership.status.cancelled', fallback: 'Cancelled');
        break;
      default:
        color = const Color(0xFF9AA0A6);
        label = t('membership.status.pending', fallback: 'Pending');
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final Color mutedColor;

  const _DateField({required this.label, required this.value, required this.mutedColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: mutedColor, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _StaticPlan {
  final String? tag;
  final String title;
  final String? description;
  final List<String> benefits;
  final bool highlighted;

  const _StaticPlan({
    this.tag,
    required this.title,
    this.description,
    this.benefits = const [],
    this.highlighted = false,
  });
}

final List<_StaticPlan> _academyStaticPlans = [
  const _StaticPlan(
    tag: 'BEST VALUE',
    title: 'FULL SEASON',
    highlighted: true,
    benefits: [
      'World Leading Practitioners',
      'UEFA Qualified Coaches, With Top Premier League Club Experience',
      'State Of The Art European Equipment, Sourced By 1 Of Only 5 FIFA Approved Distributors Across The World',
      'FIFA Size Pitches',
      'State Of The Art Stadium Style Lighting',
      'All Staff Fully Vetted And Screened Ensuring DBS, Safeguarding, And First Aid Certified',
      'Head Of Medical + Fully Qualified Physiotherapy Team',
      'Fully Equipped Medical Room With All Emergency Medical Equipment On Site',
      'Emergency Action Plan Throughout Site',
      'x3 Outdoor Sessions Weekly',
      'Access To Our Indoor Performance Hub',
      'Competitive Fixtures And Tournaments',
      'Alignment And Relationships With World-Wide Clubs',
      'Talent Identification Opportunities Throughout Our Pathway',
      'Nutrition / Sport Psychology / Sports Science Monitoring',
      'SAFF & England National Team Standard Analysis Systems And Softwares',
      'Organised Schedule To Allow For Male And Female Sessions',
      'Mixture Of Male And Female Staff To Accommodate All',
      'Holistic Individual Development Plans',
    ],
  ),
  const _StaticPlan(
    title: 'QUARTERLY OPTION',
    description: 'A flexible option with limited benefits compared to the full season membership.',
  ),
  const _StaticPlan(
    title: '1-2-1 PRIVATE TECHNICAL COACHING',
    benefits: [
      'High-intensity personalized development',
      "Aligned to player's individual development plan",
      'Position-specific drills',
      'Video analysis (optional add-on)',
    ],
  ),
  const _StaticPlan(
    tag: 'FAMILY PACKAGE',
    title: '2 ADULT X 2 CHILDREN',
    highlighted: true,
    description: 'A bundled package designed for families training together at Vision7.',
    benefits: [
      '2 Adults Gym Membership',
      '2 Children Academy Membership',
      '1x Padel Booking Monthly',
      'Free Birthday Party',
      'x2 PT Sessions',
      'x2 Private Technical Coaching Sessions',
    ],
  ),
  const _StaticPlan(
    title: 'MINI KICKERS - 3 MONTHS',
    description: '2 Sessions per week for 3 months',
  ),
];

class _StaticPlanCard extends StatelessWidget {
  final _StaticPlan plan;
  final VoidCallback onEnquire;

  const _StaticPlanCard({required this.plan, required this.onEnquire});

  @override
  Widget build(BuildContext context) {
    return PressableCard(
      isAcademy: true,
      onTap: onEnquire,
      child: Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.academyNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (plan.tag != null)
            Container(
              width: double.infinity,
              color: AppColors.gold,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                plan.tag!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.academyNavy,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title,
                  style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800, fontSize: 18),
                ),
                if (plan.description != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    plan.description!,
                    style: TextStyle(color: AppColors.academyWhite.withValues(alpha: 0.75), fontSize: 13),
                  ),
                ],
                if (plan.benefits.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  ...plan.benefits.map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(Icons.check, size: 14, color: AppColors.gold),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                b,
                                style: TextStyle(color: AppColors.academyWhite.withValues(alpha: 0.85), fontSize: 13, height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: plan.highlighted
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.academyNavy,
                          ),
                          onPressed: onEnquire,
                          child: const Text('ENQUIRE NOW', style: TextStyle(fontWeight: FontWeight.w800)),
                        )
                      : OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.gold,
                            side: const BorderSide(color: AppColors.gold),
                          ),
                          onPressed: onEnquire,
                          child: const Text('ENQUIRE NOW', style: TextStyle(fontWeight: FontWeight.w800)),
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
}
