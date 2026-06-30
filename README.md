<div align="center">

<img src="assets/branding/logo.svg" alt="TKK EyeGuard logo" width="128" height="128" />

# 👀 TKK EyeGuard

### Healthy eyes, every hour — without interrupting your meetings.

A lightweight, cross-platform desktop & mobile app that gently reminds you to
rest your eyes every hour, intelligently pausing while you're on a call.

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Material 3](https://img.shields.io/badge/Material_3-757575?style=for-the-badge&logo=materialdesign&logoColor=white)](https://m3.material.io)

[![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)](#-downloads)
[![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)](#-downloads)
[![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](#-downloads)
[![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=apple&logoColor=white)](#-downloads)

[![CI](https://img.shields.io/badge/CI-GitHub_Actions-2088FF?style=flat-square&logo=githubactions&logoColor=white)](.github/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](CONTRIBUTING.md)
![Version](https://img.shields.io/badge/version-1.0.0-blue?style=flat-square)
![Memory](https://img.shields.io/badge/RAM-%3C30MB-success?style=flat-square)
![Offline](https://img.shields.io/badge/100%25-offline-informational?style=flat-square)

</div>

---

## ✨ Why EyeGuard?

Staring at screens all day strains your eyes. The **20-20-20 rule** says: every
20 minutes, look at something 20 feet away for 20 seconds. EyeGuard automates the
healthy habit — and unlike other reminder apps, it **knows when you're in a
meeting** and stays quiet until you're free.

| | |
|---|---|
| 🪶 **Featherweight** | Event-driven, **<30 MB RAM**, near-zero idle CPU. No polling. |
| 🤫 **Meeting-aware** | Detects active microphone use and defers reminders. |
| 🎨 **Beautiful** | Material 3, glassmorphism, custom-painted eye animations. |
| 🔒 **Private** | 100% offline. Your data never leaves your device. |
| 🖥️ **Everywhere** | Windows, macOS, Android & iOS from one codebase. |

---

## 🎯 Features

- **Hourly reminders** with a configurable interval (30 / 45 / 60 / 90 / 120 min).
- **Smart meeting detection** — no popups while your mic is active (Teams, Zoom,
  Meet, Slack, Discord, FaceTime, Webex, Skype, …); resurfaces after a 2–5 min
  cool-down.
- **Native notifications** with **Done · Snooze 5 min · Skip**, respecting Focus
  & Do-Not-Disturb.
- **Guided 30-second routine** — look away, blink, roll clockwise &
  anti-clockwise, breathe — with animated eye, countdown ring and a completion
  celebration.
- **Dashboard** — today's reminders, completed / skipped / snoozed, completion %,
  current streak, weekly & monthly trends, last reminder.
- **Settings** — interval, start-at-login, sound, theme (system / light / dark),
  reset & export.
- **Background presence** — system tray (Windows) / menu bar (macOS); starts at
  login.

---

## 🧱 Architecture

Clean Architecture · MVVM · Riverpod (DI) · Repository pattern · Hive
(offline storage). See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

```mermaid
flowchart TD
    UI[Screens & Widgets] -->|watch| VM[Controllers / ViewModels]
    VM --> UC[Use-cases & Repos]
    UC --> DATA[Hive Repositories]
    UC --> SVC[Platform Services]
    SVC --> NOTIF[Notifications]
    SVC --> MIC[Mic / Meeting Detection]
    SVC --> TRAY[Tray / Menu bar]
    SCH[ReminderScheduler\nevent-driven, no polling] --> VM
    MIC --> SCH
```

### 📁 Folder structure

```
lib/
├─ main.dart              # Bootstrap (Hive, DI, services)
├─ app/                   # App shell, router, theme, DI, coordinator
├─ core/                  # Config, services, errors, utils
└─ features/
   ├─ reminder/           # Scheduler + history
   ├─ dashboard/          # Statistics
   ├─ settings/           # Preferences
   └─ exercise/           # Guided animated routine
assets/        docs/        installers/        test/        .github/
```

---

## 🚀 Getting started

> The shared Dart codebase lives here. Native runners are generated with one
> command — see [`docs/BUILD.md`](docs/BUILD.md).

```bash
# 1. Generate native platform folders
flutter create --platforms=android,ios,macos,windows,linux .

# 2. Install dependencies
flutter pub get

# 3. Run
flutter run -d macos        # or windows / <android> / <ios>
```

Then add the native microphone-detection handlers from
[`docs/NATIVE_INTEGRATION.md`](docs/NATIVE_INTEGRATION.md).

---

## 📥 Downloads

Pre-built artifacts are produced by GitHub Actions:

- **On every release tag** → attached to the [GitHub Release](../../releases).
- **On demand** → open the **Actions ▸ [Build Artifacts](../../actions/workflows/build-artifacts.yml)**
  workflow, click **Run workflow**, then download from the run's *Artifacts*.

| Platform | Artifact |
|----------|----------|
| 🪟 Windows | Portable build (`.zip`) + Inno Setup installer (`.exe`) |
| 🍎 macOS | `.dmg` (drag-to-Applications) |
| 🤖 Android | `.apk` + `.aab` |
| 📱 iOS | Unsigned `.ipa` (re-sign with your Apple cert — see [`docs/RELEASE.md`](docs/RELEASE.md)) |

---

## 🛠️ Tech Stack

| Layer | Choice |
|-------|--------|
| UI | Flutter, Material 3 |
| State / DI | Riverpod |
| Routing | go_router |
| Storage | Hive (offline) |
| Notifications | flutter_local_notifications |
| Desktop | window_manager · tray_manager · launch_at_startup |
| Architecture | Clean Architecture + MVVM + Repository pattern |

---

## ⚡ Performance

Designed from the ground up to be invisible on your system:

- **Event-driven**, single-timer scheduler — **no polling loops**.
- Procedurally-painted animations (no heavy Lottie/GIF assets).
- Target **<20–30 MB RAM**, negligible CPU & battery, small disk footprint.
- Fully **offline** — zero network calls.

---

## ✅ Quality & CI/CD

- `flutter analyze` (strict lints) · `dart format` check · unit, widget &
  integration tests on every push.
- Multi-platform build matrix (Android / macOS / Windows / iOS).
- **CodeQL** security scanning + **Dependabot** updates.
- Tag-driven **automated releases** with artifacts attached. See
  [`docs/RELEASE.md`](docs/RELEASE.md).

---

## 🗺️ Roadmap

Architecture already supports these future additions:

- [ ] AI posture & face-distance detection (webcam fatigue)
- [ ] Water / stretch reminders · Pomodoro & break timer
- [ ] Health analytics (Apple Health · Google Fit · wearables)
- [ ] Optional encrypted cloud sync & multi-device

---

## 🤝 Contributing

Contributions are welcome! Read [`CONTRIBUTING.md`](CONTRIBUTING.md) and our
[Code of Conduct](CODE_OF_CONDUCT.md). Run `dart format . && flutter analyze &&
flutter test` before opening a PR.

---

## 📜 License

Released under the [MIT License](LICENSE).

---

## 🙏 Acknowledgements

Built with the wonderful Flutter ecosystem — Riverpod, Hive, go_router,
flutter_local_notifications, window_manager & tray_manager.

---

<div align="center">

### 🔗 Connect with Techie Krishna Kayaking

<a href="https://www.linkedin.com/in/krishnakayaking/"><img src="https://img.shields.io/badge/LinkedIn-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn" /></a>&nbsp;
<a href="https://www.youtube.com/@TechieKrishnaKayaking"><img src="https://img.shields.io/badge/YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white" alt="YouTube" /></a>&nbsp;
<a href="https://www.techiekrishnakayaking.com/"><img src="https://img.shields.io/badge/Website-000000?style=for-the-badge&logo=google-chrome&logoColor=white" alt="Website" /></a>&nbsp;
<a href="https://topmate.io/techie_krishna_kayaking"><img src="https://img.shields.io/badge/Topmate-FFCA28?style=for-the-badge&logo=bookstack&logoColor=black" alt="Topmate" /></a>&nbsp;
<a href="https://www.instagram.com/techiekrishnakayaking/"><img src="https://img.shields.io/badge/Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white" alt="Instagram" /></a>&nbsp;
<a href="https://play.google.com/store/apps/details?id=co.diaz.ycvkc&hl=en_IN"><img src="https://img.shields.io/badge/Play_Store-414141?style=for-the-badge&logo=google-play&logoColor=white" alt="Play Store" /></a>

<br/><br/>

⭐ If EyeGuard helps your eyes, consider starring the repo!

</div>
