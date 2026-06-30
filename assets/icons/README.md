# Icons

This folder is bundled with the app (see `pubspec.yaml`).

Required runtime icons (generate from `../branding/app_icon.svg`):

| File | Purpose | Size |
|------|---------|------|
| `tray_icon.png` | macOS menu-bar / Linux tray | 22×22 (and @2x 44×44) |
| `tray_icon.ico` | Windows system tray | 16/32/48 multi-size |

Generate launcher icons for every platform with:

```bash
dart run flutter_launcher_icons
```

See `docs/BRANDING.md` for the full asset pipeline.
