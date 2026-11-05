/// Unofficial Dart bindings for the OpenObserve Browser SDK (RUM and Logs).
///
/// Load `@openobserve/browser-rum-slim` and `@openobserve/browser-logs` in the
/// page, then call [createO2BrowserSdk].
library;

export 'src/create_o2_browser_sdk_stub.dart'
    if (dart.library.js_interop) 'src/create_o2_browser_sdk_web.dart';
export 'src/o2_browser_sdk.dart';
export 'src/o2_contexts.dart';
export 'src/o2_event.dart';
export 'src/o2_intake.dart';
export 'src/o2_logger.dart';
export 'src/o2_logs.dart';
export 'src/o2_logs_configuration.dart';
export 'src/o2_rum.dart';
export 'src/o2_rum_configuration.dart';
