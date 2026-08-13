import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/custom_text_theme.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/providers/mode_provider.dart';
import '../../../../core/theme/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().t;
    final mode = context.watch<ModeProvider>();
    final isAcademy = mode.isAcademy;
    final hour = DateTime.now().hour;
    String greetingKey;
    if (hour < 12) {
      greetingKey = 'home.greeting.morning';
    } else if (hour < 17) {
      greetingKey = 'home.greeting.afternoon';
    } else {
      greetingKey = 'home.greeting.evening';
    }

    final cardFill = isAcademy
        ? AppColors.cream.withValues(alpha: 0.1)
        : AppColors.navy.withValues(alpha: 0.07);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t(greetingKey),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                t('home.title'),
                style: Theme.of(context).textTheme.h3,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: cardFill,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: IconButton(
            onPressed: () => context.push('/notifications'),
            icon: Icon(Icons.notifications_outlined, color: AppColors.gold, size: 22),
          ),
        ),
      ],
    );
  }
}
