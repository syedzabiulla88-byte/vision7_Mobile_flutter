# Vision7 — Manual Release Steps

> Everything you still need to do yourself before submitting to Google Play Store and Apple App Store.

---

## Table of Contents

1. [Generate Android Release Keystore](#1-generate-android-release-keystore)
2. [Create key.properties](#2-create-keyproperties)
3. [Enable "Sign in with Apple" in Xcode](#3-enable-sign-in-with-apple-in-xcode)
4. [Upload APNs Authentication Key to Firebase](#4-upload-apns-authentication-key-to-firebase)
5. [Create App Store Connect App Record](#5-create-app-store-connect-app-record)
6. [Create Google Play Console App Record](#6-create-google-play-console-app-record)
7. [Take Screenshots](#7-take-screenshots)
8. [Create Feature Graphic (Android)](#8-create-feature-graphic-android)
9. [Build & Upload Production Builds](#9-build--upload-production-builds)
10. [Submit for Review](#10-submit-for-review)
11. [Post-Release Checklist](#11-post-release-checklist)

---

## 1. Generate Android Release Keystore

This is required to sign the Android APK/AAB for release.

### Step 1.1: Generate the keystore

Open Terminal and run:

```bash
cd /Users/syedzabiulla/Downloads/OneOS/spa/vision/vision7_Mobile_flutter/android

keytool -genkey -v \
  -keystore vision7-release.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias vision7
```

You will be prompted for:
- **Keystore password** — Choose a strong password (save it somewhere safe)
- **First and last name** — e.g., `Vision7`
- **Organizational unit** — e.g., `Engineering`
- **Organization** — e.g., `VA 7 Company`
- **City or locality** — e.g., `Riyadh`
- **State or province** — e.g., `Riyadh`
- **Country code** — `SA` (for Saudi Arabia)

Confirm with `yes` when asked.

### Step 1.2: Verify the keystore was created

```bash
ls -la vision7-release.jks
```

You should see the file (~1–2 KB).

### Step 1.3: Protect the keystore

```bash
chmod 600 vision7-release.jks
```

This restricts access to only you.

---

## 2. Create key.properties

### Step 2.1: Create the file

Create a file at `android/key.properties` (DO NOT commit this — it's gitignored):

```bash
# Copy from the example
cp android/key.properties.example android/key.properties
```

### Step 2.2: Edit with your credentials

Open `android/key.properties` and replace the placeholder values:

```properties
storeFile=vision7-release.jks
storePassword=YOUR_STORE_PASSWORD
keyAlias=vision7
keyPassword=YOUR_KEY_PASSWORD
```

Use the password you set when generating the keystore.

### Step 2.3: Verify it's not tracked by git

```bash
git status android/key.properties
```

It should not appear (because `.gitignore` now excludes it).

---

## 3. Enable "Sign in with Apple" in Xcode

Required for Apple Sign-In to work. Without this, the button will crash.

### Step 3.1: Open the project in Xcode

```bash
cd /Users/syedzabiulla/Downloads/OneOS/spa/vision/vision7_Mobile_flutter
open ios/Runner.xcworkspace
```

### Step 3.2: Add the capability

1. Select the **Runner** project in the left navigator
2. Select the **Runner** target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Search for **Sign In with Apple** and double-click to add it

### Step 3.3: Verify entitlements

Open `ios/Runner/Runner.entitlements` — it should now have the `com.apple.developer.applesignin` key (it's already there from a previous step).

### Step 3.4: Rebuild and test

```bash
flutter run -d <your-device-id>
```

Try the Apple Sign-In button — it should open the native Apple auth sheet.

---

## 4. Upload APNs Authentication Key to Firebase

Required for iOS push notifications to work in production (TestFlight and App Store builds).

### Step 4.1: Create an APNs Auth Key in Apple Developer Portal

1. Go to [https://developer.apple.com/account](https://developer.apple.com/account)
2. Sign in with your Apple Developer account
3. Go to **Certificates, Identifiers & Profiles** → **Keys**
4. Click **+** to create a new key
5. Name it: `Vision7 APNs Key`
6. Check **Apple Push Notifications service (APNs)**
7. Click **Continue**, then **Register**
8. Click **Download** — save the `.p8` file to a safe location
9. **Important:** Copy the **Key ID** (shown on the page)
10. Note your **Team ID** (found at the top-right of the Developer Portal)

### Step 4.2: Upload to Firebase Console

1. Go to [https://console.firebase.google.com/project/vision7-app-56b2f/settings/cloudmessaging](https://console.firebase.google.com/project/vision7-app-56b2f/settings/cloudmessaging)
2. Scroll down to **Apple app configuration**
3. Under **APNs authentication key**, click **Upload**
4. Browse for the `.p8` file you downloaded
5. Enter the **Key ID** from the previous step
6. Enter your **Team ID**
7. Click **Upload**

---

## 5. Create App Store Connect App Record

### Step 5.1: Sign in to App Store Connect

Go to [https://appstoreconnect.apple.com](https://appstoreconnect.apple.com)

### Step 5.2: Create a new app

1. Go to **My Apps** → click **+** → **New App**
2. Fill in:
   - **Platform**: iOS
   - **Name**: Vision7
   - **Primary Language**: English
   - **Bundle ID**: `sa.vision7.app` (must match Xcode project)
   - **SKU**: `vision7-001` (any unique identifier)
   - **User Access**: Full Access
3. Click **Create**

### Step 5.3: Fill in App Information

Go to **App Information** and fill in:
- **Privacy Policy URL**: `https://www.vision7.sa/academy/privacy-policy`
- **Support URL**: `https://www.vision7.sa` (or your support page)
- **Marketing URL**: `https://www.vision7.sa` (optional)
- **Category**: Primary → **Sports**, Secondary → **Health & Fitness** (or choose as appropriate)

### Step 5.4: Prepare for Submission

1. Go to **App Store** tab → **iOS App**
2. Upload screenshots (see step 7) to all required device sizes
3. Fill in:
   - **Description** — copy from `STORE_LISTING.md`
   - **Keywords** — copy from `STORE_LISTING.md`
   - **Promotional Text** — copy from `STORE_LISTING.md`
   - **Subtitle** — copy from `STORE_LISTING.md`
4. Set **Version** to `1.0.0`
5. Under **Build**, select the build you'll upload (see step 9)
6. Fill in **Review Information**:
   - Contact information
   - Demo account (if app requires login — you may want to create a test account)
   - Notes for the reviewer
7. Under **App Review Information** → **Export Compliance**:
   - Set **Export Compliance** to your jurisdiction's requirements
   - Set **Content Rights** and **Advertising ID** as appropriate
8. Click **Save**

---

## 6. Create Google Play Console App Record

### Step 6.1: Sign in to Play Console

Go to [https://play.google.com/console](https://play.google.com/console)

### Step 6.2: Create a new app

1. Click **Create app**
2. Fill in:
   - **App name**: Vision7
   - **Default language**: English
   - **App or game**: App
   - **Free or paid**: Free
   - **Declarations**: Accept all declarations
3. Click **Create app**

### Step 6.3: Complete the store listing

Go to **Grow → Store presence → Main store listing**:

| Field | Value |
|-------|-------|
| **App name** | Vision7 |
| **Short description** | Copy from `STORE_LISTING.md` |
| **Full description** | Copy from `STORE_LISTING.md` |
| **Graphics** | Upload feature graphic (step 8) and app icon |
| **Phone screenshots** | Upload 5–8 screenshots (step 7) |
| **Tablet screenshots** | Upload if you have them |
| **Category** | Primary: Sports, Secondary: Health & Fitness |
| **Contact details** | Email, website, phone |
| **Privacy Policy** | `https://www.vision7.sa/academy/privacy-policy` |

### Step 6.4: Set up privacy & security

Go to **Policy → App content** and fill in:
- **Privacy policy**: Enter your privacy policy URL
- **Data safety**: Fill in the data collection form (the app collects: name, email, phone, photos, location if applicable)
- **Target audience**: Set appropriate age rating

### Step 6.5: Set up country/region distribution

Go to **Grow → Store presence → Pricing & distribution**:
- Select the countries you want to distribute to
- Set pricing (Free)
- Set age rating (likely 3+ or 9+ depending on content)

---

## 7. Take Screenshots

### Step 7.1: Required sizes

| Store | Device | Size | Count |
|-------|--------|------|-------|
| Google Play | Phone | 320–3840 px, 16:9 or 9:16 | 2–8 |
| Google Play | 7" Tablet | 320–3840 px, 16:9 or 9:16 | Optional |
| App Store | iPhone 6.5" | 1284×2778 px | 3–10 |
| App Store | iPhone 5.5" | 1242×2208 px | Optional |
| App Store | iPad Pro | 2048×2732 px | Only if iPad support |

### Step 7.2: How to take screenshots

**On your physical iPhone:**
1. Run the app on your device
2. Navigate to each screen you want to capture
3. Press Side Button + Volume Up to capture
4. Screenshots go to your Photos app

**Recommended screenshots to capture:**
1. Splash / loading screen
2. Onboarding screens
3. Login / Sign-up screen
4. Home screen (Academy mode)
5. Home screen (Leisure mode)
6. Facility listing / Explore screen
7. Facility detail screen
8. Booking flow screen
9. Profile screen
10. Notifications screen

### Step 7.3: Create a feature graphic (Android)

- Size: 1024×500 px
- Use your brand colors (Navy `#011B2B` + Gold `#FFCF01`)
- Include app name "Vision7" and tagline
- Export as PNG

---

## 8. Build & Upload Production Builds

### Step 8.1: Android — Build an App Bundle (AAB)

Google Play now requires AAB (Android App Bundle) instead of APK.

```bash
cd /Users/syedzabiulla/Downloads/OneOS/spa/vision/vision7_Mobile_flutter

flutter build appbundle \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --release
```

The output will be at:
```
build/app/outputs/bundle/release/app-release.aab
```

### Step 8.2: iOS — Build for Archive

```bash
cd /Users/syedzabiulla/Downloads/OneOS/spa/vision/vision7_Mobile_flutter

flutter build ios \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --release
```

### Step 8.3: Create an IPA for upload

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Any iOS Device** as the target
3. Go to **Product → Archive**
4. Wait for the archive to complete
5. In the **Organizer** window, click **Distribute App**
6. Select **App Store Connect** → **Upload**
7. Follow the prompts (use automatic signing)
8. Upload

---

## 9. Submit for Review

### Step 9.1: Android (Google Play)

1. In Play Console, go to **Release → Production**
2. Click **Create new release**
3. Upload the `.aab` file
4. Fill in the release name (e.g., `1.0.0`) and release notes
5. Click **Save**, then **Review release**
6. Click **Start rollout to Production**
7. Google Play will process the build and send it for review

### Step 9.2: iOS (App Store)

1. In App Store Connect, go to your app → **TestFlight** tab first
2. Select the build you uploaded
3. Add **TestFlight beta testing info** (what to test, contact email)
4. Add internal testers first (your team)
5. Once internal testing passes, add external testers
6. After testing, go to the **App Store** tab → **+ Version or Platform**
7. Select the build, fill in all metadata (copied from STORE_LISTING.md)
8. Click **Add for Review**
9. Apple will review the app (typically 1–2 business days)

---

## 10. Post-Release Checklist

After your app is approved and live:

- [ ] Verify the app appears in both stores
- [ ] Download and test the production build on a real device
- [ ] Verify push notifications work on both platforms
- [ ] Verify Google Sign-In and Apple Sign-In work in production
- [ ] Monitor crash reports in Firebase Crashlytics
- [ ] Monitor reviews and ratings in both stores
- [ ] Set up App Store Connect **App Analytics**
- [ ] Set up Play Console **Statistics**
- [ ] Plan your first update cycle (bug fixes, feature requests)

---

## Important Passwords & Keys to Save

| Item | Where to Save |
|------|---------------|
| Keystore password | Password manager (1Password, iCloud Keychain, etc.) |
| Key password | Same as above |
| APNs `.p8` key file | Secure backup (not in git) |
| Firebase project access | Admin access to `vision7-app-56b2f` |
| Apple Developer account | Your Apple ID |
| Google Play Console | Your Google account |

---

## Emergency: If You Lose the Keystore

If you lose the `vision7-release.jks` file, you **cannot update** the app on Google Play. You would have to publish a new app with a new package name. Backup the keystore file in a secure location (encrypted cloud storage, USB drive, etc.).
