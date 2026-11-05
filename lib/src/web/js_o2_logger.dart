import 'dart:js_interop';

/// A Logs SDK logger.
extension type JsO2Logger._(JSObject _) implements JSObject {
  external void log(
    String message,
    JSAny? context,
    String status,
    JSAny? error,
  );
  external void setContext(JSObject context);
  external void setContextProperty(String key, JSAny? value);
  external void removeContextProperty(String key);
  external JSAny? getContext();
  external void clearContext();
  external void addTag(String key, [String value]);
  external void removeTagsWithKey(String key);
  external JSArray<JSString> getTags();
  external void setLevel(String level);
  external String getLevel();
}
