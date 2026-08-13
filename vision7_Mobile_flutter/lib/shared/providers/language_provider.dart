import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_mode.dart';

class LanguageProvider extends ChangeNotifier {
  static const _key = 'vision7-lang';
  final SharedPreferences _prefs;

  AppLanguage _lang = AppLanguage.en;
  bool _isReady = false;

  LanguageProvider(this._prefs) {
    _loadLanguage();
  }

  static LanguageProvider of(BuildContext context) {
    return Provider.of<LanguageProvider>(context, listen: false);
  }

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      // Common
      'common.loading': 'Loading...',
      'common.error': 'Error',
      'common.cancel': 'Cancel',
      'common.back': 'Back',
      'common.noResults': 'No results found',
      'common.bookNow': 'Book Now',
      'common.exploreMembership': 'Explore Membership',
      'common.enquireNow': 'Enquire Now',
      'common.save': 'Save',
      'common.delete': 'Delete',
      'common.confirm': 'Confirm',
      'common.success': 'Success',
      'common.retry': 'Retry',
      'common.ok': 'OK',
      'common.share': 'Share',
      'common.viewBookings': 'View My Bookings',
      'common.idToken': 'ID Token',

      // Auth
      'auth.loginTitle': 'Welcome Back',
      'auth.loginSubtitle': 'Sign in to your Vision7 account',
      'auth.email': 'Email',
      'auth.password': 'Password',
      'auth.signIn': 'Sign In',
      'auth.signInWithBiometrics': 'Sign in with Biometrics',
      'auth.forgotPassword': 'Forgot password?',
      'auth.resetPassword': 'Reset Password',
      'auth.noAccount': "Don't have an account?",
      'auth.hasAccount': 'Already have an account?',
      'auth.signUp': 'Sign Up',
      'auth.validation.emailRequired': 'Email is required',
      'auth.validation.emailInvalid': 'Invalid email address',
      'auth.validation.passwordRequired': 'Password is required',
      'auth.validation.passwordMinLength': 'Password must be at least 8 characters',
      'auth.validation.nameRequired': 'Name is required',
      'auth.logout': 'Logout',
      'auth.logoutConfirm': 'Are you sure you want to logout?',
      'auth.google': 'Google',
      'auth.apple': 'Apple',
      'auth.orContinueWith': 'Or continue with',
      'auth.orSignInWith': 'Or sign in with',
      'auth.googleSignIn': 'Google Sign-In',
      'auth.appleSignIn': 'Apple Sign-In',
      'auth.emailHint': 'your@email.com',
      'auth.passwordHint': 'Enter password',
      'auth.confirmPasswordHint': 'Enter password',

      // Register
      'register.title': 'Create Account',
      'register.subtitle': 'Join Vision7 today',
      'register.name': 'Full Name',
      'register.email': 'Email Address',
      'register.password': 'Password',
      'register.confirmPassword': 'Confirm Password',
      'register.phone': 'Phone Number (optional)',
      'register.gender': 'Gender (optional)',
      'register.createAccount': 'Create Account',
      'register.nameHint': 'Enter your full name',
      'register.emailHint': 'your@email.com',
      'register.passwordHint': 'Enter password',

      // Forgot Password
      'forgot.title': 'Reset Password',
      'forgot.subtitle': 'Enter your email to receive reset instructions',
      'forgot.sendLink': 'Send Reset Link',
      'forgot.sent': 'Check your email for reset instructions',
      'forgot.emailHint': 'your@email.com',
      'forgot.backToLogin': 'Back to login',

      // Onboarding
      'onboarding.welcome': 'Welcome to Vision7',
      'onboarding.title': 'VISION7',
      'onboarding.subtitle': 'Your premium wellness and sports destination',
      'onboarding.next': 'Next',
      'onboarding.getStarted': 'Get Started',
      'onboarding.skip': 'Skip',

