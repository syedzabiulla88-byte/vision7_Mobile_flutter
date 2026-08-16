import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_colors.dart';
import '../features/booking/data/booking_repository_impl.dart';
import '../features/booking/data/booking_remote_data_source.dart';
import '../features/booking/domain/booking_repository.dart';
import '../features/explore/data/facility_repository_impl.dart';
import '../features/explore/data/facility_remote_data_source.dart';
import '../features/explore/domain/facility_repository.dart';
import '../features/notifications/data/notification_repository_impl.dart';
import '../features/notifications/data/notification_remote_data_source.dart';
import '../features/notifications/domain/notification_repository.dart';
import '../features/profile/data/me_repository_impl.dart';
import '../features/profile/data/me_remote_data_source.dart';
import '../features/profile/domain/me_repository.dart';
import '../features/invoices/data/invoice_repository_impl.dart';
import '../features/invoices/data/invoice_remote_data_source.dart';
import '../features/invoices/domain/invoice_repository.dart';
import '../features/membership/data/membership_repository_impl.dart';
import '../features/membership/data/membership_remote_data_source.dart';
import '../features/membership/domain/membership_repository.dart';
import '../features/enquiry/data/enquiry_repository_impl.dart';
import '../features/enquiry/data/enquiry_remote_data_source.dart';
import '../features/enquiry/domain/enquiry_repository.dart';
import '../features/tour_booking/data/tour_repository_impl.dart';
import '../features/tour_booking/data/tour_remote_data_source.dart';
import '../features/tour_booking/domain/tour_repository.dart';
import '../features/notifications/presentation/providers/notifications_provider.dart';
import '../shared/services/push_notification_service.dart';
import '../shared/providers/auth_provider.dart';
import '../features/auth/data/auth_repository_impl.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/data/auth_remote_data_source.dart';
import '../core/network/dio_client.dart';
import '../shared/providers/language_provider.dart';
import '../shared/providers/mode_provider.dart';
import '../shared/providers/app_mode.dart';
import 'routes/router.dart';

class ProviderScope extends StatefulWidget {
  final Widget child;

  const ProviderScope({super.key, required this.child});

  @override
  State<ProviderScope> createState() => _ProviderScopeState();
}

class _ProviderScopeState extends State<ProviderScope> {
  late Future<SharedPreferences> _prefsFuture;

  @override
  void initState() {
    super.initState();
    _prefsFuture = SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: _prefsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.hasError || snapshot.data == null) {
          return const _SplashLoader();
        }

        final prefs = snapshot.data!;
        final dioClient = DioClient();
        final authRemote = AuthRemoteDataSource(dioClient);
        final authRepository = AuthRepositoryImpl(
          authRemote,
          const FlutterSecureStorage(),
          prefs,
        );
        final facilityRepository = FacilityRepositoryImpl(
          FacilityRemoteDataSource(dioClient),
        );
        final bookingRepository = BookingRepositoryImpl(
          BookingRemoteDataSource(dioClient),
        );
        final notificationRepository = NotificationRepositoryImpl(
          NotificationRemoteDataSource(dioClient),
        );
        final meRepository = MeRepositoryImpl(
          MeRemoteDataSource(dioClient),
        );
        final invoiceRepository = InvoiceRepositoryImpl(
          InvoiceRemoteDataSource(dioClient),
        );
        final membershipPlanRepository = MembershipPlanRepositoryImpl(
          MembershipPlanRemoteDataSource(dioClient),
        );
        final userMembershipRepository = UserMembershipRepositoryImpl(
          UserMembershipRemoteDataSource(dioClient),
        );
        final enquiryRepository = EnquiryRepositoryImpl(
          EnquiryRemoteDataSource(dioClient),
        );
        final tourRepository = TourRepositoryImpl(
          TourRemoteDataSource(dioClient),
        );
        final pushNotificationService = PushNotificationService(notificationRepository);

        return MultiProvider(
          providers: [
            Provider<SharedPreferences>.value(value: prefs),
            Provider<AuthRepository>.value(value: authRepository),
            Provider<FacilityRepository>.value(value: facilityRepository),
            Provider<BookingRepository>.value(value: bookingRepository),
            Provider<NotificationRepository>.value(
                value: notificationRepository),
            Provider<MeRepository>.value(value: meRepository),
            Provider<InvoiceRepository>.value(value: invoiceRepository),
            Provider<MembershipPlanRepository>.value(
                value: membershipPlanRepository),
            Provider<UserMembershipRepository>.value(
                value: userMembershipRepository),
            Provider<EnquiryRepository>.value(value: enquiryRepository),
            Provider<TourRepository>.value(value: tourRepository),
            ChangeNotifierProvider(create: (_) => LanguageProvider(prefs)),
            ChangeNotifierProvider(create: (_) => ModeProvider(prefs)),
            ChangeNotifierProvider(
              create: (_) => NotificationsProvider(notificationRepository),
            ),
            Provider<PushNotificationService>.value(value: pushNotificationService),
            ChangeNotifierProvider<AuthProvider>(
              create: (_) {
                final authProvider = AuthProvider(authRepository, pushNotificationService);
                updateRouterRefreshNotifier(authProvider);
                return authProvider;
              },
            ),
          ],
          child: const Vision7App(),
        );
      },
    );
  }
}

class _SplashLoader extends StatelessWidget {
  const _SplashLoader();

  // Matches SplashScreen's first frame (navy + gold Vision7 shield) so there's
  // no visual seam between this pre-SharedPreferences loader and the real,
  // animated splash that follows it.
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.academyNavy,
        body: Center(
          child: SvgPicture.asset(
            'assets/images/vision-logo.svg',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class Vision7App extends StatelessWidget {
  const Vision7App({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);

    return ListenableBuilder(
      listenable: Listenable.merge([
        Provider.of<ModeProvider>(context, listen: false),
        Provider.of<LanguageProvider>(context, listen: false),
      ]),
      builder: (context, child) {
        final modeProvider = Provider.of<ModeProvider>(context, listen: false);
        final theme = modeProvider.buildTheme(langProvider.lang);
        final locale = Locale(langProvider.lang == AppLanguage.ar ? 'ar' : 'en');

        return MaterialApp.router(
          title: 'Vision7',
          debugShowCheckedModeBanner: false,
          theme: theme,
          themeMode: modeProvider.isAcademy ? ThemeMode.dark : ThemeMode.light,
          locale: locale,
          localizationsDelegates: const [
            ...GlobalMaterialLocalizations.delegates,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('ar', ''),
          ],
          routerConfig: router,
          builder: (context, child) {
            return Directionality(
              textDirection: langProvider.isRTL ? TextDirection.rtl : TextDirection.ltr,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(1.0),
                ),
                child: child!,
              ),
            );
          },
        );
      },
    );
  }
}
