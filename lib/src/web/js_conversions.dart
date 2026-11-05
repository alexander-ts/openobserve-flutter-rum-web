import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:openobserve_flutter_rum_web/src/o2_event.dart';
import 'package:openobserve_flutter_rum_web/src/o2_intake.dart';
import 'package:openobserve_flutter_rum_web/src/o2_rum_configuration.dart';
import 'package:openobserve_flutter_rum_web/src/web/js_error.dart';
import 'package:openobserve_flutter_rum_web/src/web/web_o2_event.dart';

/// [O2Intake] fields in the format of the RUM and Logs `init` options.
Map<String, Object?> intakeFields(O2Intake intake) => {
  'clientToken': intake.clientToken,
  'site': intake.site,
  'organizationIdentifier': intake.organizationIdentifier,
  'apiVersion': intake.apiVersion,
  'insecureHTTP': intake.insecureHttp,
  'service': intake.service,
  'env': intake.env,
  'version': ?intake.version,
  'source': 'flutter',
};

/// A JS object from [fields] (converted with `jsify`) and [js] (JS values).
JSObject jsObject(
  Map<String, Object?> fields, {
  Map<String, JSAny> js = const {},
}) {
  final object = JSObject();
  for (final MapEntry(:key, :value) in fields.entries) {
    object.setProperty(key.toJS, value.jsify());
  }
  for (final MapEntry(:key, :value) in js.entries) {
    object.setProperty(key.toJS, value);
  }
  return object;
}

/// A Dart map from a JS object, or an empty map if [value] is not an object.
Map<String, Object?> toDartMap(JSAny? value) => switch (value.dartify()) {
  final Map<Object?, Object?> map => {
    for (final MapEntry(:key, :value) in map.entries) '$key': value,
  },
  _ => {},
};

JSFunction jsUrlMatcher(O2UrlMatcher match) =>
    ((JSString url) => match(url.toDart).toJS).toJS;

JSFunction? jsBeforeSend(O2BeforeSend? beforeSend, {required bool isLog}) {
  if (beforeSend == null) return null;
  return ((JSObject event, [JSAny? _]) => beforeSend(
    WebO2Event(event, isLog: isLog),
  ).toJS).toJS;
}

/// The value passed to the SDK's `addError` and `logger.log` for a Dart error.
///
/// JSON-like values without a stack trace are passed as they are, so the SDK
/// reports them as `Provided "..."` the way it does for JS callers. Anything
/// else becomes a JS `Error` with the error's `toString()` as the message and
/// [stackTrace] as the stack. Without [stackTrace] the `Error` keeps the stack
/// it was created with, which ends at the call site. The `Error` keeps the
/// default name, because `runtimeType` is minified in release builds.
JSAny? jsError(Object error, StackTrace? stackTrace) {
  if (stackTrace == null &&
      (error is String ||
          error is num ||
          error is bool ||
          error is List ||
          error is Map)) {
    return error.jsify();
  }
  final object = JsError(error.toString());
  if (stackTrace != null) object.stack = stackTrace.toString();
  return object;
}