      // Home
      'home.title': 'Welcome to Vision7',
      'home.subtitle': 'Your premium wellness and sports experience',
      'home.greeting.morning': 'Good Morning',
      'home.greeting.afternoon': 'Good Afternoon',
      'home.greeting.evening': 'Good Evening',
      'home.experiencesTitle': 'Experiences',
      'home.focusAreasTitle': 'What Sets Us Apart',
      'home.bookATour': 'Book a Tour',
      'home.exploreMore': 'Explore More',
      'home.viewAll': 'View All',
      'home.experience.padel': 'Padel',
      'home.experience.football5': '5-A-SIDE',
      'home.experience.football7': '7-A-SIDE',
      'home.experience.football9': '9-A-SIDE',
      'home.experience.football11': '11-A-SIDE',
      'home.experience.v7arena': 'V7 Arena',
      'home.experience.birthday': 'Birthday',
      'home.experience.padel.subtitle': 'World-class courts',
      'home.experience.football.subtitle': 'Book a pitch',
      'home.experience.football11.subtitle': 'Full field',
      'home.experience.football9.subtitle': '3VS3 Smart Pitch',
      'home.experience.birthday.subtitle': 'Packages available',
      'home.focusArea.premium': 'Premium Quality',
      'home.focusArea.coaches': 'Expert Coaches',
      'home.focusArea.booking': 'Easy Booking',

      // Academy
      'academy.home.title': 'Vision7 Academy',
      'academy.home.subtitle': 'Developing champions, one pitch at a time',
      'academy.pillar.passion': 'Passion',
      'academy.pillar.excellence': 'Excellence',
      'academy.pillar.integrity': 'Integrity',
      'academy.pillar.community': 'Community',
      'academy.pillar.coaching': 'Expert Coaching',
      'academy.pillar.development': 'Player Development',
      'academy.pillar.competition': 'Competition',
      'academy.about.title': 'About Academy',
      'academy.programs': 'Programs',
      'academy.facilities': 'Facilities',
      'academy.coaches': 'Coaches',
      'academy.events': 'Events',
      'academy.contact': 'Contact',
      'academy.register': 'Register',
      'academy.registerCta': 'Register Your Interest',
      'academy.register.hint.fullName': 'Full name',
      'academy.register.hint.parentName': 'Full name',
      'academy.register.hint.age': 'Age',
      'academy.register.hint.program': 'Select program',
      'academy.quickLink.programs': 'Programs',
      'academy.quickLink.facilities': 'Facilities',
      'academy.quickLink.coaches': 'Coaches',
      'academy.quickLink.events': 'Events',
      'academy.quickLink.contact': 'Contact',
      'academy.quickLink.register': 'Register',

      // Explore
      'explore.title': 'Explore',
      'explore.search': 'Search facilities...',
      'explore.all': 'All',
      'explore.noResults': 'No facilities found',
      'explore.filterBy': 'Filter by category',
      'explore.category.padel': 'Padel',
      'explore.category.football': 'Football',
      'explore.category.v7arena': 'V7 Arena',
      'explore.category.birthday': 'Birthday',
      'explore.category.other': 'Other',

      // Booking
      'booking.title': 'Book Facility',
      'booking.confirm': 'Confirm Booking',
      'booking.yourDetails': 'Your Details',
      'booking.name': 'Full Name',
      'booking.email': 'Email',
      'booking.phone': 'Phone Number',
      'booking.date': 'Date',
      'booking.time': 'Time',
      'booking.facility': 'Facility',
      'booking.price': 'Price',
      'booking.guests': 'Guests',
      'booking.status': 'Status',
      'booking.confirmed': 'Confirmed',
      'booking.pending': 'Pending',
      'booking.cancelled': 'Cancelled',
      'booking.confirmationTitle': 'Booking Confirmed!',
      'booking.confirmationMsg': 'Your booking has been confirmed',
      'booking.share': 'Share',
      'booking.close': 'Close',
      'booking.qrCode': 'Show QR Code',
      'booking.id': 'Booking ID',
      'booking.total': 'Total',
      'booking.detail.title': 'Booking Details',
      'booking.facilityNotFound': 'Facility not found',
      'booking.notFound': 'Booking not found',
      'booking.priceFormat': 'SAR {price} / {duration}min',
      'booking.pricePerSlot': 'SAR {price}',
      'booking.slotDuration': '{duration} min slots',

