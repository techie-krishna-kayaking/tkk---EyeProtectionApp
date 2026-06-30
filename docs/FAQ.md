# FAQ

**Is my data sent anywhere?**
No. EyeGuard is 100% offline. All settings and history live in local Hive
storage on your device.

**Does it record my microphone?**
No. It only checks the operating-system flag that says whether *some* app is
using the mic — it never accesses audio.

**Why didn't I get a reminder during my call?**
That's by design. EyeGuard defers reminders while your mic is active and shows
them 2–5 minutes after the call ends.

**How light is it really?**
The scheduler is fully event-driven (a single timer, no polling), and
animations are painted procedurally, so idle CPU is near zero and memory stays
well under 30 MB.

**Can I change how often it reminds me?**
Yes — Settings ▸ Reminder interval (30 / 45 / 60 / 90 / 120 minutes).

**Does it start automatically?**
On Windows and macOS, enable *Start at login* in Settings. On Android it can
restart after reboot; iOS does not permit launch-at-login, so it relies on
scheduled notifications.

**Can I rename the app?**
Yes — change `AppConfig.appName` in `lib/core/constants/app_config.dart` (and
the bundle identifiers in the native projects).

**How do I build it myself?**
See [`BUILD.md`](BUILD.md).
