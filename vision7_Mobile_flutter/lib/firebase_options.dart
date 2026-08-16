// Real values for the `vision7-app-56b2f` Firebase project, entered by hand
// from the iOS/Android app configs downloaded via the Firebase console
// (`flutterfire configure`'s Management API listing was not returning this
// project reliably, so this file was populated manually instead — same end
// result). An APNs auth key still needs to be uploaded in the Firebase
// console (Project Settings > Cloud Messaging) before iOS push will deliver.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, TargetPlatform, defaultTargetPlatform;

class DefaultFirebaseOptions {
  /// True now that this file holds real project values. Firebase's native
  /// iOS SDK hard-validates the API key format at startup and crashes the
  /// whole process (an uncaught NSException, not a catchable Dart exception)
  /// if it doesn't look real — so callers must check this and skip
  /// Firebase.initializeApp() entirely while false, rather than relying on a
  /// try/catch around it.
  static const bool isConfigured = true;

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform (${Platform.operatingSystem}).',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'PLACEHOLDER_API_KEY',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'vision7-placeholder',
    authDomain: 'vision7-placeholder.firebaseapp.com',
    storageBucket: 'vision7-placeholder.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBXNixLEJHdk_cRp7ug7IKFbVXMj5FPh2Y',
    appId: '1:564260360553:android:9be02a32f058f43a03edf8',
    messagingSenderId: '564260360553',
    projectId: 'vision7-app-56b2f',
    storageBucket: 'vision7-app-56b2f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCm9OfQoH0y5PfDC0XGda40tw0MeDhZprE',
    appId: '1:564260360553:ios:561e4f3de283673103edf8',
    messagingSenderId: '564260360553',
    projectId: 'vision7-app-56b2f',
    storageBucket: 'vision7-app-56b2f.firebasestorage.app',
    iosBundleId: 'sa.vision7.app',
  );
}
