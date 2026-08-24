import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';
import '../../features/notifications/domain/notification_repository.dart';
import '../../app/routes/router.dart' as app_router;

/// Push-notification permission + FCM token lifecycle. Every step is wrapped
/// so a missing/placeholder Firebase project (see firebase_options.dart)
/// degrades to "push silently doesn't work" instead of crashing the app.
class PushNotificationService {
  final NotificationRepository _repository;
  PushNotificationService(this._repository);

  bool _firebaseReady = false;
  String? _registeredToken;

  Future<void> _ensureFirebase() async {
    if (_firebaseReady) return;
    // Placeholder credentials pass Dart-side validation but fail Firebase's
    // native iOS API-key format check, which throws an uncaught NSException
    // (crashes the app, not catchable from Dart) — so never call
    // Firebase.initializeApp() at all until real config exists.
    if (!DefaultFirebaseOptions.isConfigured) {
      debugPrint('Firebase not configured yet (see firebase_options.dart) — push notifications disabled.');
      return;
    }
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      }
      _firebaseReady = true;
    } catch (e) {
      debugPrint('Firebase init failed — push notifications disabled: $e');
    }
  }

  /// Request notification permission and register the device's FCM token
  /// against the current (now-authenticated) user. Call after login/register
  /// and on app start when a session already exists.
  Future<void> initialize() async {
    await _ensureFirebase();
    if (!_firebaseReady) return;

    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(alert: true, badge: true, sound: true);
      debugPrint('Push permission status: ${settings.authorizationStatus}');
      final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      if (!granted) return;

      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        // On iOS, getToken() throws apns-token-not-set if called before the
        // OS finishes registering for remote notifications — that
        // registration is async and not yet complete right after
        // requestPermission() returns, so poll briefly for it first.
        String? apnsToken = await messaging.getAPNSToken();
        var attempts = 0;
        while (apnsToken == null && attempts < 15) {
          await Future.delayed(const Duration(seconds: 1));
          apnsToken = await messaging.getAPNSToken();
          attempts++;
        }
        debugPrint('APNs token after $attempts attempts: $apnsToken');
      }

      final token = await messaging.getToken();
      debugPrint('FCM token: $token');
      if (token != null) await _registerToken(token);
      messaging.onTokenRefresh.listen(_registerToken);

      // Tap-to-open routing — a notification's `data` payload decides where
      // it opens. Covers both "tapped while backgrounded" and "tapped to
      // cold-start the app" (a message received while foregrounded never
      // reaches either of these; that's a system-notification-tray behavior
      // this app doesn't otherwise show a UI for yet).
      FirebaseMessaging.onMessageOpenedApp.listen(_routeFromMessage);
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) _routeFromMessage(initialMessage);
    } catch (e) {
      debugPrint('Push notification setup failed: $e');
    }
  }

  /// Extensible by `data['type']` — add a case per notification kind that
  /// should deep-link somewhere specific when tapped.
  void _routeFromMessage(RemoteMessage message) {
    final type = message.data['type'];
    switch (type) {
      case 'qr_pass':
        app_router.router.push('/access-pass');
        break;
      default:
        break;
    }
  }

  Future<void> _registerToken(String token) async {
    try {
      final platform = defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
      await _repository.registerDeviceToken(token, platform);
      _registeredToken = token;
    } catch (e) {
      debugPrint('Failed to register device token: $e');
    }
  }

  /// Unregister this device's token so it stops receiving push after logout.
  Future<void> onLogout() async {
    final token = _registeredToken;
    if (token == null) return;
    _registeredToken = null;
    try {
      await _repository.unregisterDeviceToken(token);
    } catch (e) {
      debugPrint('Failed to unregister device token: $e');
    }
  }
}
