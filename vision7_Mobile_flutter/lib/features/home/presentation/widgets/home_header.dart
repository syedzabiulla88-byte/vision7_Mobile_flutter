import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/custom_text_theme.dart';
import '../../../../shared/providers/language_provider.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().t;
    final hour = DateTime.now().hour;
    String greetingKey;
    if (hour < 12) {
      greetingKey = 'home.greeting.morning';
    } else if (hour < 17) {
      greetingKey = 'home.greeting.afternoon';
    } else {
      greetingKey = 'home.greeting.evening';
    }

    return Column(
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
    );
  }
}
