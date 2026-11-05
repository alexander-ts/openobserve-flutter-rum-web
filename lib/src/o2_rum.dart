import 'package:openobserve_flutter_rum_web/src/o2_contexts.dart';
import 'package:openobserve_flutter_rum_web/src/o2_intake.dart';
import 'package:openobserve_flutter_rum_web/src/o2_rum_configuration.dart';

/// IDs of the current RUM session and view.
typedef O2InternalContext = ({
  String? applicationId,
  String? sessionId,
  String? viewId,
});

/// `window.O2_RUM`.
abstract class O2Rum extends O2Contexts {
  /// Initializes RUM. Views are started manually with [startView]. Clicks are
  /// not tracked, because Flutter renders everything to a single canvas.
  void init(O2Intake intake, O2RumConfiguration configuration);

  /// IDs of the current session and view, or `null` before [init] or outside
  /// a tracked session.
  O2InternalContext? getInternalContext();

  /// Ends the current session; the next event starts a new one.
  void stopSession();

  void startView(String name, {Map<String, Object?>? context});
  void setViewName(String name);
  void setViewContext(Map<String, Object?> context);
  void setViewContextProperty(String key, Object? value);
  Map<String, Object?> getViewContext();

  /// Records the current time as the loading time of the current view.
  void setViewLoadingTime();

  /// Adds a named timing to the current view, at [time] or now.
  void addTiming(String name, {DateTime? time});

  void addError(
    Object error, {
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  });

  void addAction(String name, {Map<String, Object?>? context});

  /// Starts a long-running action. [actionKey] distinguishes concurrent
  /// actions with the same [name].
  void startAction(
    String name, {
    Map<String, Object?>? context,
    String? actionKey,
  });
  void stopAction(
    String name, {
    Map<String, Object?>? context,
    String? actionKey,
  });

  /// Starts a resource the SDK cannot see by itself, such as a WebSocket
  /// request. [resourceKey] distinguishes concurrent requests to the same [url].
  void startResource(
    String url, {
    String? method,
    O2ResourceType type = O2ResourceType.other,
    Map<String, Object?>? context,
    String? resourceKey,
  });
  void stopResource(
    String url, {
    int? statusCode,
    int? size,
    O2ResourceType type = O2ResourceType.other,
    Map<String, Object?>? context,
    String? resourceKey,
  });

  /// Adds a custom measured duration (vital).
  void addDurationVital(
    String name, {
    required DateTime start,
    required Duration duration,
    Map<String, Object?>? context,
    String? description,
  });
  void startDurationVital(
    String name, {
    Map<String, Object?>? context,
    String? description,
    String? vitalKey,
  });
  void stopDurationVital(
    String name, {
    Map<String, Object?>? context,
    String? description,
    String? vitalKey,
  });

  /// Not implemented.
  void addFeatureFlagEvaluation(String key, Object? value) =>
      throw UnimplementedError('addFeatureFlagEvaluation');

  /// Not implemented: the slim bundle has no Session Replay, and replay records
  /// the DOM, which cannot capture Flutter's canvas.
  void startSessionReplayRecording() =>
      throw UnimplementedError('startSessionReplayRecording');
  void stopSessionReplayRecording() =>
      throw UnimplementedError('stopSessionReplayRecording');
  String? getSessionReplayLink() =>
      throw UnimplementedError('getSessionReplayLink');

  /// Not implemented: feature operations are experimental. Use
  /// [startDurationVital] or [startAction] for long-running work.
  void startOperation(String name) =>
      throw UnimplementedError('startOperation');
  void succeedOperation(String name) =>
      throw UnimplementedError('succeedOperation');
  void failOperation(String name, String failureReason) =>
      throw UnimplementedError('failOperation');
}

/// Resource type for `O2Rum.startResource` and `O2Rum.stopResource`.
enum O2ResourceType {
  document,
  xhr,
  beacon,
  fetch,
  css,
  js,
  image,
  font,
  media,
  other,
  native,
}
