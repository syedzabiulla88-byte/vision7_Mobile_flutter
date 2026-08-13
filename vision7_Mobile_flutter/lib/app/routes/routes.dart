class AppRoutes {
  // Onboarding & Auth
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Tabs
  static const String home = '/home';
  static const String explore = '/explore';
  static const String bookings = '/bookings';
  static const String membership = '/membership';
  static const String profile = '/profile';

  // Detail screens
  static const String facilityDetail = '/facility/:slug';
  static const String book = '/book';
  static const String bookingConfirmation = '/booking-confirmation';
  static const String bookingDetail = '/bookings/:id';
  static const String invoiceDetail = '/membership/:id';
  static const String invoices = '/invoices';
  static const String notifications = '/notifications';
  static const String enquiry = '/enquiry';
  static const String tourBooking = '/tour-booking';

  // Academy
  static const String academyAbout = '/academy/about';
  static const String academyPrograms = '/academy/programs';
  static const String academyFacilities = '/academy/facilities';
  static const String academyCoaches = '/academy/coaches';
  static const String academyEvents = '/academy/events';
  static const String academyContact = '/academy/contact';
  static const String academyRegister = '/academy/register';
}
