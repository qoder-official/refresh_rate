# Screenshots needed before publish

pub.dev supports a `screenshots` section in pubspec.yaml (max 4 MB per image).
These are referenced in pubspec.yaml and will appear on the package page.

## Required files

1. **overlay.png** — Screenshot of the live FPS overlay running on a real device
   - Show the debug HUD with FPS counter, Hz badge, frame budget
   - Ideally on a 120Hz device showing >60 FPS in green

2. **before-after.png** — Side-by-side or annotated comparison
   - Left: Flutter app at 60Hz (default)
   - Right: Same app at 120Hz with refresh_rate enabled
   - Could be two phone screenshots or a single composite

## Tips

- Use a real device (CMF Phone 1 at 120Hz is perfect)
- PNG format, reasonable resolution (1080px wide works well)
- Keep file size under 4 MB each
- Dark backgrounds look better on pub.dev's dark theme
