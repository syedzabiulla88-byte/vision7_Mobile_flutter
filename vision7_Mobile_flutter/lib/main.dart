import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Missing on a fresh clone / CI runner without the file provisioned —
    // every consumer (e.g. DioClient's API_BASE_URL) already falls back to a
    // hardcoded default, so this shouldn't stop the app from starting.
    debugPrint('.env not found, using built-in defaults: $e');
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await _initCrashReporting();

  runApp(const ProviderScope(child: Vision7App()));
}

/// Same guard as PushNotificationService._ensureFirebase(): Firebase's
/// native iOS SDK hard-validates the API key format and crashes the whole
/// process (an uncaught NSException, not catchable from Dart) if it looks
/// like a placeholder — never call Firebase.initializeApp() unless real
/// config is in place. Safe to call again from PushNotificationService
/// later (it checks Firebase.apps.isEmpty first).
///
/// Without this, a release crash was invisible — no way to know it
/// happened, let alone diagnose it.
Future<void> _initCrashReporting() async {
  if (!DefaultFirebaseOptions.isConfigured) return;
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    debugPrint('Crash reporting init failed: $e');
  }
}
