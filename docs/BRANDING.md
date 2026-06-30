# Branding

## Logo & icon

Source vectors live in `assets/branding/`:

- `logo.svg` — primary logo (eye + check motif).
- `app_icon.svg` — rounded app icon.

### Generating raster assets

1. Export a 1024×1024 PNG from `app_icon.svg` to `assets/icons/app_icon.png`
   (any vector tool, or `rsvg-convert` / `inkscape`):

   ```bash
   rsvg-convert -w 1024 -h 1024 assets/branding/app_icon.svg \
     -o assets/icons/app_icon.png
   ```

2. Generate per-platform launcher icons:

   ```bash
   dart run flutter_launcher_icons
   ```

3. Export tray icons:
   - `assets/icons/tray_icon.png` (22×22, plus @2x 44×44) for macOS / Linux
   - `assets/icons/tray_icon.ico` (16/32/48) for Windows

## Brand colors

| Token | Hex |
|-------|-----|
| Primary | `#3D7BFF` |
| Accent | `#22C7A9` |
| Success | `#2BB673` |
| Warning | `#F5A623` |
| Danger | `#E0526A` |

Defined in `lib/app/theme/app_colors.dart`.

## Typography

The UI requests the **Inter** typeface and falls back to the platform default
until the font files are bundled (see the commented `fonts:` block in
`pubspec.yaml`).
