import 'package:openobserve_flutter_rum_web/src/o2_contexts.dart';
import 'package:openobserve_flutter_rum_web/src/o2_intake.dart';
import 'package:openobserve_flutter_rum_web/src/o2_logger.dart';
import 'package:openobserve_flutter_rum_web/src/o2_logs_configuration.dart';

/// `window.O2_LOGS`.
abstract class O2Logs extends O2Contexts {
  void init(O2Intake intake, O2LogsConfiguration configuration);

  /// Creates the logger [name], replacing any existing one.
  O2Logger createLogger(
    String name, {
    O2LogStatus level = O2LogStatus.debug,
    Map<String, Object?>? context,
  });

  /// The logger created by [createLogger], or `null`.
  O2Logger? getLogger(String name);
}
