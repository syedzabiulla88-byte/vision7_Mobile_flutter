# Vision7 — Release Notes

## Version 1.1.2 (Build 4) — August 2026

### Overview
Vision7 is a bilingual (English / Arabic) mobile app for Vision7 Leisure Club and VISION7 Academy in Riyadh. Users can explore facilities, book tours, manage memberships, view invoices, and receive push notifications.

---

### Features

#### Authentication & Onboarding
- Email/password sign-up and sign-in
- Google Sign-In social authentication
- Password reset (forgot password flow)
- Onboarding screens with app introduction
- Route guards — authenticated screens are protected from unauthenticated access
- Secure token storage via `flutter_secure_storage`

#### Dual Mode: Leisure Club & Academy
- Toggle between **Leisure** (light theme) and **Academy** (dark navy theme) modes
- Mode persisted via `SharedPreferences`
- Entire app theme (colors, typography, surfaces) adapts to the selected mode
- Home screen switches content between `academy_home.dart` and `leisure_home.dart`

#### Home & Exploration
- Mode-specific home screens with curated content (focus areas, experiences, tour CTA)
- Explore screen listing facilities with search and category filtering
- Facility detail screen with full information, amenities, gallery, and location
- Academy-specific sections: About, Coaches, Events, Facilities, Programs, Contact

#### Tour Booking
- Date picker (up to 90 days in advance)
- Available time slot selection with real-time availability
- Gender-specific session windows (Female: 6 AM–3 PM, Male: 4 PM–1 AM)
- Booking confirmation with snackbar feedback
- Platform tagging (iOS / Android) in booking payload

#### Membership
- Membership plan selection and enrollment
- Payment method management
- Membership status tracking

#### Invoices
- Invoice list view
- Invoice detail screen with line items and amounts

#### Notifications
- Firebase Cloud Messaging (FCM) push notifications
- Notifications list screen
- Notification badge count on app icon

#### Profile
- User profile view with account details
- Language toggle (English / Arabic) with RTL support
- Logout functionality
- App version display

#### Legal
- Terms & Conditions and Privacy Policy screen

---

### Architecture

#### Clean Architecture (Feature-first)
Each feature follows a layered structure:
```
lib/features/<feature>/
  data/          — Remote data sources, repository implementations
  domain/        — Models, repository interfaces
  presentation/  — Screens, providers, widgets
```

#### Core Modules
- **Networking**: Dio HTTP client with interceptors, token refresh, error handling
- **Theme**: `AppTheme` with mode-aware light/dark themes, custom text styles, color palette
- **Localization**: `LanguageProvider` with EN/AR translations and RTL layout support
- **Shared Widgets**: `AppButton`, `AppCard`, `AppInput`, `AppSection`, `LoadingIndicator`, `EmptyState`, `ConfirmationOverlay`, `PressableCard`, `TabBarWidget`, `AppBadge`
- **State Management**: Provider pattern (`ChangeNotifier`) for auth, language, mode

---

### Platforms & Configuration

#### Android
- Application ID: `sa.vision7.app`
- Min SDK: 21, Target SDK: 34
- ProGuard / R8 code shrinking enabled for release
- Dart obfuscation enabled for release builds
- POST_NOTIFICATIONS runtime permission
- Production Firebase configuration (`google-services.json`)
- Release signing via `key.properties` (gitignored)

#### iOS
- Bundle ID: `sa.vision7.app`
- Deployment Target: iOS 12.0+
- Portrait and landscape orientations supported (Info.plist)
- Production APNs environment
- `ITSAppUsesNonExemptEncryption` set to `false`
- Firebase configuration (`GoogleService-Info.plist`)

#### CI/CD
- GitHub Actions workflows for automated Android AAB and iOS Archive builds
- Release artifacts uploaded as GitHub Actions artifacts

---

### Dependencies

| Package | Purpose |
|---|---|
| `flutter_riverpod` / `provider` | State management |
| `go_router` | Declarative routing |
| `dio` | HTTP client |
| `flutter_secure_storage` | Secure token storage |
| `firebase_core` / `firebase_messaging` | Push notifications |
| `google_sign_in` | Google authentication |
| `shared_preferences` | Local settings (mode, language) |
| `image_picker` | Profile/avatar image selection |
| `local_auth` | Biometric authentication |
| `package_info_plus` | App version display |
| `flutter_local_notifications` | Local notification handling |

---

### What's New in This Release
- Production-ready Android and iOS build configurations
- Code obfuscation and minification for release
- CI/CD pipeline for automated builds
- Push notification permissions on Android
- Firebase production configuration
- Accessibility labels on shared widgets
- Legal screen linked from Profile
- App version display in Profile
