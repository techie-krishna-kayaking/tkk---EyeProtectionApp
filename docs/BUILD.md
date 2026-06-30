# Build & Run

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) **3.24+** (Dart 3.4+)
- Platform toolchains as needed: Xcode (macOS/iOS), Visual Studio with the
  "Desktop development with C++" workload (Windows), Android Studio / SDK.

Verify your setup:

```bash
flutter doctor
```

## First-time setup

This repository ships the shared Dart codebase. Generate the native runner
projects once:

```bash
# from the project root
flutter create --platforms=android,ios,macos,windows,linux .
flutter pub get
```

Then add the native handlers from [`NATIVE_INTEGRATION.md`](NATIVE_INTEGRATION.md)
(microphone detection) and place the tray icons in `assets/icons/`.

## Run

```bash
flutter run -d macos      # or windows / chrome / <android-device> / <ios-device>
```

## Quality gates

```bash
dart format .
flutter analyze
flutter test
flutter test --coverage
```

## Build release artifacts

| Platform | Command | Output |
|----------|---------|--------|
| Android APK | `flutter build apk --release` | `build/app/outputs/flutter-apk/app-release.apk` |
| Android AAB | `flutter build appbundle --release` | `build/app/outputs/bundle/release/app-release.aab` |
| macOS | `flutter build macos --release` | `build/macos/Build/Products/Release/*.app` |
| Windows | `flutter build windows --release` | `build/windows/x64/runner/Release/` |
| iOS (unsigned) | `flutter build ios --release --no-codesign` | `build/ios/iphoneos` |

### Installers

- **Windows:** `iscc installers/windows/eyeguard.iss` (requires Inno Setup).
- **macOS DMG:** `brew install create-dmg` then run the `create-dmg` step from
  `.github/workflows/release.yml`.

## Android boot-restart (optional)

To restart the background service after reboot, add to
`android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

and register a `BroadcastReceiver` for `android.intent.action.BOOT_COMPLETED`.
