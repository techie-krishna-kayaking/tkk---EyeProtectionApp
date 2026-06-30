# Developer Guide

## Project conventions

- **Lints:** `flutter_lints` + strict analyzer options (`analysis_options.yaml`).
  Run `flutter analyze` before every commit; CI fails on any issue.
- **Formatting:** `dart format .` — CI rejects unformatted code.
- **State:** Riverpod. UI watches `*Controller` providers; never mutate state
  directly from widgets.
- **No code-gen to build:** Hive adapters are hand-written. If you add a model,
  give it a unique `typeId` and register it in `main.dart`.
- **Keep it light:** avoid timers/polling, heavy packages, and background work.
  Prefer event streams.

## Adding a feature

1. Create `lib/features/<name>/{domain,data,presentation}`.
2. Define entities + repository interface in `domain/`.
3. Implement the repository in `data/` and expose it via a provider in
   `app/di/providers.dart`.
4. Add a `Controller` (StateNotifier) and screen in `presentation/`.
5. Register routes in `app/router/app_router.dart`.
6. Write unit tests for use-cases and a widget test for the screen.

## Testing

```bash
flutter test                 # unit + widget
flutter test --coverage      # with coverage
flutter test integration_test
```

- Pure logic (use-cases, scheduler) is tested with `fake_async` — no real time.
- Platform services are abstracted behind interfaces so they can be faked.

## Useful commands

```bash
flutter run -d macos
flutter pub outdated
flutter pub upgrade --major-versions
dart run flutter_launcher_icons   # regenerate launcher icons
```
