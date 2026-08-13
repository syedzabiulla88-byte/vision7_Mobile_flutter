import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/custom_text_theme.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/providers/mode_provider.dart';
import '../../../../shared/providers/app_mode.dart';
import '../../domain/membership_models.dart';
import '../../domain/membership_repository.dart';
import '../../domain/payment_method_model.dart';
import '../../../../core/theme/app_colors.dart';

class PaymentMethodScreen extends StatefulWidget {
  final MembershipPlan plan;

  const PaymentMethodScreen({super.key, required this.plan});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  PaymentMethod? _selected;
  AppLanguage _lang = AppLanguage.en;

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().t;
    _lang = context.watch<LanguageProvider>().lang;
    final mode = context.watch<ModeProvider>();
    final isAcademy = mode.isAcademy;

    return Scaffold(
      backgroundColor: isAcademy ? AppColors.academyNavy : AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios, color: AppColors.cream),
              ),
              Text(
                t('payment.method', fallback: 'Payment Method'),
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                t('payment.selectMethod', fallback: 'Select how you want to pay'),
                style: Theme.of(context).textTheme.body.copyWith(
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ...PaymentMethod.values.map((method) {
                final isSelected = _selected == method;
                return _MethodTile(
                  method: method,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selected = method),
                  isAcademy: isAcademy,
                );
              }),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selected == null
                      ? null
                      : () => _confirmPurchase(context, t),
                  child: Text(
                    t('payment.confirm', fallback: 'Confirm & Pay'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmPurchase(BuildContext context, String Function(String, {String? fallback}) t) async {
    if (_selected == null) return;

    final plan = widget.plan;
    final planName = _lang == AppLanguage.ar && plan.nameAr != null
        ? plan.nameAr!
        : plan.name;

    final userMembershipRepo = context.read<UserMembershipRepository>();
    final scaffold = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        title: Text(
          t('payment.confirmTitle', fallback: 'Confirm Purchase'),
          style: const TextStyle(color: AppColors.cream),
        ),
        content: Text(
          t(
            'payment.confirmMessage',
            fallback:
                'Purchase $planName for ${plan.currency} ${plan.price.toStringAsFixed(2)}?',
          ),
          style: const TextStyle(color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t('common.cancel', fallback: 'Cancel'),
                style: const TextStyle(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t('common.confirm', fallback: 'Confirm'),
                style: const TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await userMembershipRepo.purchase(widget.plan.id);

      if (!mounted) return;

      scaffold.showSnackBar(
        SnackBar(
          content: Text(
            t(
              'payment.success',
              fallback: 'Payment successful! Membership activated.',
            ),
          ),
          backgroundColor: AppColors.success,
        ),
      );

      router.go('/membership');
    } catch (e) {
      if (!mounted) return;
      scaffold.showSnackBar(
        SnackBar(
          content: Text(
            t('payment.failed', fallback: 'Payment failed. Please try again.'),
          ),
          backgroundColor: AppColors.errorLight,
        ),
      );
    }
  }
}

class _MethodTile extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isAcademy;

  const _MethodTile({
    required this.method,
    required this.isSelected,
    required this.onTap,
    this.isAcademy = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isAcademy ? AppColors.cream.withValues(alpha: 0.1) : AppColors.white;
    final textColor = isSelected ? AppColors.gold : (isAcademy ? AppColors.cream : AppColors.muted);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold.withValues(alpha: 0.08) : cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.gold : (isAcademy ? AppColors.gold.withValues(alpha: 0.3) : AppColors.grayBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              method.icon,
              size: 28,
              color: isSelected ? AppColors.gold : (isAcademy ? AppColors.cream : AppColors.muted),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                method.label,
                style: TextStyle(
                  color: isSelected ? AppColors.gold : textColor,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.gold, size: 24),
          ],
        ),
      ),
    );
  }
}
