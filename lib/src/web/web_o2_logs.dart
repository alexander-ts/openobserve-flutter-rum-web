import 'package:openobserve_flutter_rum_web/src/o2_intake.dart';
import 'package:openobserve_flutter_rum_web/src/o2_logger.dart';
import 'package:openobserve_flutter_rum_web/src/o2_logs.dart';
import 'package:openobserve_flutter_rum_web/src/o2_logs_configuration.dart';
import 'package:openobserve_flutter_rum_web/src/web/js_conversions.dart';
import 'package:openobserve_flutter_rum_web/src/web/js_o2_logs.dart';
import 'package:openobserve_flutter_rum_web/src/web/web_o2_contexts.dart';
import 'package:openobserve_flutter_rum_web/src/web/web_o2_logger.dart';

/// [O2Logs] backed by `window.O2_LOGS`.
final class WebO2Logs extends O2Logs with WebO2Contexts {
  WebO2Logs(this.js);

  @override
  final JsO2Logs js;

  @override
  void init(O2Intake intake, O2LogsConfiguration configuration) {
    js.init(
      jsObject(
        {
          ...intakeFields(intake),
          'sessionSampleRate': configuration.sessionSampleRate,
          'forwardErrorsToLogs': configuration.forwardErrorsToLogs,
          'forwardConsoleLogs': [
            for (final api in configuration.forwardConsoleLogs) api.name,
          ],
          'forwardReports': [
            for (final report in configuration.forwardReports) report.jsName,
          ],
        },
        js: {
          'beforeSend': ?jsBeforeSend(configuration.beforeSend, isLog: true),
        },
      ),
    );
  }

  @override
  O2Logger createLogger(
    String name, {
    O2LogStatus level = O2LogStatus.debug,
    Map<String, Object?>? context,
  }) => WebO2Logger(
    js.createLogger(name, jsObject({'level': level.name, 'context': ?context})),
  );

  @override
  O2Logger? getLogger(String name) => switch (js.getLogger(name)) {
    final logger? => WebO2Logger(logger),
    null => null,
  };
}
