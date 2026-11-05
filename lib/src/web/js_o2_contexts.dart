import 'dart:js_interop';

/// User and global context methods shared by `O2_RUM` and `O2_LOGS`.
extension type JsO2Contexts._(JSObject _) implements JSObject {
  external void setUser(JSObject user);
  external void setUserProperty(String key, JSAny? value);
  external void removeUserProperty(String key);
  external JSAny? getUser();
  external void clearUser();
  external void setGlobalContext(JSObject context);
  external void setGlobalContextProperty(String key, JSAny? value);
  external void removeGlobalContextProperty(String key);
  external JSAny? getGlobalContext();
  external void clearGlobalContext();
}
