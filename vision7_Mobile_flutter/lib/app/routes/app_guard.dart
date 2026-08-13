import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';


class AppGuard extends StatelessWidget {
  final bool isLoading;
  final bool isAuthenticated;
  final Widget child;

  const AppGuard({
    super.key,
    required this.isLoading,
    required this.isAuthenticated,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.dark,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
      );
    }

    if (!isAuthenticated) {
      // Will be handled by GoRouter redirect, but as a safety net:
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const SizedBox.shrink();
    }

    return child;
  }
}
