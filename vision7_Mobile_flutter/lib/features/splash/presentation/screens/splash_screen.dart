import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/mode_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        final isAuthenticated = context.read<AuthProvider>().isAuthenticated;
        context.go(isAuthenticated ? '/home' : '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ModeProvider>();
    final isAcademy = mode.isAcademy;
    final bgColor = isAcademy ? AppColors.academyNavy : AppColors.cream;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/vision-logo.svg',
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 32),
              Image.asset(
                'assets/images/leisure-logo-1024.png',
                width: 220,
                height: 100,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