      // Bookings
      'bookings.title': 'My Bookings',
      'bookings.upcoming': 'Upcoming',
      'bookings.past': 'Past',
      'bookings.noBookings': 'No bookings yet',
      'bookings.noBookingsSubtitle': 'Explore facilities and make your first booking',
      'bookings.cancelled': 'Cancelled',
      'bookings.noUpcoming': 'No upcoming bookings',
      'bookings.noPast': 'No past bookings',
      'bookings.idLabelEn': 'Booking ID',
      'bookings.idLabelAr': 'رقم الحجز',

      // Booking
      'booking.defaultFacility': 'Facility Booking',
      'booking.detail.failedToLoad': 'Failed to load booking',

      // Facility
      'facility.amenities': 'Amenities',
      'facility.hours': 'Hours',
      'facility.notFound': 'Facility not found',

      // Calendar
      'calendar.day.1': 'Mon',
      'calendar.day.2': 'Tue',
      'calendar.day.3': 'Wed',
      'calendar.day.4': 'Thu',
      'calendar.day.5': 'Fri',
      'calendar.day.6': 'Sat',
      'calendar.day.7': 'Sun',
      'calendar.month.1': 'January',
      'calendar.month.2': 'February',
      'calendar.month.3': 'March',
      'calendar.month.4': 'April',
      'calendar.month.5': 'May',
      'calendar.month.6': 'June',
      'calendar.month.7': 'July',
      'calendar.month.8': 'August',
      'calendar.month.9': 'September',
      'calendar.month.10': 'October',
      'calendar.month.11': 'November',
      'calendar.month.12': 'December',

      // Tab Bar
      'tab.home': 'Home',
      'tab.explore': 'Explore',
      'tab.bookings': 'Bookings',
      'tab.membership': 'Membership',
      'tab.profile': 'Profile',

      // Home
      'home.tourSubtitle': 'See our facilities in person',

      // Membership
      'membership.title': 'Membership',
      'membership.active': 'Active Plan',
      'membership.invoices': 'Invoices',
      'membership.plans': 'Available Plans',
      'membership.enquire': 'Enquire',
      'membership.subscribe': 'Subscribe',
      'membership.invoiceDetail': 'Invoice Details',
      'membership.invoiceItems': 'Items',
      'membership.invoiceTotal': 'Total',
      'membership.invoiceDate': 'Date',
      'membership.invoiceStatus': 'Status',
      'membership.invoicePaid': 'Paid',
      'membership.invoicePending': 'Pending',
      'membership.noInvoices': 'No invoices yet',
      'membership.activePlan': 'Active Plan',
      'membership.noActive': 'No active membership',
      'membership.validUntil': 'Valid until',
      'membership.upgrade': 'Upgrade',
      'membership.availablePlans': 'Available Plans',
      'membership.history': 'History',
      'membership.noPlans': 'No plans available',
      'membership.plan.gold': 'Gold Membership',
      'membership.period.month': 'mo',
      'membership.period.day': 'day',

      // Profile
      'profile.title': 'Profile',
      'profile.account': 'Account',
      'profile.preferences': 'Preferences',
      'profile.about': 'About',
      'profile.bookings': 'My Bookings',
      'profile.membership': 'Membership',
      'profile.invoices': 'Invoices',
      'profile.notifications': 'Notifications',
      'profile.language': 'Language',
      'profile.languageCurrent': 'English',
      'profile.languageOptionEn': 'English',
      'profile.languageOptionAr': 'العربية',
      'profile.mode': 'Mode',
      'profile.leisureMode': 'Leisure',
      'profile.academyMode': 'Academy',
      'profile.privacyPolicy': 'Privacy Policy',
      'profile.termsOfService': 'Terms of Service',
      'profile.aboutApp': 'About Vision7',
      'profile.version': 'Version',
      'profile.guestUser': 'Guest User',
      'profile.memberSince': 'Member since',
      'profile.failedToLoad': 'Failed to load profile',
      'profile.editProfile': 'Edit Profile',

