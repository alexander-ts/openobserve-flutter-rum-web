import 'package:meta/meta.dart';

/// User and global context, shared by RUM and Logs.
///
/// Context values must be JSON-compatible: `null`, `bool`, `num`, `String`,
/// and `List` or `Map` of those.
abstract class O2Contexts {
  void setUser(O2User user);
  void setUserProperty(String key, Object? value);
  void removeUserProperty(String key);
  Map<String, Object?> getUser();
  void clearUser();

  void setGlobalContext(Map<String, Object?> context);
  void setGlobalContextProperty(String key, Object? value);
  void removeGlobalContextProperty(String key);
  Map<String, Object?> getGlobalContext();
  void clearGlobalContext();

  /// Not implemented.
  void setAccount(String id, {String? name}) =>
      throw UnimplementedError('setAccount');
  void setAccountProperty(String key, Object? value) =>
      throw UnimplementedError('setAccountProperty');
  void removeAccountProperty(String key) =>
      throw UnimplementedError('removeAccountProperty');
  Map<String, Object?> getAccount() => throw UnimplementedError('getAccount');
  void clearAccount() => throw UnimplementedError('clearAccount');
  void setTrackingConsent(String consent) =>
      throw UnimplementedError('setTrackingConsent');
  void onReady(void Function() callback) => throw UnimplementedError('onReady');
  Map<String, Object?> getInitConfiguration() =>
      throw UnimplementedError('getInitConfiguration');
  void stop() => throw UnimplementedError('stop');
}

/// The user for `O2Contexts.setUser`.
@immutable
final class O2User {
  const O2User({
    required this.id,
    this.name,
    this.email,
    this.properties = const {},
  });

  final String id;
  final String? name;
  final String? email;

  /// Additional user fields (`usr.<key>`).
  final Map<String, Object?> properties;
}
