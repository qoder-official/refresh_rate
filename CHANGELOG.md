# Changelog

## 1.0.0

Initial stable release — unlock, query, overlay, and benchmark display refresh rates across all Flutter platforms.

### Control

- `RefreshRate.enable()` — one-line unlock of peak display refresh rate
- `RefreshRate.preferMax()` / `preferDefault()` — explicit rate preference
- `RefreshRate.matchContent(fps)` — sync display cadence to content frame rate (fixes 24 fps video judder)
- `RefreshRate.boost(duration)` — temporary max-rate spike for gesture-driven animations
- `RefreshRate.category(RateCategory)` — Android 15 semantic rate category
- `RefreshRate.setTouchBoost(bool)` — Android 15 touch-driven rate boost

### Diagnostics

- `RefreshRate.info` — synchronous cached `RefreshRateInfo` snapshot (current rate, max, min, supported rates, VRR, API level)
- `RefreshRate.onChanged` — stream fires on rate change, Low Power Mode toggle, or thermal state change
- `RefreshRate.isLowPowerMode` / `thermalState` / `isProMotionReady`

### Debug overlay

- `RefreshRate.showOverlay()` — full diagnostic HUD with live FPS, build/raster timings, frame budget
- `RefreshRate.showFPS()` / `showHz()` — individual overlay badges
- FPS colour is relative to the device's actual target rate, not a hard-coded 60 Hz baseline

### Benchmark sessions

- `RefreshRate.startSession(name)` returns `RefreshRateSession`
- `session.end()` returns `SessionReport` with verdict, bottleneck, avgFps, 1% low FPS, missed-frame %, and JSON export
- Sessions auto-exclude backgrounded periods, resume warmup, LPM changes, and thermal changes

### Platform coverage

- **Android 6+** (API 23): `SurfaceControl.Transaction.setFrameRate()` (API 34+), `preferredRefreshRate` + `preferredDisplayModeId` (API 30–33), legacy `preferredDisplayModeId` fallback (API 23–29)
- **iOS 15+**: `CADisplayLink.preferredFrameRateRange` with runtime `Info.plist` ProMotion validation
- **macOS 14+**: `CADisplayLink`-based control via `NSView.displayLink`
- **macOS < 14 / Windows / Linux**: query-only (reports real monitor refresh rate)
- All platform bridges use [pigeon](https://pub.dev/packages/pigeon) — fully typed, zero codec overhead
