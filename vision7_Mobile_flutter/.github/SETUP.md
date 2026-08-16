# GitHub Actions Setup — Vision7

This workflow builds and (optionally) uploads releases automatically.

## Workflow Behavior

On every push to `main`:
- **Android**: Builds AAB → uploads to Google Play Internal Testing
- **iOS**: Builds archive → saves as downloadable artifact

## Required Secrets

Add these in `GitHub → Settings → Secrets and variables → Actions`:

### 1. GOOGLE_PLAY_SERVICE_ACCOUNT

A Google Cloud service account JSON key with Play Console access.

**How to create:**
1. Go to [Google Cloud Console](https://console.cloud.google.com) → create project or use existing
2. Enable **Google Play Android Developer API**
3. Create a Service Account → JSON key
4. In [Play Console](https://play.google.com/console) → **Setup → API access**
5. Click **"Invite"** next to the service account
6. Grant **"Release manager"** permissions
7. Copy the JSON content to GitHub secret `GOOGLE_PLAY_SERVICE_ACCOUNT`

## Triggering a Build

Either:
- Push to `main` (automatic)
- Or use **Actions tab → "Release Build" → Run workflow**

## Downloading the iOS Archive

1. Go to the **Actions** tab
2. Click the green workflow run
3. Scroll to **Artifacts** at the bottom
4. Download `ios-archive`
5. Open `Runner.app` in Xcode → **Product → Archive** to upload to App Store Connect

## Versioning

Update `version` in `pubspec.yaml`:
```yaml
version: 1.0.0+1   # 1.0.0 (versionName), 1 (versionCode)
```
Increment `versionCode` for each Play Store upload (Google Play rejects duplicates).
