## 1.0.0

Initial stable release.

**Core**
- `RefreshRate.enable()` — one-line unlock of peak display rate on all supported platforms
- `RefreshRate.preferMax()` / `preferDefault()` — explicit rate preference control
- `RefreshRate.matchContent(fps)` — sync display cadence to content frame rate (fixes 24 fps video judder)
- `RefreshRate.boost(duration)` — temporary max-rate spike for gesture-driven animations
- `RefreshRate.category(RateCategory)` — Android 15 semantic rate category passthrough
- `RefreshRate.setTouchBoost(bool)` — Android 15-QPR1 touch-driven rate boost
- `RefreshRate.info` — synchronous cached `RefreshRateInfo` snapshot
- `RefreshRate.onChanged` — stream that fires on rate change, Low Power Mode toggle, or thermal state change
- `RefreshRate.isLowPowerMode`, `RefreshRate.thermalState`, `RefreshRate.isProMotionReady`

**Overlays**
- `RefreshRate.showFPS()` — live FPS counter badge
- `RefreshRate.showHz()` — live Hz badge
- `RefreshRate.showOverlay()` — full diagnostic HUD (FPS, build/raster ms, frame budget, Low Power, thermal)
- `RefreshRate.hideOverlay()`
- All overlays are refresh-rate-aware: FPS colour is relative to the device's actual target rate, not a fixed 60 Hz baseline

**Benchmark sessions**
- `RefreshRate.startSession(name)` → `RefreshRateSession`
- `session.end()` → `SessionReport` with verdict, bottleneck, avgFps, 1% low FPS, missed-frame %, and JSON export
- Sessions auto-exclude backgrounded periods, resume warmup, LPM changes, and thermal changes

**Platform**
- Android 6+ (API 23): `Surface.setFrameRate()` (API 30+), `preferredDisplayModeId` fallback (API 23–29)
- iOS 15+: `CADisplayLink.preferredFrameRateRange` with Info.plist ProMotion validation
- macOS 14+ (Sonoma): `CADisplayLink`-based control via `NSView.displayLink`
- macOS < 14, Windows, Linux: query-only (reports real monitor refresh rate)
- All platform bridges use [pigeon](https://pub.dev/packages/pigeon) — fully typed, zero `MethodChannel` codec overhead
