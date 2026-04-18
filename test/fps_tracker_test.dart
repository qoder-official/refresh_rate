import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:refresh_rate/src/verification/fps_tracker.dart';
import 'package:refresh_rate/src/verification/refresh_rate_session.dart';
import 'package:refresh_rate/src/verification/session_scorer.dart';
import 'package:refresh_rate/src/models/display_info.dart';
import 'package:refresh_rate/src/models/enums.dart';
import 'package:refresh_rate/src/models/session_report.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FpsTracker', () {
    test('starts with no samples', () {
      final tracker = FpsTracker();
      expect(tracker.sampleCount, 0);
      expect(tracker.avgFps, 0.0);
    });

    test('addTimings accumulates samples', () {
      final tracker = FpsTracker();
      final timings = List<FrameTiming>.generate(10, (i) => _fakeTiming(8333));
      tracker.addTimings(timings);
      expect(tracker.sampleCount, 10);
    });

    test('avgFps is reasonable for 120fps timings', () {
      final tracker = FpsTracker();
      final timings = List<FrameTiming>.generate(120, (i) => _fakeTiming(8333));
      tracker.addTimings(timings);
      // 1s / 8333µs ≈ 120fps
      expect(tracker.avgFps, closeTo(120.0, 5.0));
    });

    test('reset clears all samples', () {
      final tracker = FpsTracker();
      tracker.addTimings(List<FrameTiming>.generate(10, (i) => _fakeTiming(8333)));
      tracker.reset();
      expect(tracker.sampleCount, 0);
    });

    test('onePercentLow is less than or equal to avgFps', () {
      final tracker = FpsTracker();
      final fast = List<FrameTiming>.generate(100, (i) => _fakeTiming(8333));
      final slow = List<FrameTiming>.generate(10, (i) => _fakeTiming(33333));
      tracker.addTimings([...fast, ...slow]);
      expect(tracker.onePercentLowFps, lessThanOrEqualTo(tracker.avgFps));
    });

    test('jankyFrameCount counts frames over budget', () {
      final tracker = FpsTracker();
      // At 60fps, budget = ~16667µs. Add 5 frames over budget.
      final normal = List<FrameTiming>.generate(10, (_) => _fakeTiming(8333));
      final janky = List<FrameTiming>.generate(5, (_) => _fakeTiming(20000));
      tracker.addTimings([...normal, ...janky]);
      expect(tracker.jankyFrameCount(60.0), 5);
    });

    test('missedFramePercent is 0 when no jank', () {
      final tracker = FpsTracker();
      tracker.addTimings(List<FrameTiming>.generate(100, (_) => _fakeTiming(8333)));
      expect(tracker.missedFramePercent(120.0), 0.0);
    });

    test('onePercentLowFps works for small sample count', () {
      final tracker = FpsTracker();
      // 10 frames: 9 fast + 1 slow. With floor cutoff, 1 slow frame is captured.
      final fast = List<FrameTiming>.generate(9, (_) => _fakeTiming(8333));
      final slow = List<FrameTiming>.generate(1, (_) => _fakeTiming(33333));
      tracker.addTimings([...fast, ...slow]);
      // onePercentLow should be close to 30fps (the slow frame), not avgFps
      expect(tracker.onePercentLowFps, lessThan(tracker.avgFps));
    });
  });

  group('SessionScorer.compute', () {
    test('returns inconclusive for zero-frame session', () {
      final report = SessionScorer.compute(
        sessionName: 'empty',
        tracker: FpsTracker(),
        targetHz: 120.0,
        validDuration: Duration(seconds: 1),
        excludedDuration: Duration.zero,
        exclusionReasons: {},
        deviceState: DeviceStateSnapshot(thermalState: ThermalState.nominal),
      );
      expect(report.verdict, Verdict.inconclusive);
    });

    test('returns excellent for smooth 120fps session', () {
      final tracker = FpsTracker();
      tracker.addTimings(List<FrameTiming>.generate(120, (_) => _fakeTiming(8333)));
      final report = SessionScorer.compute(
        sessionName: 'smooth',
        tracker: tracker,
        targetHz: 120.0,
        validDuration: Duration(seconds: 1),
        excludedDuration: Duration.zero,
        exclusionReasons: {},
        deviceState: DeviceStateSnapshot(thermalState: ThermalState.nominal),
      );
      expect(report.verdict, Verdict.excellent);
    });

    test('returns powerLimited bottleneck when LPM is true', () {
      final tracker = FpsTracker();
      tracker.addTimings(List<FrameTiming>.generate(60, (_) => _fakeTiming(8333)));
      final report = SessionScorer.compute(
        sessionName: 'lpm',
        tracker: tracker,
        targetHz: 120.0,
        validDuration: Duration(seconds: 1),
        excludedDuration: Duration.zero,
        exclusionReasons: {},
        deviceState: DeviceStateSnapshot(
          thermalState: ThermalState.nominal,
          isLowPowerMode: true,
        ),
      );
      expect(report.likelyBottleneck, Bottleneck.powerLimited);
    });

    test('returns displayCapped for 88% fps', () {
      final tracker = FpsTracker();
      // 88% of 120fps ≈ 105.6fps. Frame time: 1_000_000 / 105.6 ≈ 9470µs
      tracker.addTimings(List<FrameTiming>.generate(100, (_) => _fakeTiming(9470)));
      final report = SessionScorer.compute(
        sessionName: 'capped',
        tracker: tracker,
        targetHz: 120.0,
        validDuration: Duration(seconds: 1),
        excludedDuration: Duration.zero,
        exclusionReasons: {},
        deviceState: DeviceStateSnapshot(thermalState: ThermalState.nominal),
      );
      expect(report.likelyBottleneck, Bottleneck.displayCapped);
    });
  });

  group('RefreshRateSession', () {
    test('starts in running state', () {
      WidgetsFlutterBinding.ensureInitialized();
      final info = DisplayInfo(
        currentRate: 120.0, maxRate: 120.0, minRate: 60.0,
        supportedRates: [60.0, 120.0], isVariableRefreshRate: true,
        engineTargetRate: 120.0, thermalState: ThermalState.nominal,
      );
      final session = RefreshRateSession.create('test', info);
      expect(session.state, SessionState.running);
      expect(session.name, 'test');
    });

    test('end() returns a SessionReport', () async {
      WidgetsFlutterBinding.ensureInitialized();
      final info = DisplayInfo(
        currentRate: 120.0, maxRate: 120.0, minRate: 60.0,
        supportedRates: [60.0, 120.0], isVariableRefreshRate: true,
        engineTargetRate: 120.0, thermalState: ThermalState.nominal,
      );
      final session = RefreshRateSession.create('scroll_test', info);
      final report = await session.end();
      expect(report.sessionName, 'scroll_test');
      expect(report.targetHz, 120.0);
      expect(report.verdict, isA<Verdict>());
    });
  });
}

FrameTiming _fakeTiming(int totalMicros) => _MockFrameTiming(totalMicros);

class _MockFrameTiming implements FrameTiming {
  final int _totalUs;
  _MockFrameTiming(this._totalUs);

  @override
  Duration get buildDuration => Duration(microseconds: (_totalUs * 0.6).toInt());
  @override
  Duration get rasterDuration => Duration(microseconds: (_totalUs * 0.4).toInt());
  @override
  Duration get totalSpan => Duration(microseconds: _totalUs);
  @override
  int get frameNumber => 0;
  @override
  int get layerCacheCount => 0;
  @override
  int get layerCacheBytes => 0;
  @override
  int get pictureCacheCount => 0;
  @override
  int get pictureCacheBytes => 0;
  @override
  int timestampInMicroseconds(FramePhase phase) => 0;

  // Forward any additional SDK-version-specific members gracefully.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
