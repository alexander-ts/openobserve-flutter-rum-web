import 'package:openobserve_flutter_rum_web/src/o2_logs.dart';
import 'package:openobserve_flutter_rum_web/src/o2_rum.dart';

/// Dart API for the OpenObserve Browser SDK (`@openobserve/browser-rum-slim` and
/// `@openobserve/browser-logs` 0.4.3).
///
/// Get an instance from [createO2BrowserSdk], which returns `null` on
/// platforms other than web.
///
/// SDK methods this package does not implement are declared and throw
/// [UnimplementedError].
abstract class O2BrowserSdk {
  O2Rum get rum;
  O2Logs get logs;
}
