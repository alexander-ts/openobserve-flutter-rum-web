import 'dart:js_interop';

import 'package:openobserve_flutter_rum_web/src/web/js_o2_contexts.dart';

/// `window.O2_RUM`, or `null` if the RUM script is not loaded.
@JS('O2_RUM')
external JsO2Rum? get o2Rum;

/// OpenObserve Browser RUM SDK.
extension type JsO2Rum._(JSObject _) implements JsO2Contexts {
  external void init(JSObject options);
  external JSObject? getInternalContext();
  external void stopSession();
  external void startView(JSObject options);
  external void setViewName(String name);
  external void setViewContext(JSObject context);
  external void setViewContextProperty(String key, JSAny? value);
  external JSAny? getViewContext();
  external void setViewLoadingTime();
  external void addTiming(String name, [int time]);
  external void addError(JSAny? error, JSAny? context);
  external void addAction(String name, JSAny? context);
  external void startAction(String name, JSObject options);
  external void stopAction(String name, JSObject options);
  external void startResource(String url, JSObject options);
  external void stopResource(String url, JSObject options);
  external void addDurationVital(String name, JSObject options);
  external void startDurationVital(String name, JSObject options);
  external void stopDurationVital(String name, JSObject options);
}
