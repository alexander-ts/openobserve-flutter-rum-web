import 'package:openobserve_flutter_rum_web/src/o2_browser_sdk.dart';
import 'package:openobserve_flutter_rum_web/src/web/js_o2_logs.dart';
import 'package:openobserve_flutter_rum_web/src/web/js_o2_rum.dart';
import 'package:openobserve_flutter_rum_web/src/web/web_o2_browser_sdk.dart';
import 'package:openobserve_flutter_rum_web/src/web/web_o2_logs.dart';
import 'package:openobserve_flutter_rum_web/src/web/web_o2_rum.dart';

/// Returns the SDK backed by `window.O2_RUM` and `window.O2_LOGS`, which the
/// OpenObserve scripts define, or `null` if they are not loaded.
O2BrowserSdk? createO2BrowserSdk() {
  if ((o2Rum, o2Logs) case (final rum?, final logs?)) {
    return WebO2BrowserSdk(rum: WebO2Rum(rum), logs: WebO2Logs(logs));
  }
  return null;
}
