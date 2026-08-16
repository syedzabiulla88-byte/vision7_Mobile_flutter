import Flutter
import UIKit
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // FirebaseMessaging's remote-notification swizzling initializes very
    // early in process launch — before the Dart-side Firebase.initializeApp()
    // call ever runs — so without this, APNs registration silently never
    // completes (logs "[FirebaseCore][I-COR000005] No app has been
    // configured yet." and getAPNSToken() hangs null forever). Configuring
    // here, before super's launch, ensures a FirebaseApp already exists by
    // the time swizzling runs. Safe to call before the later Dart-side
    // Firebase.initializeApp() — that call already checks Firebase.apps and
    // reuses this instance instead of reconfiguring.
    FirebaseApp.configure()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  // With Flutter's implicit-engine app lifecycle, this delegate callback
  // never reaches firebase_messaging's own plugin-dispatch forwarding (its
  // swizzled didRegisterForRemoteNotificationsWithDeviceToken: never fires),
  // so getAPNSToken() hangs null forever. Set the token on Firebase directly
  // here instead of relying on that forwarding.
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("Failed to register for remote notifications: \(error)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
}
