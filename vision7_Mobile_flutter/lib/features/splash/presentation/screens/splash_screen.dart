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
  bool _navigated = false;
  Timer? _fallbackTimer;
  late final AuthProvider _auth;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthProvider>();
    Timer(const Duration(milliseconds: 1300), () {
      if (mounted) setState(() => _showLeisure = true);
    });
    Timer(const Duration(milliseconds: 2700), _tryNavigate);
    // Safety net: never strand the user on the splash screen if auth
    // resolution somehow never finishes (e.g. a hung request).
    _fallbackTimer = Timer(const Duration(seconds: 8), _tryNavigate);
  }

  // AuthProvider's startup check (restoring a stored session, then a live
  // GET /auth/profile) is async and can easily outlast the fixed splash
  // animation on a slow connection or cold start. Reading isAuthenticated
  // before that resolves risked briefly routing an already-logged-in user
  // to /login. Wait for isLoading to clear instead of guessing.
  void _tryNavigate() {
    if (!mounted || _navigated) return;
    if (_auth.isLoading) {
      _auth.addListener(_onAuthChanged);
      return;
    }
    _navigate(_auth.isAuthenticated);
  }

  void _onAuthChanged() {
    if (_navigated || _auth.isLoading) return;
    _navigate(_auth.isAuthenticated);
  }

  void _navigate(bool isAuthenticated) {
    if (_navigated || !mounted) return;
    _navigated = true;
    _auth.removeListener(_onAuthChanged);
    _fallbackTimer?.cancel();
    context.go(isAuthenticated ? '/home' : '/login');
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _auth.removeListener(_onAuthChanged);
    super.dispose();
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
