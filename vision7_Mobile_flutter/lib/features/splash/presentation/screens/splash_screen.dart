import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/auth_provider.dart';

/// Brand intro: gold Vision7 shield on navy, fades to the black Leisure
/// wordmark on cream. Always plays this fixed sequence — independent of
/// whichever Academy/Leisure mode is currently selected.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showLeisure = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1300), () {
      if (mounted) setState(() => _showLeisure = true);
    });
    Timer(const Duration(milliseconds: 2700), () {
      if (mounted) {
        final isAuthenticated = context.read<AuthProvider>().isAuthenticated;
        context.go(isAuthenticated ? '/home' : '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 700),
          child: _showLeisure ? const _LeisurePanel() : const _AcademyPanel(),
        ),
      ),
    );
  }
}

class _AcademyPanel extends StatelessWidget {
  const _AcademyPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('academy'),
      width: double.infinity,
      height: double.infinity,
      color: AppColors.academyNavy,
      child: Center(
        child: SvgPicture.asset(
          'assets/images/vision-logo.svg',
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _LeisurePanel extends StatelessWidget {
  const _LeisurePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('leisure'),
      width: double.infinity,
      height: double.infinity,
      color: AppColors.cream,
      child: Center(
        child: Image.asset(
          'assets/images/leisure-logo-black.png',
          width: 260,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
