# Publishing Framatic on Google Play Store

## 1. Prerequisites

| What you need | Details |
|---|---|
| **Google Play Developer Account** | One-time $25 fee at [play.google.com/console](https://play.google.com/console). Takes ~48h for identity verification. |
| **Signing Key** | An upload key to sign your app. Flutter can generate one. |
| **App Bundle (.aab)** | Google requires Android App Bundles, not APKs. |
| **Store Listing Assets** | Screenshots, icon, feature graphic, descriptions. |
| **Privacy Policy** | A publicly accessible URL — required even if you collect no data. |

**Official docs starting point:** [flutter.dev/docs/deployment/android](https://docs.flutter.dev/deployment/android)

---

## 2. Step-by-Step Breakdown

### Step 1: App Configuration

- Set your **applicationId** in `android/app/build.gradle` (e.g., `com.yourname.framatic`). This is permanent — can't change after publishing.
- Set `versionCode` and `versionName` in the same file (or `pubspec.yaml`).
- Update the app name in `android/app/src/main/AndroidManifest.xml`.
- Replace the default launcher icon (use the `flutter_launcher_icons` package).
- Add a splash screen if desired (`flutter_native_splash` package).

### Step 2: Signing the App

- Generate an upload keystore:
  ```
  keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
  ```
- Create `android/key.properties` (do NOT commit this):
  ```
  storePassword=<password>
  keyPassword=<password>
  keyAlias=upload
  storeFile=/path/to/upload-keystore.jks
  ```
- Configure `build.gradle` to read from `key.properties`.
- **Back up your keystore securely.** If you lose it, you lose the ability to update your app.

**Docs:** [flutter.dev/docs/deployment/android#signing-the-app](https://docs.flutter.dev/deployment/android#signing-the-app)

### Step 3: Build the Release Bundle

```bash
flutter build appbundle --release
```

Output will be at `build/app/outputs/bundle/release/app-release.aab`.

### Step 4: Create Play Console Listing

- App name, short description (80 chars), full description (4000 chars)
- **Screenshots**: min 2 per device type (phone). Use a real device or emulator.
- **Feature graphic**: 1024x500 px
- **App icon**: 512x512 px (high-res)
- Select app category (Photography / Tools)
- Content rating questionnaire (in-console wizard)
- Data safety form (declare camera, storage permissions, no data collection if applicable)
- Privacy policy URL

### Step 5: Upload & Review

- Upload the `.aab` to an internal/closed testing track first (recommended).
- Fill out all required store listing sections.
- Submit for review. First review typically takes 1-3 days, can take up to 7.

---

## 3. Testing Checklist Before Launch

### Functional Testing

- [ ] Camera opens and displays feed on different Android versions (API 24+)
- [ ] All predefined frames (4:3, 16:9, 1:1) render correctly
- [ ] Custom frame CRUD works — create, edit, delete, reorder
- [ ] Photo capture produces correct cropped image with polaroid border
- [ ] Save to gallery works and photo appears in "Framatic" album
- [ ] Retake flow cleans up temp files
- [ ] Frame reordering persists across app restarts

### Permission Testing

- [ ] First launch: camera permission prompt appears
- [ ] Storage/media permission granted — save works
- [ ] Permission denied — app shows meaningful message, doesn't crash
- [ ] Permission revoked mid-use (go to settings, revoke, return to app)

### Lifecycle & Edge Cases

- [ ] App backgrounded during camera use — resumes correctly
- [ ] App killed and reopened — state restored properly
- [ ] Rotate device (if supported) or lock orientation handled
- [ ] Low storage — photo save fails gracefully
- [ ] Very large or very small custom aspect ratios
- [ ] Rapid capture (tap capture button quickly multiple times)

### Device Testing

- [ ] Test on at least 2-3 physical devices with different screen sizes
- [ ] Test on oldest supported Android version
- [ ] Test on a budget/low-RAM device (camera + image processing is memory-heavy)

### Release Build Specific

- [ ] Test the **release build**, not just debug — ProGuard/R8 can strip needed code
- [ ] Verify the signed `.aab` installs and works:
  ```bash
  flutter install --release
  ```

### Performance

- [ ] Camera preview runs smoothly (no dropped frames)
- [ ] Photo processing in isolate doesn't freeze the UI
- [ ] No memory leaks on repeated capture/retake cycles

---

## 4. Things You Might Miss

**Before submission:**
- **`internet` permission** — if you don't need it, explicitly remove it. Some packages add it silently. Audit your merged manifest.
- **ProGuard rules** — release builds use R8 code shrinking. If your app crashes only in release mode, you likely need ProGuard keep rules for a dependency.
- **`android:exported`** — required on all activities/receivers targeting API 31+. Check your `AndroidManifest.xml`.
- **Minimum SDK version** — set it deliberately in `build.gradle`. Don't leave it at the Flutter default if your dependencies need higher.

**Store listing:**
- **Data safety form** — this is separate from the privacy policy. You must declare camera and storage access. Be truthful; Google can reject for mismatches.
- **Content rating** — you must complete the IARC questionnaire or your app won't be published.
- **Target audience** — if your app could appeal to children, you face stricter rules. Mark it as "not designed for children" if that's the case.

**Post-launch:**
- **Enable Play App Signing** — Google manages your signing key and you upload with an upload key. This is the default now and strongly recommended (you can recover from a lost upload key).
- **Use internal testing track first** — don't publish directly to production. Internal track has no review wait and lets you verify the exact build Google will serve.
- **Set up crash reporting** — Firebase Crashlytics (free) or just check the Play Console's Android Vitals dashboard after launch.
- **Pre-launch report** — Play Console runs your app on real devices automatically. Check the results before promoting to production.

**Legal:**
- **Privacy policy** — you can host a simple one on GitHub Pages for free. It must be publicly accessible.
- **You need a D-U-N-S number or identity verification** — Google now requires identity verification for new developer accounts. Start this early, it can take days.

---

## 5. Quick Reference: Key Flutter Docs Pages

| Topic | URL |
|---|---|
| Android deployment | flutter.dev/docs/deployment/android |
| Build modes | flutter.dev/docs/testing/build-modes |
| App icon | pub.dev/packages/flutter_launcher_icons |
| Obfuscation | flutter.dev/docs/deployment/obfuscate |
| Flavors (if needed) | flutter.dev/docs/deployment/flavors |

Start with the developer account registration and signing setup — those have the longest lead times. Everything else can be done in parallel.
