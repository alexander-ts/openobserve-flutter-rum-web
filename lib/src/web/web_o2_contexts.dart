import 'dart:js_interop';

import 'package:openobserve_flutter_rum_web/src/o2_contexts.dart';
import 'package:openobserve_flutter_rum_web/src/web/js_conversions.dart';
import 'package:openobserve_flutter_rum_web/src/web/js_o2_contexts.dart';

/// [O2Contexts] backed by the RUM or Logs SDK object.
mixin WebO2Contexts on O2Contexts {
  JsO2Contexts get js;

  @override
  void setUser(O2User user) => js.setUser(
    jsObject({
      ...user.properties,
      'id': user.id,
      'name': ?user.name,
      'email': ?user.email,
    }),
  );

  @override
  void setUserProperty(String key, Object? value) =>
      js.setUserProperty(key, value.jsify());

  @override
  void removeUserProperty(String key) => js.removeUserProperty(key);

  @override
  Map<String, Object?> getUser() => toDartMap(js.getUser());

  @override
  void clearUser() => js.clearUser();

  @override
  void setGlobalContext(Map<String, Object?> context) =>
      js.setGlobalContext(jsObject(context));

  @override
  void setGlobalContextProperty(String key, Object? value) =>
      js.setGlobalContextProperty(key, value.jsify());

  @override
  void removeGlobalContextProperty(String key) =>
      js.removeGlobalContextProperty(key);

  @override
  Map<String, Object?> getGlobalContext() => toDartMap(js.getGlobalContext());

  @override
  void clearGlobalContext() => js.clearGlobalContext();
}
