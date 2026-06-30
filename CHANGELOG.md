# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-06-30

### Added
- Hourly, configurable eye-exercise reminders (30 / 45 / 60 / 90 / 120 min).
- Meeting-aware deferral: reminders are suppressed while the microphone is in
  use and resurface after a 2–5 minute cool-down.
- Native notifications with Done / Snooze / Skip actions, respecting Focus /
  Do-Not-Disturb.
- Guided 30-second exercise screen with custom-painted eye animations,
  countdown ring and completion celebration.
- Dashboard with today's outcomes, streaks, weekly/monthly trends and average
  completion rate.
- Settings: interval, start-at-login, notification sound, theme (system / light
  / dark), reset and export.
- Desktop system-tray / menu-bar presence with background operation.
- Start-at-login on Windows & macOS.
- Clean Architecture + MVVM + Riverpod + Hive, offline-first.
- CI (analyze / format / test / multi-platform build), CodeQL, Dependabot and an
  automated multi-platform release pipeline.
