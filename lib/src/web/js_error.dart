import 'dart:js_interop';

/// JS `Error`.
@JS('Error')
extension type JsError._(JSObject _) implements JSObject {
  external factory JsError(String message);
  external set stack(String value);
}
