import 'package:meta/meta.dart';

import 'package:openobserve_flutter_rum_web/src/o2_event.dart';

@immutable
final class O2LogsConfiguration {
  const O2LogsConfiguration({
    this.sessionSampleRate = 100,
    this.forwardErrorsToLogs = false,
    this.forwardConsoleLogs = const [],
    this.forwardReports = const [],
    this.beforeSend,
  });

  /// Percentage of sessions whose logs are sent, 0–100.
  final num sessionSampleRate;

  /// Forward uncaught JS errors and failed network requests as logs.
  ///
  /// Defaults to `false`, unlike the JS SDK, which defaults to `true`.
  final bool forwardErrorsToLogs;
  final List<O2ConsoleApi> forwardConsoleLogs;
  final List<O2ReportType> forwardReports;
  final O2BeforeSend? beforeSend;
}

/// `console` methods that the Logs SDK can forward as logs.
enum O2ConsoleApi { log, debug, info, warn, error }

/// Browser report types (Reporting API) that the Logs SDK can forward.
enum O2ReportType {
  intervention('intervention'),
  deprecation('deprecation'),
  cspViolation('csp_violation');

  const O2ReportType(this.jsName);

  final String jsName;
}
