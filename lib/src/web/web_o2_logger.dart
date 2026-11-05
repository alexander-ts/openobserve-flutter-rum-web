import 'dart:js_interop';

import 'package:openobserve_flutter_rum_web/src/o2_logger.dart';
import 'package:openobserve_flutter_rum_web/src/web/js_conversions.dart';
import 'package:openobserve_flutter_rum_web/src/web/js_o2_logger.dart';

/// [O2Logger] backed by a Logs SDK logger.
final class WebO2Logger extends O2Logger {
  WebO2Logger(this._js);

  final JsO2Logger _js;

  @override
  void log(
    String message, {
    O2LogStatus status = O2LogStatus.info,
    Map<String, Object?>? context,
    Object? error,
    StackTrace? stackTrace,
  }) => _js.log(
    message,
    context?.jsify(),
    status.name,
    error == null ? null : jsError(error, stackTrace),
  );

  @override
  void setContext(Map<String, Object?> context) =>
      _js.setContext(jsObject(context));

  @override
  void setContextProperty(String key, Object? value) =>
      _js.setContextProperty(key, value.jsify());

  @override
  void removeContextProperty(String key) => _js.removeContextProperty(key);

  @override
  Map<String, Object?> getContext() => toDartMap(_js.getContext());

  @override
  void clearContext() => _js.clearContext();

  @override
  void addTag(String key, [String? value]) =>
      value == null ? _js.addTag(key) : _js.addTag(key, value);

  @override
  void removeTagsWithKey(String key) => _js.removeTagsWithKey(key);

  @override
  List<String> getTags() => [
    for (final tag in _js.getTags().toDart) tag.toDart,
  ];

  @override
  void setLevel(O2LogStatus level) => _js.setLevel(level.name);

  @override
  O2LogStatus getLevel() =>
      O2LogStatus.values.asNameMap()[_js.getLevel()] ?? O2LogStatus.debug;
}
