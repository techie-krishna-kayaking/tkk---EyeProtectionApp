# Release Guide

Releases are automated by [`.github/workflows/release.yml`](../.github/workflows/release.yml),
triggered when you push a semver tag.

## Cut a release

```bash
# 1. Bump version in pubspec.yaml  (e.g. 1.1.0+2) and update CHANGELOG.md
# 2. Commit
git commit -am "chore: release v1.1.0"
# 3. Tag & push
git tag v1.1.0
git push origin main --tags
```

The workflow then:

1. Builds Android (APK + AAB), macOS (.app + .dmg), Windows (EXE + Inno installer)
   and an unsigned iOS archive.
2. Generates release notes from commit history.
3. Creates a GitHub Release and attaches every artifact.

## Versioning

We follow [Semantic Versioning](https://semver.org): `MAJOR.MINOR.PATCH`.
The Flutter build number (`+N`) increments every release.

## iOS / App Store (manual signing required)

A fully signed `.ipa` cannot be produced in a public workflow without Apple
credentials. To publish:

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Set your Team and a unique Bundle Identifier under *Signing & Capabilities*.
3. **Product ▸ Archive**, then distribute via the Organizer to TestFlight or the
   App Store.

To automate later, add `APPLE_CERTIFICATE`, `APPLE_PROVISIONING_PROFILE` and
related secrets as **GitHub Secrets** and extend the `ios` job with `fastlane`.

## Android signing

1. Create a keystore and a `android/key.properties` (never commit it).
2. Reference it in `android/app/build.gradle`.
3. Store the keystore + passwords as GitHub Secrets for CI signing.
