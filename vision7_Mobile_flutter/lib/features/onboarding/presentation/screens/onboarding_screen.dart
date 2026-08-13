import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/providers/mode_provider.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().t;
    final mode = context.watch<ModeProvider>();
    final isAcademy = mode.isAcademy;
    final textColor = isAcademy ? AppColors.cream : AppColors.text;

    return Scaffold(
      backgroundColor: isAcademy ? AppColors.academyNavy : AppColors.cream,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              t('onboarding.title', fallback: 'VISION7'),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/login'),
              child: Text(t('onboarding.getStarted', fallback: 'Get Started')),
            ),
          ],
        ),
      ),
    );
  }
}
