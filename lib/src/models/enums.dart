enum RateCategory {
  none,
  low,
  normal,
  high;

  static RateCategory fromIndex(int? index) {
    switch (index) {
      case 0: return none;
      case 1: return low;
      case 2: return normal;
      case 3: return high;
      default: return none;
    }
  }
}

enum ThermalState {
  nominal,
  fair,
  serious,
  critical,
  unknown;

  static ThermalState fromIndex(int? index) {
    switch (index) {
      case 0: return nominal;
      case 1: return fair;
      case 2: return serious;
      case 3: return critical;
      default: return unknown;
    }
  }
}

enum SessionState { idle, running, warmup, interrupted, completed }

enum ExclusionReason {
  appBackgrounded,
  appInactive,
  resumeWarmup,
  overlayOrFocusLoss,
  displayRateChanged,
  lowPowerModeChanged,
  thermalStateChanged,
}

enum Verdict { excellent, good, fair, poor, inconclusive }

enum Bottleneck { buildBound, rasterBound, displayCapped, powerLimited, thermalLimited, none }