      // Enquiry
      'enquiry.title': 'Enquiry',
      'enquiry.subtitle': 'Tell us about your requirements',
      'enquiry.membershipType': 'Membership Type',
      'enquiry.fitnessGoal': 'Fitness Goal',
      'enquiry.experience': 'Experience Level',
      'enquiry.preferredTime': 'Preferred Time',
      'enquiry.howHeard': 'How did you hear about us?',
      'enquiry.message': 'Message',
      'enquiry.hint.name': 'Enter your name',
      'enquiry.hint.message': 'Tell us more...',
      'enquiry.submit': 'Submit Enquiry',
      'enquiry.success': 'Enquiry submitted successfully!',

      // Tour Booking
      'tourBooking.title': 'Book a Tour',
      'tourBooking.subtitle': 'Schedule your visit to Vision7',
      'tourBooking.selectDate': 'Select Date',
      'tourBooking.selectTime': 'Select Time',
      'tourBooking.yourInfo': 'Your Information',
      'tourBooking.interests': 'Areas of Interest',
      'tourBooking.confirm': 'Confirm Booking',
      'tourBooking.success': 'Tour booked successfully!',
      'tour.hint.name': 'Enter your full name',

      // Notifications
      'notifications.title': 'Notifications',
      'notifications.noNotifications': 'No notifications yet',
      'notifications.markAllRead': 'Mark all as read',
      'notifications.justNow': 'Just now',

