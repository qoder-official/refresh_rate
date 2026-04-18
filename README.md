# refresh_rate

[![pub package](https://img.shields.io/pub/v/refresh_rate.svg)](https://pub.dev/packages/refresh_rate)
[![pub points](https://img.shields.io/pub/points/refresh_rate)](https://pub.dev/packages/refresh_rate/score)
[![License: BSD-3](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](https://github.com/qoder-official/refresh_rate/blob/main/LICENSE)

Cross-platform Flutter plugin to unlock, query, and verify your device's full display refresh rate — 90 Hz, 120 Hz, 144 Hz, and beyond.

Flutter apps run at 60 Hz on high-refresh-rate devices by default because the engine never communicates peak capability to the OS compositor. `refresh_rate` makes that declaration in one line, and gives you diagnostics, benchmark sessions, and a live overlay to confirm it's actually working.

Built on [pigeon](https://pub.dev/packages/pigeon) — fully typed end-to-end, zero `MethodChannel` codec overhead.

---

## Platform support

| Platform | Unlock | Query | Overlay | Sessions |
|---|---|---|---|---|
| Android 6+ (API 23) | ✅ | ✅ | ✅ | ✅ |
| iOS 15+ | ✅ * | ✅ | ✅ | ✅ |
| macOS 14+ (Sonoma) | ✅ | ✅ | ✅ | ✅ |
| macOS < 14 | — | ✅ | ✅ | ✅ |
| Windows | — | ✅ | ✅ | ✅ |
| Linux | — | ✅ | ✅ | ✅ |

\* iOS requires an additional `Info.plist` key — see [iOS setup](#ios-setup) below.

---

## Installation

```yaml
dependencies:
  refresh_rate: ^0.1.0
```

---

## Quick start

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  RefreshRate.enable();   // unlocks peak rate on every supported device
  runApp(const MyApp());
}
```

That's all you need for the common case. On a 120 Hz device, your app will now render at 120 Hz instead of the default 60 Hz Flutter lock.

### iOS setup

Add this key to `ios/Runner/Info.plist` — required for > 60 Hz on any iPhone with ProMotion:

```xml
<key>CADisableMinimumFrameDurationOnPhone</key>
<true/>
```

Without this key, iOS ignores frame-rate hints from Flutter even if the hardware supports them.

---

## Diagnostics

```dart
// Synchronous cached snapshot — safe to call anywhere
final info = RefreshRate.info;

print(info.currentRate);          // 120.0
print(info.maxRate);              // 120.0
print(info.minRate);              // 60.0
print(info.supportedRates);       // [60.0, 90.0, 120.0]
print(info.isVariableRefreshRate); // true — LTPO panel
print(info.androidApiLevel);      // 34 (Android only)
print(info.displayServer);        // "wayland" (Linux only)

// System state
print(RefreshRate.isLowPowerMode);    // false
print(RefreshRate.thermalState);      // ThermalState.nominal
print(RefreshRate.isProMotionReady);  // true — plist key + hardware both present

// Refresh whenever you need the latest snapshot
await RefreshRate.refresh();

// Stream: fires on rate change, Low Power Mode toggle, or thermal state change
RefreshRate.onChanged.listen((info) {
  print('Rate changed to ${info.currentRate} Hz');
});
```

---

## Advanced control

```dart
// Prefer the maximum available rate
RefreshRate.preferMax();

// Return to OS default
RefreshRate.preferDefault();

// Match display cadence to a specific content frame rate (fixes 24 fps video judder)
RefreshRate.matchContent(24.0);

// Temporary rate spike — useful for animations triggered by gestures
RefreshRate.boost(const Duration(seconds: 2));

// Android 15: semantic rate category
RefreshRate.category(RateCategory.high);   // high | normal | low

// Android 15-QPR1: enable touch-driven rate boost
RefreshRate.setTouchBoost(true);
```

---

## Debug overlay

Drop a live performance HUD into any debug build:

```dart
@override
void initState() {
  super.initState();
  if (kDebugMode) RefreshRate.showOverlay();
}
```

Or show individual badges:

```dart
RefreshRate.showFPS();      // live FPS counter
RefreshRate.showHz();       // current Hz badge
RefreshRate.showOverlay();  // full diagnostic panel

RefreshRate.hideOverlay();  // dismiss
```

The full overlay shows:
- Live FPS with colour-coded health (green / amber / red relative to the *device's actual target rate*, not a fixed 60 Hz baseline)
- Per-frame build and raster timings in ms
- Frame budget at the current target Hz
- Low Power Mode warning
- Thermal state warning

---

## Benchmark sessions

Record a time-bounded performance window and get a structured report:

```dart
// Start before user interaction
final session = RefreshRate.startSession('home_feed_scroll');

// … user scrolls for a few seconds …

// End and inspect
final report = await session.end();

print(report.verdict);             // Verdict.good | degraded | poor
print(report.likelyBottleneck);    // Bottleneck.rasterBound | buildBound | none
print(report.avgFps);              // 108.4
print(report.onePercentLowFps);    // 87.2  (1% low — worst-case jank metric)
print(report.missedFramePercent);  // 3.2%
print(report.validDuration);       // Duration of frames actually counted

// Export for CI / QA dashboards
final json = report.toJson();
```

Sessions automatically exclude:
- App backgrounding / foregrounding
- Resume warmup windows
- Low Power Mode state changes
- Thermal state changes

---

## Migration from `flutter_displaymode`

```dart
// Before — verbose, Android-only, broken on LTPO displays
final modes = await FlutterDisplayMode.supported;
final highest = modes.reduce((a, b) => a.refreshRate > b.refreshRate ? a : b);
await FlutterDisplayMode.setPreferredMode(highest);

// After — one line, all platforms
RefreshRate.enable();
```

`flutter_displaymode` silently fails on Samsung/OnePlus/Pixel Pro LTPO panels, does nothing on iOS, and has been unmaintained since 2023. `refresh_rate` is actively maintained and supports all six Flutter platforms.

---

## API reference

| Method | Description |
|---|---|
| `RefreshRate.enable()` | Equivalent to `preferMax()` — call once in `main()` |
| `RefreshRate.disable()` | Stop overriding; return to OS default |
| `RefreshRate.preferMax()` | Request the highest available rate |
| `RefreshRate.preferDefault()` | Clear any override |
| `RefreshRate.matchContent(fps)` | Match display cadence to content frame rate |
| `RefreshRate.boost(duration)` | Temporary max-rate spike |
| `RefreshRate.category(cat)` | Android 15 semantic category |
| `RefreshRate.setTouchBoost(bool)` | Android 15-QPR1 touch boost |
| `RefreshRate.refresh()` | Reload platform info cache |
| `RefreshRate.showFPS()` | Show live FPS overlay badge |
| `RefreshRate.showHz()` | Show live Hz overlay badge |
| `RefreshRate.showOverlay()` | Show full diagnostic overlay |
| `RefreshRate.hideOverlay()` | Dismiss overlay |
| `RefreshRate.startSession(name)` | Begin a benchmark session |
| `RefreshRate.info` | Cached `RefreshRateInfo` snapshot |
| `RefreshRate.isLowPowerMode` | Low Power / Battery Saver active |
| `RefreshRate.thermalState` | `ThermalState` enum |
| `RefreshRate.isProMotionReady` | iOS: plist key + ProMotion hardware |
| `RefreshRate.onChanged` | `Stream<RefreshRateInfo>` |

---

## License

BSD 3-Clause © 2026 [Qoder](https://qoder.in)

See [LICENSE](https://github.com/qoder-official/refresh_rate/blob/main/LICENSE) for the full text.

---

Made with ♥ by [Qoder](https://qoder.in) · [Other packages](https://pub.dev/publishers/qoder.in/packages)
