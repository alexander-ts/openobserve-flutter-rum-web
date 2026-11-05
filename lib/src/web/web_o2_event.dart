import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:openobserve_flutter_rum_web/src/o2_event.dart';

/// [O2Event] backed by a JS event object.
final class WebO2Event implements O2Event {
  WebO2Event(this._event, {required bool isLog}) : _isLog = isLog;

  final JSObject _event;
  final bool _isLog;

  @override
  String? get type => _isLog ? null : this['type'] as String?;

  @override
  Object? operator [](String path) {
    final (parent, key) = _parent(path);
    return parent?.getProperty<JSAny?>(key.toJS).dartify();
  }

  @override
  void operator []=(String path, Object? value) {
    final (parent, key) = _parent(path);
    parent?.setProperty(key.toJS, value.jsify());
  }

  /// The object that holds the last key of [path], or `null` if a key on the
  /// way is missing or not an object.
  ///
  /// Throws [ArgumentError] if [path] has an empty key, such as `''` or `a..b`.
  (JSObject?, String) _parent(String path) {
    final keys = path.split('.');
    if (keys.contains('')) {
      throw ArgumentError.value(path, 'path', 'Contains an empty key');
    }
    JSObject current = _event;
    for (final key in keys.take(keys.length - 1)) {
      final value = current.getProperty<JSAny?>(key.toJS);
      if (value == null || !value.typeofEquals('object')) {
        return (null, keys.last);
      }
      current = value as JSObject;
    }
    return (current, keys.last);
  }
}
