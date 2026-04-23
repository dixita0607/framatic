# Framatic Beta Distribution Guide

This document covers your options for sharing Framatic with beta testers before a public release, plus a pre-release checklist to work through first.

---

## Pre-Release Checklist

Work through this before sending the app to anyone.

### App Identity
- [ ] Change `applicationId` in `android/app/build.gradle.kts` from `com.example.framatic` to something permanent (e.g. `com.yourname.framatic`). **This cannot be changed after publishing to Play Store.**
- [ ] Update `versionCode` and `versionName` in `pubspec.yaml` (currently `0.1.0`)
- [ ] Replace the default app icon (currently Flutter's default blue icon)
- [ ] Update the app name in `android/app/src/main/AndroidManifest.xml`

### Signing
- [ ] Generate a release keystore (see [LAUNCH.md](LAUNCH.md) Step 2 for the command)
- [ ] Configure `build.gradle.kts` to use your keystore for release builds (currently signed with debug keys)
- [ ] Back up the keystore somewhere safe — losing it means losing the ability to update the app

### Functional Smoke Test (release build)
- [ ] Build and install the **release** APK — `flutter build apk --release && flutter install --release`
- [ ] Camera opens and viewfinder renders correctly
- [ ] All 3 predefined frames display properly
- [ ] Photo capture, crop, and save to gallery works
- [ ] Retake flow works without crashing
- [ ] Camera permission denied → app shows a message, doesn't crash
- [ ] App backgrounded and resumed → camera recovers
- [ ] No crashes on app cold start

### Code Quality
- [ ] Remove any debug prints or test code left in
- [ ] Verify no sensitive credentials are hardcoded
- [ ] Run `flutter analyze` — fix any errors

---

## Beta Distribution Options

### Option 1 — Direct APK (Simplest, no account needed)

Build a release APK and send it directly to testers via file sharing (Google Drive, email, WhatsApp, etc.).

**How to build:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

Testers must enable **"Install from unknown sources"** in their Android settings before installing.

**Pros:**
- Zero setup, no accounts needed
- Works immediately
- Good for 1–5 trusted testers

**Cons:**
- Testers must manually enable unknown sources (some find this confusing)
- No crash reporting or install tracking
- You must manually send each new build
- Not suitable for wider audiences (security-conscious users may refuse)

---

### Option 2 — Firebase App Distribution (Recommended for small-medium beta)

Google's free tool for distributing pre-release apps to testers. Testers get an email invite and install via the Firebase App Distribution app. No Play Store account needed.

**Setup:**
1. Create a project at [console.firebase.google.com](https://console.firebase.google.com) (free)
2. Add your Android app with your `applicationId`
3. Download `google-services.json` and place it in `android/app/`
4. Install the Firebase CLI: `npm install -g firebase-tools`
5. Distribute a build:
   ```bash
   flutter build apk --release
   firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
     --app YOUR_FIREBASE_APP_ID \
     --testers "tester1@email.com,tester2@email.com" \
     --release-notes "Beta 1 — initial test build"
   ```

Testers receive an email with a download link. The Firebase tester app manages installs and updates.

**Pros:**
- Clean tester experience — email invite, no sideloading friction
- Supports up to 100 testers for free
- You can add release notes per build
- Testers get notified when a new build is available
- No Play Store account or review process

**Cons:**
- Testers need to install the Firebase App Distribution companion app once
- Requires a Firebase project (though it's free)
- Still requires enabling unknown sources on older Android versions (< Android 8)

---

### Option 3 — Google Play Internal Testing (Best long-term, most friction to set up)

Upload your app to the Play Console's "Internal Testing" track. Up to 100 testers install it like a normal Play Store app — no unknown sources, no sideloading.

**Setup:**
1. Pay the one-time $25 Google Play developer fee and create an account at [play.google.com/console](https://play.google.com/console)
2. Complete identity verification (can take 2–3 days)
3. Create a new app in the console
4. Build an App Bundle: `flutter build appbundle --release`
5. Upload to the **Internal Testing** track (not production — no review needed for internal track)
6. Add tester email addresses or create a shareable opt-in link
7. Testers install from the Play Store like any other app

**Pros:**
- Best tester experience — standard Play Store install, automatic updates
- No "unknown sources" friction at all
- You can promote the same build to Closed Testing → Open Testing → Production without rebuilding
- Play Console provides crash reports and Android Vitals for free
- Required eventually anyway if you want to publish publicly

**Cons:**
- $25 one-time fee
- Identity verification takes a few days
- More setup than the other options
- Still need a complete store listing before promoting to production (not needed for internal track)

---

## Recommendation

| Situation | Go with |
|---|---|
| Testing with 1–3 close friends quickly | Option 1 (Direct APK) |
| Broader beta, want a clean tester experience | Option 2 (Firebase App Distribution) |
| Planning to publish on Play Store eventually | Option 3 (Play Internal Testing) |

If you plan to eventually release on the Play Store, starting with Option 3 is worth the upfront effort — you'll need the Play Console account anyway, and the internal testing track gives you the smoothest path from beta to production.

A practical sequence: use **Option 1 or 2** for your very first round of testing (while the app is still rough), then set up **Option 3** once you're close to a public release.

---

## Quick Reference

| Tool | Cost | Tester limit | Review required | Tester UX |
|---|---|---|---|---|
| Direct APK | Free | Unlimited | None | Must enable unknown sources |
| Firebase App Distribution | Free | 100 | None | Install companion app once |
| Play Internal Testing | $25 one-time | 100 | None | Normal Play Store install |
| Play Closed/Open Testing | (included) | Varies | Yes (first upload) | Normal Play Store install |