      // Facility Detail
      'facilityDetail.amenities': 'Amenities',
      'facilityDetail.hours': 'Opening Hours',
      'facilityDetail.description': 'Description',
      'facilityDetail.bookNow': 'Book Now',
      'facilityDetail.availableSlots': 'Available Slots',
      'facilityDetail.noSlots': 'No slots available',
      'facilityDetail.genderRule': 'Gender Rule',
      'facilityDetail.mixed': 'Mixed',
      'facilityDetail.maleOnly': 'Male Only',
      'facilityDetail.femaleOnly': 'Female Only',
      'facilityDetail.pricePerSlot': 'Per Slot',
      'facilityDetail.duration': 'Duration',
    },  // end 'en'
    'ar': {
      // Common
      'common.loading': 'جاري التحميل...',
      'common.error': 'خطأ',
      'common.cancel': 'إلغاء',
      'common.back': 'رجوع',
      'common.noResults': 'لا توجد نتائج',
      'common.bookNow': 'احجز الآن',
      'common.exploreMembership': 'استكشف العضوية',
      'common.enquireNow': 'استفسر الآن',
      'common.save': 'حفظ',
      'common.delete': 'حذف',
      'common.confirm': 'تأكيد',
      'common.success': 'نجح',
      'common.retry': 'إعادة المحاولة',
      'common.ok': 'موافق',
      'common.share': 'مشاركة',
      'common.viewBookings': 'عرض حجوزاتي',
      'common.idToken': 'رمز الهوية',

      // Auth
      'auth.loginTitle': 'مرحباً بعودتك',
      'auth.loginSubtitle': 'تسجيل الدخول إلى حساب Vision7',
      'auth.email': 'البريد الإلكتروني',
      'auth.password': 'كلمة المرور',
      'auth.signIn': 'تسجيل الدخول',
      'auth.signInWithBiometrics': 'تسجيل الدخول بالبصمة',
      'auth.forgotPassword': 'نسيت كلمة المرور؟',
      'auth.resetPassword': 'إعادة تعيين كلمة المرور',
      'auth.noAccount': 'ليس لديك حساب؟',
      'auth.hasAccount': 'لديك حساب بالفعل؟',
      'auth.signUp': 'إنشاء حساب',
      'auth.validation.emailRequired': 'البريد الإلكتروني مطلوب',
      'auth.validation.emailInvalid': 'عنوان بريد إلكتروني غير صالح',
      'auth.validation.passwordRequired': 'كلمة المرور مطلوبة',
      'auth.validation.passwordMinLength': 'يجب أن تكون كلمة المرور 8 أحرف على الأقل',
      'auth.validation.nameRequired': 'الاسم مطلوب',
      'auth.logout': 'تسجيل الخروج',
      'auth.logoutConfirm': 'هل أنت متأكد من تسجيل الخروج؟',
      'auth.google': 'جوجل',
      'auth.apple': 'آبل',
      'auth.orContinueWith': 'أو استمر بـ',
      'auth.orSignInWith': 'أو سجل الدخول بـ',
      'auth.googleSignIn': 'تسجيل الدخول بجوجل',
      'auth.appleSignIn': 'تسجيل الدخول بآبل',
      'auth.emailHint': 'بريدك@example.com',
      'auth.passwordHint': 'أدخل كلمة المرور',
      'auth.confirmPasswordHint': 'أدخل كلمة المرور',

      // Register
      'register.title': 'إنشاء حساب',
      'register.subtitle': 'انضم إلى Vision7 اليوم',
      'register.name': 'الاسم الكامل',
      'register.email': 'البريد الإلكتروني',
      'register.password': 'كلمة المرور',
      'register.confirmPassword': 'تأكيد كلمة المرور',
      'register.phone': 'رقم الهاتف (اختياري)',
      'register.gender': 'الجنس (اختياري)',
      'register.createAccount': 'إنشاء الحساب',
      'register.nameHint': 'أدخل اسمك الكامل',
      'register.emailHint': 'بريدك@example.com',
      'register.passwordHint': 'أدخل كلمة المرور',

      // Forgot Password
      'forgot.title': 'إعادة تعيين كلمة المرور',
      'forgot.subtitle': 'أدخل بريدك الإلكتروني لتلقي تعليمات إعادة التعيين',
      'forgot.sendLink': 'إرسال رابط إعادة التعيين',
      'forgot.sent': 'تحقق من بريدك الإلكتروني لتعليمات إعادة التعيين',
      'forgot.emailHint': 'بريدك@example.com',
      'forgot.backToLogin': 'العودة لتسجيل الدخول',

      // Onboarding
      'onboarding.welcome': 'مرحباً بك في Vision7',
      'onboarding.title': 'VISION7',
      'onboarding.subtitle': 'وجهتك المتميزة للرفاهية والرياضة',
      'onboarding.next': 'التالي',
      'onboarding.getStarted': 'ابدأ',
      'onboarding.skip': 'تخطي',

      // Home
      'home.title': 'مرحباً بك في Vision7',
      'home.subtitle': 'تجربتك المتميزة للرفاهية والرياضة',
      'home.greeting.morning': 'صباح الخير',
      'home.greeting.afternoon': 'مساء الخير',
      'home.greeting.evening': 'مساء الخير',
      'home.experiencesTitle': 'التجارب',
      'home.focusAreasTitle': 'ما يميزنا',
      'home.bookATour': 'احجز جولة',
      'home.exploreMore': 'استكشف المزيد',
      'home.viewAll': 'عرض الكل',
      'home.experience.padel': 'بادل',
      'home.experience.football5': '5 لاعبين',
      'home.experience.football7': '7 لاعبين',
      'home.experience.football9': '9 لاعبين',
      'home.experience.football11': '11 لاعب',
      'home.experience.v7arena': 'V7 أرينا',
      'home.experience.birthday': 'حفلات الأعياد',
      'home.experience.padel.subtitle': 'ملاعب عالمية المستوى',
      'home.experience.football.subtitle': 'احجز ملعب',
      'home.experience.football11.subtitle': 'ملعب كامل',
      'home.experience.football9.subtitle': 'ملعب ذكي 3 ضد 3',
      'home.experience.birthday.subtitle': 'باقات متاحة',
      'home.focusArea.premium': 'جودة عالية',
      'home.focusArea.coaches': 'مدربون محترفون',
      'home.focusArea.booking': 'حجز سهل',

      // Academy
      'academy.home.title': 'أكاديمية Vision7',
      'academy.home.subtitle': 'نصمم الأبطال، ملعباً تلو الآخر',
      'academy.pillar.passion': 'الشغف',
      'academy.pillar.excellence': 'التميز',
      'academy.pillar.integrity': 'النزاهة',
      'academy.pillar.community': 'المجتمع',
      'academy.pillar.coaching': 'تدريب احترافي',
      'academy.pillar.development': 'تطوير اللاعبين',
      'academy.pillar.competition': 'منافسات',
      'academy.about.title': 'عن الأكاديمية',
      'academy.programs': 'البرامج',
      'academy.facilities': 'المرافق',
      'academy.coaches': 'المدربون',
      'academy.events': 'الفعاليات',
      'academy.contact': 'اتصل بنا',
      'academy.register': 'التسجيل',
      'academy.registerCta': 'سجل اهتمامك',
      'academy.register.hint.fullName': 'الاسم الكامل',
      'academy.register.hint.parentName': 'الاسم الكامل',
      'academy.register.hint.age': 'العمر',
      'academy.register.hint.program': 'اختر البرنامج',
      'academy.quickLink.programs': 'البرامج',
      'academy.quickLink.facilities': 'المرافق',
      'academy.quickLink.coaches': 'المدربون',
      'academy.quickLink.events': 'الفعاليات',
      'academy.quickLink.contact': 'اتصل بنا',
      'academy.quickLink.register': 'التسجيل',

      // Explore
      'explore.title': 'استكشاف',
      'explore.search': 'البحث عن المرافق...',
      'explore.all': 'الكل',
      'explore.noResults': 'لم يتم العثور على مرافق',
      'explore.filterBy': 'تصفية حسب الفئة',
      'explore.category.padel': 'بادل',
      'explore.category.football': 'كرة القدم',
      'explore.category.v7arena': 'V7 أرينا',
      'explore.category.birthday': 'حفلات عيد الميلاد',
      'explore.category.other': 'أخرى',

      // Booking
      'booking.title': 'حجز المرفق',
      'booking.confirm': 'تأكيد الحجز',
      'booking.yourDetails': 'تفاصيلك',
      'booking.name': 'الاسم الكامل',
      'booking.email': 'البريد الإلكتروني',
      'booking.phone': 'رقم الهاتف',
      'booking.date': 'التاريخ',
      'booking.time': 'الوقت',
      'booking.facility': 'المرفق',
      'booking.price': 'السعر',
      'booking.guests': 'الضيوف',
      'booking.status': 'الحالة',
      'booking.confirmed': 'مؤكد',
      'booking.pending': 'قيد الانتظار',
      'booking.cancelled': 'ملغى',
      'booking.confirmationTitle': 'تم تأكيد الحجز!',
      'booking.confirmationMsg': 'تم تأكيد حجزك بنجاح',
      'booking.share': 'مشاركة',
      'booking.close': 'إغلاق',
      'booking.qrCode': 'عرض رمز الاستجابة السريعة',
      'booking.id': 'رقم الحجز',
      'booking.total': 'الإجمالي',
      'booking.detail.title': 'تفاصيل الحجز',
      'booking.facilityNotFound': 'المرفق غير موجود',
      'booking.notFound': 'الحجز غير موجود',
      'booking.priceFormat': '{price} ريال / {duration}دقيقة',
      'booking.pricePerSlot': '{price} ريال',
      'booking.slotDuration': '{duration} دقيقة',

      // Bookings
      'bookings.title': 'حجوزاتي',
      'bookings.upcoming': 'القادمة',
      'bookings.past': 'السابقة',
      'bookings.noBookings': 'لا توجد حجوزات بعد',
      'bookings.noBookingsSubtitle': 'استكشف المرافق واجعل أول حجز لك',
      'bookings.cancelled': 'ملغى',
      'bookings.noUpcoming': 'لا توجد حجوزات قادمة',
      'bookings.noPast': 'لا توجد حجوزات سابقة',
      'bookings.idLabelAr': 'رقم الحجز',

      // Facility
      'facility.amenities': 'المرافق',
      'facility.hours': 'ساعات العمل',
      'facility.notFound': 'المركز الرياضي غير موجود',

      // Calendar
      'calendar.day.1': 'أحد',
      'calendar.day.2': 'إثنين',
      'calendar.day.3': 'ثلاثاء',
      'calendar.day.4': 'أربعاء',
      'calendar.day.5': 'خميس',
      'calendar.day.6': 'جمعة',
      'calendar.day.7': 'سبت',
      'calendar.month.1': 'يناير',
      'calendar.month.2': 'فبراير',
      'calendar.month.3': 'مارس',
      'calendar.month.4': 'أبريل',
      'calendar.month.5': 'مايو',
      'calendar.month.6': 'يونيو',
      'calendar.month.7': 'يوليو',
      'calendar.month.8': 'أغسطس',
      'calendar.month.9': 'سبتمبر',
      'calendar.month.10': 'أكتوبر',
      'calendar.month.11': 'نوفمبر',
      'calendar.month.12': 'ديسمبر',

      // Tab Bar
      'tab.home': 'الرئيسية',
      'tab.explore': 'استكشاف',
      'tab.bookings': 'حجوزاتي',
      'tab.membership': 'العضوية',
      'tab.profile': 'الملف الشخصي',

      // Home
      'home.tourSubtitle': 'تعرف على منشآتنا عن قرب',

      // Membership
      'membership.title': 'العضوية',
      'membership.active': 'الخطة النشطة',
      'membership.invoices': 'الفواتير',
      'membership.plans': 'الخطط المتاحة',
      'membership.enquire': 'استفسر',
      'membership.subscribe': 'اشترك',
      'membership.invoiceDetail': 'تفاصيل الفاتورة',
      'membership.invoiceItems': 'البنود',
      'membership.invoiceTotal': 'الإجمالي',
      'membership.invoiceDate': 'التاريخ',
      'membership.invoiceStatus': 'الحالة',
      'membership.invoicePaid': 'مدفوع',
      'membership.invoicePending': 'قيد الانتظار',
      'membership.noInvoices': 'لا توجد فواتير بعد',
      'membership.activePlan': 'الخطة النشطة',
      'membership.noActive': 'لا توجد عضوية نشطة',
      'membership.validUntil': 'صالح حتى',
      'membership.upgrade': 'ترقية',
      'membership.availablePlans': 'الخطط المتاحة',
      'membership.history': 'السجل',
      'membership.noPlans': 'لا توجد خطط متاحة',
      'membership.plan.gold': 'عضوية ذهبية',
      'membership.period.month': 'شهر',
      'membership.period.day': 'يوم',

      // Profile
      'profile.title': 'الملف الشخصي',
      'profile.account': 'الحساب',
      'profile.preferences': 'التفضيلات',
      'profile.about': 'حول',
      'profile.bookings': 'حجوزاتي',
      'profile.membership': 'العضوية',
      'profile.invoices': 'الفواتير',
      'profile.notifications': 'الإشعارات',
      'profile.language': 'اللغة',
      'profile.languageCurrent': 'English',
      'profile.languageOptionEn': 'English',
      'profile.languageOptionAr': 'العربية',
      'profile.mode': 'الوضع',
      'profile.leisureMode': 'ترفيه',
      'profile.academyMode': 'أكاديمي',
      'profile.privacyPolicy': 'سياسة الخصوصية',
      'profile.termsOfService': 'شروط الخدمة',
      'profile.aboutApp': 'عن Vision7',
      'profile.version': 'الإصدار',
      'profile.guestUser': 'زائر',
      'profile.memberSince': 'عضو منذ',
      'profile.failedToLoad': 'فشل تحميل الملف الشخصي',
      'profile.editProfile': 'تعديل الملف الشخصي',

      // Enquiry
      'enquiry.title': 'استفسار',
      'enquiry.subtitle': 'أخبرنا عن احتياجاتك',
      'enquiry.membershipType': 'نوع العضوية',
      'enquiry.fitnessGoal': 'الهدف اللياقي',
      'enquiry.experience': 'مستوى الخبرة',
      'enquiry.preferredTime': 'الوقت المفضل',
      'enquiry.howHeard': 'كيف سمعت عنا؟',
      'enquiry.message': 'الرسالة',
      'enquiry.hint.name': 'الاسم الكامل',
      'enquiry.hint.message': 'أخبرنا المزيد...',
      'enquiry.submit': 'إرسال الاستفسار',
      'enquiry.success': 'تم إرسال الاستفسار بنجاح!',

      // Tour Booking
      'tourBooking.title': 'احجز جولة',
      'tourBooking.subtitle': 'جدولة زيارتك إلى Vision7',
      'tourBooking.selectDate': 'اختر التاريخ',
      'tourBooking.selectTime': 'اختر الوقت',
      'tourBooking.yourInfo': 'معلوماتك',
      'tourBooking.interests': 'مجالات الاهتمام',
      'tourBooking.confirm': 'تأكيد الحجز',
      'tourBooking.success': 'تم حجز الجولة بنجاح!',
      'tour.hint.name': 'الاسم الكامل',

      // Notifications
      'notifications.title': 'الإشعارات',
      'notifications.noNotifications': 'لا توجد إشعارات بعد',
      'notifications.markAllRead': 'تحديد الكل كمقروء',
      'notifications.justNow': 'الآن',

      // Facility Detail
      'facilityDetail.amenities': 'المرافق',
      'facilityDetail.hours': 'ساعات العمل',
      'facilityDetail.description': 'الوصف',
      'facilityDetail.bookNow': 'احجز الآن',
      'facilityDetail.availableSlots': 'الأوقات المتاحة',
      'facilityDetail.noSlots': 'لا توجد أوقات متاحة',
      'facilityDetail.genderRule': 'قاعدة الجنس',
      'facilityDetail.mixed': 'مختلط',
      'facilityDetail.maleOnly': 'ذكور فقط',
      'facilityDetail.femaleOnly': 'إناث فقط',
      'facilityDetail.pricePerSlot': 'لكل فترة',
      'facilityDetail.duration': 'المدة',
    },
  };

  AppLanguage get lang => _lang;
  bool get isReady => _isReady;
  bool get isArabic => _lang == AppLanguage.ar;
  bool get isRTL => _lang == AppLanguage.ar;

  Map<String, String> get _currentMap =>
      _translations[_lang == AppLanguage.ar ? 'ar' : 'en'] ?? _translations['en']!;

  void _loadLanguage() {
    final saved = _prefs.getString(_key);
    if (saved == 'ar') {
      _lang = AppLanguage.ar;
    } else {
      _lang = AppLanguage.en;
    }
    _isReady = true;
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage lang) async {
    _lang = lang;
    await _prefs.setString(_key, lang == AppLanguage.ar ? 'ar' : 'en');
    notifyListeners();
  }

  String t(String key, {String? fallback}) {
    return _currentMap[key] ?? fallback ?? key;
  }
}

extension TranslationKey on AppLanguage {
  String get key => switch (this) {
    AppLanguage.en => 'en',
    AppLanguage.ar => 'ar',
  };
}
