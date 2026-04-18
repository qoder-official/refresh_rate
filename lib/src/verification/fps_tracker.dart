import 'dart:ui' show FramePhase;
import 'package:flutter/scheduler.dart';

class FrameSample {
  final int buildUs;
  final int rasterUs;
  final int totalUs;
  final int vsyncUs;
  final DateTime timestamp;

  FrameSample({
    required this.buildUs,
    required this.rasterUs,
    required this.totalUs,
    required this.vsyncUs,
    required this.timestamp,
  });
}

class FpsTracker {
  final List<FrameSample> _samples = [];

  int get sampleCount => _samples.length;

  void addTimings(List<FrameTiming> timings) {
    final now = DateTime.now();
    for (final t in timings) {
      _samples.add(FrameSample(
        buildUs: t.buildDuration.inMicroseconds,
        rasterUs: t.rasterDuration.inMicroseconds,
        totalUs: t.totalSpan.inMicroseconds,
        vsyncUs: t.timestampInMicroseconds(FramePhase.vsyncStart),
        timestamp: now,
      ));
    }
    // Keep a bounded window so memory doesn't grow unbounded during long sessions
    if (_samples.length > 600) {
      _samples.removeRange(0, _samples.length - 600);
    }
  }

  void reset() => _samples.clear();

  List<FrameSample> get samples => List.unmodifiable(_samples);

  /// FPS over all samples — used by benchmark sessions.
  double get avgFps => _fpsFromWindow(_samples);

  /// FPS over the last [n] frames — used by the live overlay.
  double recentFps([int n = 60]) {
    if (_samples.length < 2) return 0.0;
    final window = _samples.length <= n ? _samples : _samples.sublist(_samples.length - n);
    return _fpsFromWindow(window);
  }

  static double _fpsFromWindow(List<FrameSample> s) {
    if (s.length < 2) return 0.0;
    final elapsedUs = s.last.vsyncUs - s.first.vsyncUs;
    if (elapsedUs <= 0) return 0.0;
    return (s.length - 1) * 1000000.0 / elapsedUs;
  }

  double get avgBuildMs {
    if (_samples.isEmpty) return 0.0;
    return _samples.fold<int>(0, (s, f) => s + f.buildUs) / _samples.length / 1000.0;
  }

  double get avgRasterMs {
    if (_samples.isEmpty) return 0.0;
    return _samples.fold<int>(0, (s, f) => s + f.rasterUs) / _samples.length / 1000.0;
  }

  double get avgTotalMs {
    if (_samples.isEmpty) return 0.0;
    return _samples.fold<int>(0, (s, f) => s + f.totalUs) / _samples.length / 1000.0;
  }

  double get onePercentLowFps {
    if (_samples.isEmpty) return 0.0;
    final sorted = _samples.map((s) => s.totalUs).toList()..sort();
    final cutoff = (sorted.length * 0.99).floor();
    final slowSamples = sorted.skip(cutoff).toList();
    if (slowSamples.isEmpty) return avgFps;
    final avgSlowUs = slowSamples.fold<int>(0, (s, v) => s + v) / slowSamples.length;
    return avgSlowUs > 0 ? 1000000 / avgSlowUs : 0.0;
  }

  double get fivePercentLowFps {
    if (_samples.isEmpty) return 0.0;
    final sorted = _samples.map((s) => s.totalUs).toList()..sort();
    final cutoff = (sorted.length * 0.95).floor();
    final slowSamples = sorted.skip(cutoff).toList();
    if (slowSamples.isEmpty) return avgFps;
    final avgSlowUs = slowSamples.fold<int>(0, (s, v) => s + v) / slowSamples.length;
    return avgSlowUs > 0 ? 1000000 / avgSlowUs : 0.0;
  }

  int jankyFrameCount(double targetHz) {
    final budgetUs = (1000000 / targetHz).round();
    return _samples.where((s) => s.totalUs > budgetUs).length;
  }

  int severeJankCount(double targetHz) {
    final budgetUs = (1000000 / targetHz).round();
    return _samples.where((s) => s.totalUs > budgetUs * 2).length;
  }

  double missedFramePercent(double targetHz) {
    if (_samples.isEmpty) return 0.0;
    return jankyFrameCount(targetHz) / _samples.length * 100.0;
  }
}
