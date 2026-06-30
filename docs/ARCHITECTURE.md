# Architecture

TKK EyeGuard follows **Clean Architecture** with an **MVVM** presentation layer,
**Riverpod** for dependency injection / state, and the **Repository pattern**
for data access.

```
┌───────────────────────────────────────────────────────────┐
│ Presentation (MVVM)                                        │
│  Screens & Widgets  ──watch──▶  Controllers (ViewModels)   │
└───────────────────────────────────────────────────────────┘
              │ calls use-cases / reads providers
              ▼
┌───────────────────────────────────────────────────────────┐
│ Domain                                                     │
│  Entities · Repository interfaces · Use-cases (pure logic) │
└───────────────────────────────────────────────────────────┘
              │ implemented by
              ▼
┌───────────────────────────────────────────────────────────┐
│ Data                                                       │
│  Models (Hive) · Repository implementations                │
└───────────────────────────────────────────────────────────┘
              │ uses
              ▼
┌───────────────────────────────────────────────────────────┐
│ Core / Platform Services                                   │
│  Notifications · Microphone detection · Tray · Autostart   │
└───────────────────────────────────────────────────────────┘
```

## Folder layout

```
lib/
├─ main.dart                      # Bootstrap: Hive, DI container, services
├─ app/
│  ├─ app.dart                    # Root MaterialApp + router wiring
│  ├─ di/
│  │  ├─ providers.dart           # Riverpod providers (repos, services)
│  │  └─ app_coordinator.dart     # Runtime orchestrator
│  ├─ router/app_router.dart      # GoRouter graph
│  ├─ shell/home_shell.dart       # Responsive rail / bottom-nav shell
│  └─ theme/                      # Material 3 themes & colors
├─ core/
│  ├─ constants/                  # AppConfig (rebrandable) + copy
│  ├─ errors/                     # Failures & exceptions
│  ├─ services/                   # Notifications, mic, tray, autostart
│  └─ utils/                      # Logger, platform info
└─ features/
   ├─ reminder/                   # Scheduler + history (data/domain/presentation)
   ├─ dashboard/                  # Stats use-case + screen
   ├─ settings/                   # Preferences
   └─ exercise/                   # Guided animated routine
```

## Key design decisions

- **Event-driven scheduling.** `ReminderScheduler` arms a single `Timer` for the
  exact next-due instant — there is **no polling loop**, so the CPU stays idle
  between reminders. This is the core of the <30 MB / near-zero-CPU goal.
- **Meeting-aware.** A `MicrophoneActivityService` exposes a broadcast stream of
  mic-in-use state. When a reminder is due during a call it is deferred and
  re-armed for a randomised 2–5 minute cool-down after the mic is released.
- **No code-gen required to build.** Hive `TypeAdapter`s are hand-written, so a
  clean checkout builds without running `build_runner`.
- **Rebrandable.** Every user-facing string flows from `AppConfig.appName`.
- **Offline-first.** All state lives in local Hive boxes; there is no network
  dependency.

## Data flow: an hourly reminder

1. `ReminderScheduler` timer fires → checks mic state.
2. If free, emits on `onDue`; `AppCoordinator` shows a native notification and
   signals the UI to open the `ExerciseScreen`.
3. User picks Done / Snooze / Skip → `AppCoordinator.recordOutcome` persists a
   `ReminderEvent` and re-arms the next reminder.
4. `DashboardController` recomputes `DashboardStats` from history.
