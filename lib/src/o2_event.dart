/// Called before each event is sent. Return `false` to drop the event (RUM
/// views cannot be dropped). Only fields the SDK allows to be modified can be
/// changed (URLs, messages, `context` and so on).
typedef O2BeforeSend = bool Function(O2Event event);

/// A RUM event or log entry passed to [O2BeforeSend].
///
/// Fields are addressed by dotted path: `view.url`, `resource.url`,
/// `error.message`, `message`, `context.city`.
///
/// A path with an empty key, such as `''` or `context..city`, throws
/// [ArgumentError].
abstract interface class O2Event {
  /// The RUM event type (`view`, `action`, `error`, `resource`, `long_task`,
  /// `vital`), or `null` for a log entry.
  String? get type;

  Object? operator [](String path);

  /// Writes the value if the parent object of [path] exists.
  void operator []=(String path, Object? value);
}
