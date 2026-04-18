import 'dart:async';
import 'package:flutter/widgets.dart';

import 'generated/refresh_rate_api.g.dart';
import 'models/display_info.dart';
import 'models/enums.dart';
import 'refresh_rate_api_adapter.dart';
import 'verification/overlay_controller.dart';
import 'verification/refresh_rate_session.dart';

class RefreshRate {
  RefreshRate._();

  static RefreshRateApiAdapter _api = PigeonRefreshRateApiAdapter();
  static DisplayInfo _cachedInfo = DisplayInfo.fallback;
  static StreamController<DisplayInfo>? _changedController;
  static final _flutterApi = _RefreshRateFlutterApiImpl();

  // ── Test seam ──────────────────────────────────────────────────

  static void setApiForTesting(RefreshRateApiAdapter api) {
    _api = api;
  }

  static void clearApiForTesting() {
    _api = PigeonRefreshRateApiAdapter();
    _flutterApi._onChanged = null;
    RefreshRateFlutterApi.setUp(null);
    _changedController?.close();
    _changedController = null;
  }

  // ── Control ────────────────────────────────────────────────────

  static void enable() {
    _api.enable();
    _refreshInfo();
  }

  static void disable() {
    _api.disable();
    _refreshInfo();
  }

  static void preferMax() => _api.preferMax();

  static void preferDefault() => _api.preferDefault();

  static void matchContent(double fps) => _api.matchContent(fps);

  static void boost(Duration duration) =>
      _api.boost(duration.inMilliseconds);

  static void boostDuring(AnimationController controller) {
    late final void Function(AnimationStatus) statusListener;
    statusListener = (status) {
      if (status == AnimationStatus.forward ||
          status == AnimationStatus.reverse) {
        _api.boost(controller.duration?.inMilliseconds ?? 500);
      } else if (status == AnimationStatus.completed ||
                 status == AnimationStatus.dismissed) {
        controller.removeStatusListener(statusListener);
      }
    };
    controller.addStatusListener(statusListener);
  }

  static void category(RateCategory c) => _api.setCategory(c.index);

  static void setTouchBoost(bool enabled) => _api.setTouchBoost(enabled);

  // ── Verification overlays ──────────────────────────────────────

  static void showFPS() => OverlayController.instance.showFPS();
  static void showHz() => OverlayController.instance.showHz();
  static void showOverlay() => OverlayController.instance.showFull();
  static void hideOverlay() => OverlayController.instance.hide();
  static bool get isOverlayVisible => OverlayController.instance.isVisible;

  // ── Diagnostics ────────────────────────────────────────────────

  static DisplayInfo get info => _cachedInfo;

  static Future<DisplayInfo> refresh() async {
    final msg = await _api.getDisplayInfo();
    _cachedInfo = DisplayInfo.fromMessage(msg);
    return _cachedInfo;
  }

  static Stream<DisplayInfo> get onChanged {
    if (_changedController == null) {
      _changedController = StreamController<DisplayInfo>.broadcast();
      _flutterApi._onChanged = (info) {
        _cachedInfo = info;
        _changedController!.add(info);
      };
      RefreshRateFlutterApi.setUp(_flutterApi);
    }
    return _changedController!.stream;
  }

  static bool get isProMotionReady =>
      _cachedInfo.iosProMotionEnabled == true;

  static bool get isLowPowerMode =>
      _cachedInfo.isLowPowerMode ?? false;

  static ThermalState get thermalState => _cachedInfo.thermalState;

  // ── Benchmark sessions ─────────────────────────────────────────

  static RefreshRateSession startSession(String name) {
    return RefreshRateSession.create(name, _cachedInfo);
  }

  // ── Internal ───────────────────────────────────────────────────

  static void _refreshInfo() {
    void handle(DisplayInfoMessage msg) {
      _cachedInfo = DisplayInfo.fromMessage(msg);
    }
    void handleError(Object e) {
      assert(() {
        debugPrint('RefreshRate: _refreshInfo error: $e');
        return true;
      }());
    }

    try {
      final result = _api.getDisplayInfo();
      if (result is Future<DisplayInfoMessage>) {
        result.then(handle).catchError(handleError);
      } else {
        handle(result);
      }
    } catch (e) {
      handleError(e);
    }
  }
}

class _RefreshRateFlutterApiImpl extends RefreshRateFlutterApi {
  void Function(DisplayInfo)? _onChanged;

  @override
  void onDisplayInfoChanged(DisplayInfoMessage info) {
    _onChanged?.call(DisplayInfo.fromMessage(info));
  }
}
