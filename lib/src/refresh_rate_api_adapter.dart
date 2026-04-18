import 'dart:async';

import 'generated/refresh_rate_api.g.dart';

/// Abstract interface for the host API, used as the test seam.
///
/// The real implementation ([PigeonRefreshRateApiAdapter]) delegates to the
/// pigeon-generated [RefreshRateHostApi]. Tests implement this interface
/// directly with synchronous fakes — no await required.
abstract class RefreshRateApiAdapter {
  FutureOr<DisplayInfoMessage> getDisplayInfo();
  FutureOr<void> enable();
  FutureOr<void> disable();
  FutureOr<void> preferMax();
  FutureOr<void> preferDefault();
  FutureOr<void> matchContent(double fps);
  FutureOr<void> boost(int durationMs);
  FutureOr<void> setCategory(int categoryIndex);
  FutureOr<void> setTouchBoost(bool enabled);
  FutureOr<bool> isSupported();
}

/// Production implementation that delegates to the pigeon-generated channel.
class PigeonRefreshRateApiAdapter implements RefreshRateApiAdapter {
  final RefreshRateHostApi _pigeon;

  PigeonRefreshRateApiAdapter() : _pigeon = RefreshRateHostApi();

  @override
  Future<DisplayInfoMessage> getDisplayInfo() => _pigeon.getDisplayInfo();

  @override
  Future<void> enable() => _pigeon.enable();

  @override
  Future<void> disable() => _pigeon.disable();

  @override
  Future<void> preferMax() => _pigeon.preferMax();

  @override
  Future<void> preferDefault() => _pigeon.preferDefault();

  @override
  Future<void> matchContent(double fps) => _pigeon.matchContent(fps);

  @override
  Future<void> boost(int durationMs) => _pigeon.boost(durationMs);

  @override
  Future<void> setCategory(int categoryIndex) => _pigeon.setCategory(categoryIndex);

  @override
  Future<void> setTouchBoost(bool enabled) => _pigeon.setTouchBoost(enabled);

  @override
  Future<bool> isSupported() => _pigeon.isSupported();
}
