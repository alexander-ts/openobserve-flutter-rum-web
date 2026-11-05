import 'package:openobserve_flutter_rum_web/src/o2_browser_sdk.dart';
import 'package:openobserve_flutter_rum_web/src/o2_logs.dart';
import 'package:openobserve_flutter_rum_web/src/o2_rum.dart';

final class WebO2BrowserSdk implements O2BrowserSdk {
  WebO2BrowserSdk({required this.rum, required this.logs});

  @override
  final O2Rum rum;

  @override
  final O2Logs logs;
}
