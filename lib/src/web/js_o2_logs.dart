import 'dart:js_interop';

import 'package:openobserve_flutter_rum_web/src/web/js_o2_contexts.dart';
import 'package:openobserve_flutter_rum_web/src/web/js_o2_logger.dart';

/// `window.O2_LOGS`, or `null` if the Logs script is not loaded.
@JS('O2_LOGS')
external JsO2Logs? get o2Logs;

/// OpenObserve Browser Logs SDK.
extension type JsO2Logs._(JSObject _) implements JsO2Contexts {
  external void init(JSObject options);
  external JsO2Logger createLogger(String name, JSObject options);
  external JsO2Logger? getLogger(String name);
}
