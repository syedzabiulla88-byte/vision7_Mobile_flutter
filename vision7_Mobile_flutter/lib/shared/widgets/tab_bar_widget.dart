import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../providers/mode_provider.dart';
import '../providers/language_provider.dart';

class TabBarWidget extends StatelessWidget {
  const TabBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ModeProvider>();
    final t = context.watch<LanguageProvider>().t;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: mode.isAcademy ? AppColors.academyNavy : AppColors.white,
      selectedItemColor: AppColors.gold,
      unselectedItemColor: AppColors.muted,
      elevation: 8,
      currentIndex: _getCurrentIndex(context),
      onTap: (index) => _onTap(context, index),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: t('tab.home', fallback: 'Home'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.explore_outlined),
          activeIcon: const Icon(Icons.explore),
          label: t('tab.explore', fallback: 'Explore'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.calendar_today_outlined),
          activeIcon: const Icon(Icons.calendar_today),
          label: t('tab.bookings', fallback: 'Bookings'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.card_membership_outlined),
          activeIcon: const Icon(Icons.card_membership),
          label: t('tab.membership', fallback: 'Membership'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          activeIcon: const Icon(Icons.person),
          label: t('tab.profile', fallback: 'Profile'),
        ),
      ],
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    switch (location) {
      case '/home': return 0;
      case '/explore': return 1;
      case '/bookings': return 2;
      case '/membership': return 3;
      case '/profile': return 4;
      default: return 0;
    }
  }

  void _onTap(BuildContext context, int index) {
    final routes = ['/home', '/explore', '/bookings', '/membership', '/profile'];
    context.go(routes[index]);
  }
}
