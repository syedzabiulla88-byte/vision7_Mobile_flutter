# Vision7 — Store Listing

> Content ready to copy-paste into Google Play Console and App Store Connect.

---

## App Identity

| Field | Value |
|-------|-------|
| **App Name** | Vision7 |
| **Package / Bundle ID** | `sa.vision7.app` |
| **Current Version** | 1.0.0 (build 1) |
| **Category** | Sports / Health & Fitness |
| **Privacy Policy URL** | `https://www.vision7.sa/academy/privacy-policy` |
| **Support URL** | `https://www.vision7.sa/support` |
| **Email** | privacy@vision7.sa |

---

## Google Play Console — Store Listing

### Short Description (80 chars)
```
Book sports facilities, manage memberships, and stay connected with Vision7.
```

### Full Description
```
VISION7 — Your Gateway to Premium Sports & Wellness Facilities

Vision7 brings you seamless access to world-class sports academies and leisure facilities. Whether you're booking a football pitch, joining an academy program, or managing your membership, Vision7 puts everything at your fingertips.

KEY FEATURES

• Facility Booking — Browse and book courts, pitches, and amenities in real time
• Academy Programs — Explore coaching programs, schedules, and register your child
• Membership Management — View plans, payment methods, and billing history
• Smart Notifications — Get reminders for bookings, sessions, and promotions
• Dual Mode — Switch between Academy and Leisure experiences
• Bilingual — Full English and Arabic (العربية) support with RTL layout
• Social Sign-In — Quick login with Google or Apple

EXPLORE

Discover facilities near you, view detailed information including photos, amenities, and pricing. Book with just a few taps and manage all your reservations in one place.

MANAGE

View your booking history, track membership status, download invoices, and update your profile — all from the app.

STAY CONNECTED

Enable push notifications to never miss a booking reminder, academy update, or exclusive offer.

Vision7 — Where Champions Begin.
```

### Keywords (comma-separated)
```
sports facility,academy,booking,membership,fitness,wellness,leisure,sports booking,facility booking,saudi arabia,academy registration,sports center,fitness membership
```

---

## App Store Connect — Store Listing

### Subtitle (30 chars)
```
Sports facilities & membership
```

### Description
```
VISION7 — Your Gateway to Premium Sports & Wellness Facilities

Vision7 brings you seamless access to world-class sports academies and leisure facilities. Whether you're booking a football pitch, joining an academy program, or managing your membership, Vision7 puts everything at your fingertips.

KEY FEATURES

• Facility Booking — Browse and book courts, pitches, and amenities in real time
• Academy Programs — Explore coaching programs, schedules, and register your child
• Membership Management — View plans, payment methods, and billing history
• Smart Notifications — Get reminders for bookings, sessions, and promotions
• Dual Mode — Switch between Academy and Leisure experiences
• Bilingual — Full English and Arabic (العربية) support with RTL layout
• Social Sign-In — Quick login with Google or Apple

EXPLORE

Discover facilities near you, view detailed information including photos, amenities, and pricing. Book with just a few taps and manage all your reservations in one place.

MANAGE

View your booking history, track membership status, download invoices, and update your profile — all from the app.

STAY CONNECTED

Enable push notifications to never miss a booking reminder, academy update, or exclusive offer.

Vision7 — Where Champions Begin.
```

### Keywords
```
sports,facility,booking,membership,fitness,wellness,leisure,academy,center,saudi
```

### Promotional Text (170 chars)
```
Book sports facilities, manage memberships, and stay connected. Vision7 — Your Gateway to Premium Sports & Wellness Facilities.
```

---

## Required Assets

| Asset | Size | Notes |
|-------|------|-------|
| **App Icon** | 1024×1024 px | `assets/images/app-icon-1024.png` ✓ |
| **Feature Graphic (Android)** | 1024×500 px | NOT yet created |
| **Phone Screenshots (Android)** | 320–3840 px (16:9 or 9:16) | 2–8 required |
| **Phone Screenshots (iOS 6.5")** | 1284×2778 px | 3–10 required |
| **Phone Screenshots (iOS 5.5")** | 1242×2208 px | Optional (3–10 required) |
| **iPad Screenshots (iOS)** | 2048×2732 px | Only if app supports iPad |
| **App Store Promo Text (iOS)** | Up to 170 chars | Provided above |

---

## What Still Needs Manual Action

- [ ] Generate release keystore: `keytool -genkey -v -keystore android/vision7-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias vision7`
- [ ] Create `android/key.properties` with keystore credentials
- [ ] Host privacy policy at `https://www.vision7.sa/academy/privacy-policy` *(already live)*
- [ ] Create feature graphic (1024×500) for Google Play
- [ ] Take and export screenshots for both stores
- [ ] Enable "Sign in with Apple" capability in Xcode → Signing & Capabilities
- [ ] Upload APNs auth key to Firebase Console
- [ ] Test via TestFlight (iOS) and Internal Testing (Android) before production release
- [ ] Fill in store listing in Play Console and App Store Connect using content above
- [ ] Upload production APK/IPA
