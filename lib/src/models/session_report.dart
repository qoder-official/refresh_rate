import 'dart:convert';
import 'enums.dart';

class DeviceStateSnapshot {
  final bool? isLowPowerMode;
  final ThermalState thermalState;
  final bool? hasAdaptiveRefreshRate;
  final String? displayServer;
  final int? monitorCount;

  const DeviceStateSnapshot({
    this.isLowPowerMode,
    required this.thermalState,
    this.hasAdaptiveRefreshRate,
    this.displayServer,
    this.monitorCount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceStateSnapshot &&
          isLowPowerMode == other.isLowPowerMode &&
          thermalState == other.thermalState;

  @override
  int get hashCode => Object.hash(isLowPowerMode, thermalState);

  Map<String, dynamic> toMap() => {
        'isLowPowerMode': isLowPowerMode,
        'thermalState': thermalState.name,
        'hasAdaptiveRefreshRate': hasAdaptiveRefreshRate,
        'displayServer': displayServer,
        'monitorCount': monitorCount,
      };
}

class SessionReport {
  final String sessionName;
  final Verdict verdict;
  final Bottleneck likelyBottleneck;
  final double targetHz;
  final double observedAvgHz;
  final double frameBudgetMs;
  final double avgFps;
  final double onePercentLowFps;
  final double fivePercentLowFps;
  final double avgBuildMs;
  final double avgRasterMs;
  final double avgTotalFrameMs;
  final int jankyFrameCount;
  final int severeJankCount;
  final double missedFramePercent;
  final Duration validDuration;
  final Duration excludedDuration;
  final Map<ExclusionReason, int> exclusionReasons;
  final DeviceStateSnapshot deviceState;

  const SessionReport({
    required this.sessionName,
    required this.verdict,
    required this.likelyBottleneck,
    required this.targetHz,
    required this.observedAvgHz,
    required this.frameBudgetMs,
    required this.avgFps,
    required this.onePercentLowFps,
    required this.fivePercentLowFps,
    required this.avgBuildMs,
    required this.avgRasterMs,
    required this.avgTotalFrameMs,
    required this.jankyFrameCount,
    required this.severeJankCount,
    required this.missedFramePercent,
    required this.validDuration,
    required this.excludedDuration,
    required this.exclusionReasons,
    required this.deviceState,
  });

  Map<String, dynamic> toMap() => {
        'sessionName': sessionName,
        'verdict': verdict.name,
        'likelyBottleneck': likelyBottleneck.name,
        'targetHz': targetHz,
        'observedAvgHz': observedAvgHz,
        'frameBudgetMs': frameBudgetMs,
        'avgFps': avgFps,
        'onePercentLowFps': onePercentLowFps,
        'fivePercentLowFps': fivePercentLowFps,
        'avgBuildMs': avgBuildMs,
        'avgRasterMs': avgRasterMs,
        'avgTotalFrameMs': avgTotalFrameMs,
        'jankyFrameCount': jankyFrameCount,
        'severeJankCount': severeJankCount,
        'missedFramePercent': missedFramePercent,
        'validDurationMs': validDuration.inMilliseconds,
        'excludedDurationMs': excludedDuration.inMilliseconds,
        'exclusionReasons': exclusionReasons.map((k, v) => MapEntry(k.name, v)),
        'deviceState': deviceState.toMap(),
      };

  String toJson() => jsonEncode(toMap());

  String toCsv() {
    final m = toMap();
    String esc(dynamic v) {
      final s = v is Map ? jsonEncode(v) : '$v';
      if (s.contains(',') || s.contains('"') || s.contains('\n')) {
        return '"${s.replaceAll('"', '""')}"';
      }
      return s;
    }
    final headers = m.keys.join(',');
    final values = m.values.map(esc).join(',');
    return '$headers\n$values';
  }
}
