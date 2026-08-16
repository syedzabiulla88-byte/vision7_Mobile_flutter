import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/bookings/presentation/screens/bookings_screen.dart';
import '../../features/membership/domain/membership_models.dart';
import '../../features/membership/presentation/screens/membership_screen.dart';
import '../../features/membership/presentation/screens/payment_method_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/facility_detail/presentation/screens/facility_detail_screen.dart';
import '../../features/booking/presentation/screens/booking_screen.dart';
import '../../features/booking/presentation/screens/booking_confirmation_screen.dart';
import '../../features/invoices/presentation/screens/invoice_detail_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/legal/presentation/screens/legal_screen.dart';
import '../../features/enquiry/presentation/screens/enquiry_screen.dart';
import '../../features/tour_booking/presentation/screens/tour_booking_screen.dart';
import '../../features/academy/presentation/screens/academy_about_screen.dart';
import '../../features/academy/presentation/screens/academy_programs_screen.dart';
import '../../features/academy/presentation/screens/academy_facilities_screen.dart';
import '../../features/academy/presentation/screens/academy_coaches_screen.dart';
import '../../features/academy/presentation/screens/academy_events_screen.dart';
import '../../features/academy/presentation/screens/academy_contact_screen.dart';
import '../../features/academy/presentation/screens/academy_register_screen.dart';
import '../../shared/widgets/tab_bar_widget.dart';
import '../../features/booking/presentation/screens/booking_detail_screen.dart';
import '../../shared/providers/auth_provider.dart';
import 'app_guard.dart';

// Bridge: forwards AuthProvider.notifyListeners to GoRouter's refreshListenable.
// This ensures redirects re-evaluate when auth state changes (login/logout).
class _GoRouterRefreshNotifier extends ChangeNotifier {
  AuthProvider? _auth;
  _GoRouterRefreshNotifier();

  void updateAuthProvider(AuthProvider auth) {
    _auth?.removeListener(notifyListeners);
    _auth = auth;
    _auth!.addListener(notifyListeners);
  }
}

final _routerRefreshNotifier = _GoRouterRefreshNotifier();

/// Call this after creating the AuthProvider in ProviderScope.
void updateRouterRefreshNotifier(AuthProvider auth) {
  _routerRefreshNotifier.updateAuthProvider(auth);
}

final router = GoRouter(
  initialLocation: '/',
  refreshListenable: _routerRefreshNotifier,
  redirect: (context, state) {
    final isAuthenticated = context.read<AuthProvider>().isAuthenticated;
    final isLoading = context.read<AuthProvider>().isLoading;
    final isLoginRoute = state.uri.toString() == '/login';
    final isRegisterRoute = state.uri.toString() == '/register';
    final isForgotRoute = state.uri.toString() == '/forgot-password';
    final isPublicRoute = isLoginRoute || isRegisterRoute || isForgotRoute || state.uri.toString() == '/' || state.uri.toString() == '/onboarding';

    if (isLoading) return null;

    // Let splash screen show at '/' — it handles its own navigation after 2.5s
    if (state.uri.toString() == '/') return null;

    if (!isAuthenticated && !isPublicRoute) {
      return '/login';
    }

    if (isAuthenticated && isPublicRoute) {
      return '/home';
    }

    return null;
  },
  routes: [
    // Splash screen (dual-logo animation before login)
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),

    // Onboarding
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Auth routes
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // Shell route (tab bar + nested screens)
    ShellRoute(
      builder: (context, state, child) {
        final auth = context.watch<AuthProvider>();
        return AppGuard(
          isLoading: auth.isLoading,
          isAuthenticated: auth.isAuthenticated,
          child: TabScaffold(child: child),
        );
      },
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/explore', builder: (_, __) => const ExploreScreen()),
        GoRoute(path: '/bookings', builder: (_, __) => const BookingsScreen()),
        GoRoute(path: '/membership', builder: (_, __) => const MembershipScreen()),
        GoRoute(
          path: '/payment',
          builder: (context, state) {
            final plan = state.extra as MembershipPlan?;
            if (plan == null) {
              return const SizedBox.shrink();
            }
            return PaymentMethodScreen(plan: plan);
          },
        ),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      ],
    ),

    // Detail screens (outside tabs)
    GoRoute(
      path: '/facility/:slug',
      builder: (context, state) {
        final slug = state.pathParameters['slug'] ?? '';
        return FacilityDetailScreen(slug: slug);
      },
    ),
    GoRoute(
      path: '/book',
      builder: (_, __) => const BookingScreen(),
    ),
    GoRoute(
      path: '/booking-confirmation',
      builder: (_, __) => const BookingConfirmationScreen(),
    ),
    GoRoute(
      path: '/bookings/:id',
      builder: (context, state) =>
          BookingDetailScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/membership/:id',
      builder: (context, state) =>
          InvoiceDetailScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/invoices',
      builder: (_, __) => const InvoiceDetailScreen(id: ''),
    ),
    GoRoute(
      path: '/notifications',
      builder: (_, __) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/terms',
      builder: (_, __) => const LegalScreen(document: LegalDocument.terms),
    ),
    GoRoute(
      path: '/privacy',
      builder: (_, __) => const LegalScreen(document: LegalDocument.privacy),
    ),
    GoRoute(
      path: '/enquiry',
      builder: (_, state) => EnquiryScreen(packageName: state.extra as String?),
    ),
    GoRoute(
      path: '/tour-booking',
      builder: (_, __) => const TourBookingScreen(),
    ),

    // Academy screens
    GoRoute(
      path: '/academy/about',
      builder: (_, __) => const AcademyAboutScreen(),
    ),
    GoRoute(
      path: '/academy/programs',
      builder: (_, __) => const AcademyProgramsScreen(),
    ),
    GoRoute(
      path: '/academy/facilities',
      builder: (_, __) => const AcademyFacilitiesScreen(),
    ),
    GoRoute(
      path: '/academy/coaches',
      builder: (_, __) => const AcademyCoachesScreen(),
    ),
    GoRoute(
      path: '/academy/events',
      builder: (_, __) => const AcademyEventsScreen(),
    ),
    GoRoute(
      path: '/academy/contact',
      builder: (_, __) => const AcademyContactScreen(),
    ),
    GoRoute(
      path: '/academy/register',
      builder: (_, __) => const AcademyRegisterScreen(),
    ),
  ],
);

// TabScaffold with BottomNavigationBar
class TabScaffold extends StatelessWidget {
  final Widget child;
  const TabScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const TabBarWidget(),
    );
  }
}
