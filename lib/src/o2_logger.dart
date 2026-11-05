/// A logger created by `O2Logs.createLogger`.
abstract class O2Logger {
  /// Writes an entry at [status]. With [error], the entry includes the error
  /// type, message and stack trace.
  void log(
    String message, {
    O2LogStatus status = O2LogStatus.info,
    Map<String, Object?>? context,
    Object? error,
    StackTrace? stackTrace,
  });

  void debug(String message, {Map<String, Object?>? context}) =>
      log(message, status: O2LogStatus.debug, context: context);
  void info(String message, {Map<String, Object?>? context}) =>
      log(message, context: context);
  void warn(
    String message, {
    Map<String, Object?>? context,
    Object? error,
    StackTrace? stackTrace,
  }) => log(
    message,
    status: O2LogStatus.warn,
    context: context,
    error: error,
    stackTrace: stackTrace,
  );
  void error(
    String message, {
    Map<String, Object?>? context,
    Object? error,
    StackTrace? stackTrace,
  }) => log(
    message,
    status: O2LogStatus.error,
    context: context,
    error: error,
    stackTrace: stackTrace,
  );

  void setContext(Map<String, Object?> context);
  void setContextProperty(String key, Object? value);
  void removeContextProperty(String key);
  Map<String, Object?> getContext();
  void clearContext();

  /// Adds the tag `key:value`, or `key` without a value.
  void addTag(String key, [String? value]);
  void removeTagsWithKey(String key);
  List<String> getTags();

  /// Entries below [level] are dropped.
  void setLevel(O2LogStatus level);
  O2LogStatus getLevel();

  /// Not implemented: entries are always sent to OpenObserve (`http`).
  void setHandler(String handler) => throw UnimplementedError('setHandler');
  String getHandler() => throw UnimplementedError('getHandler');
}

/// The level (status) of a log entry.
enum O2LogStatus {
  ok,
  debug,
  info,
  notice,
  warn,
  error,
  critical,
  alert,
  emerg,
}
