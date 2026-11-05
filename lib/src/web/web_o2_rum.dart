import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:openobserve_flutter_rum_web/src/o2_intake.dart';
import 'package:openobserve_flutter_rum_web/src/o2_rum.dart';
import 'package:openobserve_flutter_rum_web/src/o2_rum_configuration.dart';
import 'package:openobserve_flutter_rum_web/src/web/js_conversions.dart';
import 'package:openobserve_flutter_rum_web/src/web/js_o2_rum.dart';
import 'package:openobserve_flutter_rum_web/src/web/web_o2_contexts.dart';

/// [O2Rum] backed by `window.O2_RUM`.
final class WebO2Rum extends O2Rum with WebO2Contexts {
  WebO2Rum(this.js);

  @override
  final JsO2Rum js;

  @override
  void init(O2Intake intake, O2RumConfiguration configuration) {
    js.init(
      jsObject(
        {
          ...intakeFields(intake),
          'applicationId': configuration.applicationId,
          'sessionSampleRate': configuration.sessionSampleRate,
          'traceSampleRate': configuration.traceSampleRate,
          'trackViewsManually': true,
          'trackUserInteractions': false,
          'trackResources': configuration.trackResources,
          'trackLongTasks': configuration.trackLongTasks,
        },
        js: {
          'allowedTracingUrls': [
            for (final url in configuration.allowedTracingUrls)
              jsObject(
                {
                  'propagatorTypes': [
                    for (final type in url.propagatorTypes) type.name,
                  ],
                },
                js: {'match': jsUrlMatcher(url.match)},
              ),
          ].toJS,
          'excludedActivityUrls': [
            for (final match in configuration.excludedActivityUrls)
              jsUrlMatcher(match),
          ].toJS,
          'beforeSend': ?jsBeforeSend(configuration.beforeSend, isLog: false),
        },
      ),
    );
  }

  @override
  O2InternalContext? getInternalContext() {
    final context = js.getInternalContext();
    if (context == null) return null;
    final view = context.getProperty<JSAny?>('view'.toJS);
    return (
      applicationId: context
          .getProperty<JSString?>('application_id'.toJS)
          ?.toDart,
      sessionId: context.getProperty<JSString?>('session_id'.toJS)?.toDart,
      viewId: view.isA<JSObject>()
          ? (view as JSObject).getProperty<JSAny?>('id'.toJS).dartify()
                as String?
          : null,
    );
  }

  @override
  void stopSession() => js.stopSession();

  @override
  void startView(String name, {Map<String, Object?>? context}) =>
      js.startView(jsObject({'name': name, 'context': ?context}));

  @override
  void setViewName(String name) => js.setViewName(name);

  @override
  void setViewContext(Map<String, Object?> context) =>
      js.setViewContext(jsObject(context));

  @override
  void setViewContextProperty(String key, Object? value) =>
      js.setViewContextProperty(key, value.jsify());

  @override
  Map<String, Object?> getViewContext() => toDartMap(js.getViewContext());

  @override
  void setViewLoadingTime() => js.setViewLoadingTime();

  @override
  void addTiming(String name, {DateTime? time}) => time == null
      ? js.addTiming(name)
      : js.addTiming(name, time.millisecondsSinceEpoch);

  @override
  void addError(
    Object error, {
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) => js.addError(jsError(error, stackTrace), context?.jsify());

  @override
  void addAction(String name, {Map<String, Object?>? context}) =>
      js.addAction(name, context?.jsify());

  @override
  void startAction(
    String name, {
    Map<String, Object?>? context,
    String? actionKey,
  }) => js.startAction(
    name,
    jsObject({'context': ?context, 'actionKey': ?actionKey}),
  );

  @override
  void stopAction(
    String name, {
    Map<String, Object?>? context,
    String? actionKey,
  }) => js.stopAction(
    name,
    jsObject({'context': ?context, 'actionKey': ?actionKey}),
  );

  @override
  void startResource(
    String url, {
    String? method,
    O2ResourceType type = O2ResourceType.other,
    Map<String, Object?>? context,
    String? resourceKey,
  }) => js.startResource(
    url,
    jsObject({
      'type': type.name,
      'method': ?method,
      'context': ?context,
      'resourceKey': ?resourceKey,
    }),
  );

  @override
  void stopResource(
    String url, {
    int? statusCode,
    int? size,
    O2ResourceType type = O2ResourceType.other,
    Map<String, Object?>? context,
    String? resourceKey,
  }) => js.stopResource(
    url,
    jsObject({
      'type': type.name,
      'statusCode': ?statusCode,
      'size': ?size,
      'context': ?context,
      'resourceKey': ?resourceKey,
    }),
  );

  @override
  void addDurationVital(
    String name, {
    required DateTime start,
    required Duration duration,
    Map<String, Object?>? context,
    String? description,
  }) => js.addDurationVital(
    name,
    jsObject({
      'startTime': start.millisecondsSinceEpoch,
      'duration': duration.inMilliseconds,
      'context': ?context,
      'description': ?description,
    }),
  );

  @override
  void startDurationVital(
    String name, {
    Map<String, Object?>? context,
    String? description,
    String? vitalKey,
  }) => js.startDurationVital(
    name,
    jsObject({
      'context': ?context,
      'description': ?description,
      'vitalKey': ?vitalKey,
    }),
  );

  @override
  void stopDurationVital(
    String name, {
    Map<String, Object?>? context,
    String? description,
    String? vitalKey,
  }) => js.stopDurationVital(
    name,
    jsObject({
      'context': ?context,
      'description': ?description,
      'vitalKey': ?vitalKey,
    }),
  );
}
