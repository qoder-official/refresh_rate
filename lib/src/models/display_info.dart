import '../generated/refresh_rate_api.g.dart';
import 'enums.dart';

class DisplayInfo {
  final double currentRate;
  final double maxRate;
  final double minRate;
  final List<double> supportedRates;
  final bool isVariableRefreshRate;
  final double engineTargetRate;
  final bool? iosProMotionEnabled;
  final int? androidApiLevel;
  final bool? isLowPowerMode;
  final ThermalState thermalState;
  final bool? hasAdaptiveRefreshRate;
  final String? displayServer;
  final int? monitorCount;

  const DisplayInfo({
    required this.currentRate,
    required this.maxRate,
    required this.minRate,
    required this.supportedRates,
    required this.isVariableRefreshRate,
    required this.engineTargetRate,
    this.iosProMotionEnabled,
    this.androidApiLevel,
    this.isLowPowerMode,
    required this.thermalState,
    this.hasAdaptiveRefreshRate,
    this.displayServer,
    this.monitorCount,
  });

  factory DisplayInfo.fromMessage(DisplayInfoMessage msg) {
    return DisplayInfo(
      currentRate: msg.currentRate ?? 60.0,
      maxRate: msg.maxRate ?? 60.0,
      minRate: msg.minRate ?? 60.0,
      supportedRates: msg.supportedRates?.whereType<double>().toList() ?? const [60.0],
      isVariableRefreshRate: msg.isVariableRefreshRate ?? false,
      engineTargetRate: msg.engineTargetRate ?? 60.0,
      iosProMotionEnabled: msg.iosProMotionEnabled,
      androidApiLevel: msg.androidApiLevel,
      isLowPowerMode: msg.isLowPowerMode,
      thermalState: ThermalState.fromIndex(msg.thermalStateIndex),
      hasAdaptiveRefreshRate: msg.hasAdaptiveRefreshRate,
      displayServer: msg.displayServer,
      monitorCount: msg.monitorCount,
    );
  }

  static const DisplayInfo fallback = DisplayInfo(
        currentRate: 60.0,
        maxRate: 60.0,
        minRate: 60.0,
        supportedRates: [60.0],
        isVariableRefreshRate: false,
        engineTargetRate: 60.0,
        thermalState: ThermalState.unknown,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DisplayInfo &&
          currentRate == other.currentRate &&
          maxRate == other.maxRate &&
          minRate == other.minRate &&
          isVariableRefreshRate == other.isVariableRefreshRate &&
          engineTargetRate == other.engineTargetRate &&
          thermalState == other.thermalState &&
          isLowPowerMode == other.isLowPowerMode;

  @override
  int get hashCode => Object.hash(currentRate, maxRate, minRate,
      isVariableRefreshRate, engineTargetRate, thermalState, isLowPowerMode);

  @override
  String toString() =>
      'DisplayInfo(currentRate: ${currentRate}Hz, maxRate: ${maxRate}Hz, '
      'thermalState: $thermalState, isLowPowerMode: $isLowPowerMode)';
}
