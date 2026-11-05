@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:test/test.dart';

import 'package:openobserve_flutter_rum_web/openobserve_flutter_rum_web.dart';

void main() {
  /// Calls to the fake `O2_RUM`, `O2_LOGS` and logger: method name and arguments.
  late List<(String, List<JSAny?>)> calls;

  JSObject fakeObject(List<String> methods, {JSObject? Function()? returns}) {
    final object = JSObject();
    for (final method in methods) {
      object.setProperty(
        method.toJS,
        (([JSAny? a, JSAny? b, JSAny? c, JSAny? d]) {
          calls.add((method, [a, b, c, d]));
          return returns?.call();
        }).toJS,
      );
    }
    return object;
  }

  const contextMethods = ['setUser', 'clearUser', 'setGlobalContextProperty'];

  setUp(() {
    calls = [];
    final logger = fakeObject(['log', 'addTag']);
    globalContext
      ..setProperty(
        'O2_RUM'.toJS,
        fakeObject([
          ...contextMethods,
          'init',
          'startView',
          'startResource',
          'stopSession',
          'addError',
        ]),
      )
      ..setProperty(
        'O2_LOGS'.toJS,
        fakeObject([
          ...contextMethods,
          'init',
          'createLogger',
        ], returns: () => logger),
      );
  });

  tearDown(() {
    globalContext
      ..delete('O2_RUM'.toJS)
      ..delete('O2_LOGS'.toJS);
  });

  Object? arg(String method, int index) =>
      calls.lastWhere((call) => call.$1 == method).$2[index].dartify();

  const intake = O2Intake(
    site: 'localhost:5080',
    clientToken: 'token',
    service: 'svc',
    env: 'test',
    insecureHttp: true,
  );

  test('returns null without the RUM script', () {
    globalContext.delete('O2_RUM'.toJS);
    expect(createO2BrowserSdk(), isNull);
  });

  test('returns null without the Logs script', () {
    globalContext.delete('O2_LOGS'.toJS);
    expect(createO2BrowserSdk(), isNull);
  });

  test('logs.init passes the intake and forwarding options', () {
    createO2BrowserSdk()!.logs.init(
      intake,
      const O2LogsConfiguration(
        forwardConsoleLogs: [O2ConsoleApi.warn],
        forwardReports: [O2ReportType.cspViolation],
      ),
    );
    expect(arg('init', 0), containsPair('site', 'localhost:5080'));
    expect(arg('init', 0), containsPair('source', 'flutter'));
    expect(arg('init', 0), containsPair('forwardErrorsToLogs', false));
    expect(arg('init', 0), containsPair('forwardConsoleLogs', ['warn']));
    expect(arg('init', 0), containsPair('forwardReports', ['csp_violation']));
  });

  test('getInternalContext reads the session and view IDs', () {
    final rum = globalContext.getProperty<JSObject>('O2_RUM'.toJS);
    rum.setProperty(
      'getInternalContext'.toJS,
      (() => {
        'application_id': 'app',
        'session_id': 's1',
        'view': {'id': 'v1', 'name': '/home'},
      }.jsify()).toJS,
    );
    expect(createO2BrowserSdk()!.rum.getInternalContext(), (
      applicationId: 'app',
      sessionId: 's1',
      viewId: 'v1',
    ));

    rum.setProperty('getInternalContext'.toJS, (() => null).toJS);
    expect(createO2BrowserSdk()!.rum.getInternalContext(), isNull);
  });

  test('addError without a stack trace keeps the JS stack', () {
    createO2BrowserSdk()!.rum.addError(StateError('bad'));
    final error = calls.lastWhere((c) => c.$1 == 'addError').$2[0]! as JSObject;
    expect(error.getProperty<JSString>('name'.toJS).toDart, 'Error');
    expect(
      error.getProperty<JSString>('message'.toJS).toDart,
      'Bad state: bad',
    );
    expect(error.getProperty<JSString>('stack'.toJS).toDart, isNotEmpty);
  });

  test('addError passes a String error as it is', () {
    createO2BrowserSdk()!.rum.addError('Payment failed', context: {'a': 1});
    expect(arg('addError', 0), 'Payment failed');
    expect(arg('addError', 1), {'a': 1});
  });

  test('addError wraps a String error with a stack trace', () {
    createO2BrowserSdk()!.rum.addError(
      'Payment failed',
      stackTrace: StackTrace.fromString('at pay'),
    );
    final error = calls.lastWhere((c) => c.$1 == 'addError').$2[0]! as JSObject;
    expect(
      error.getProperty<JSString>('message'.toJS).toDart,
      'Payment failed',
    );
    expect(error.getProperty<JSString>('stack'.toJS).toDart, 'at pay');
  });

  test('rum.init passes the intake and manual view tracking', () {
    createO2BrowserSdk()!.rum.init(
      intake,
      const O2RumConfiguration(applicationId: 'app'),
    );
    expect(arg('init', 0), containsPair('applicationId', 'app'));
    expect(arg('init', 0), containsPair('site', 'localhost:5080'));
    expect(arg('init', 0), containsPair('insecureHTTP', true));
    expect(arg('init', 0), containsPair('trackViewsManually', true));
    expect(arg('init', 0), containsPair('trackUserInteractions', false));
  });

  test('rum.init passes Dart URL matchers as JS functions', () {
    createO2BrowserSdk()!.rum.init(
      intake,
      O2RumConfiguration(
        applicationId: 'app',
        allowedTracingUrls: [
          O2TracingUrl(match: (url) => url.startsWith('https://api.')),
        ],
      ),
    );
    final options = calls.lastWhere((c) => c.$1 == 'init').$2[0]! as JSObject;
    final tracingUrl = options
        .getProperty<JSArray<JSObject>>('allowedTracingUrls'.toJS)
        .toDart
        .single;
    final match = tracingUrl.getProperty<JSFunction>('match'.toJS);
    expect(
      match.callAsFunction(null, 'https://api.example.com'.toJS).dartify(),
      isTrue,
    );
    expect(
      match.callAsFunction(null, 'https://cdn.example.com'.toJS).dartify(),
      isFalse,
    );
    expect(tracingUrl.getProperty<JSAny?>('propagatorTypes'.toJS).dartify(), [
      'tracecontext',
    ]);
  });

  test('beforeSend reads and writes event fields by path', () {
    createO2BrowserSdk()!.rum.init(
      intake,
      O2RumConfiguration(
        applicationId: 'app',
        beforeSend: (event) {
          event['view.url'] = 'redacted';
          return event.type != 'action';
        },
      ),
    );
    final options = calls.lastWhere((c) => c.$1 == 'init').$2[0]! as JSObject;
    final beforeSend = options.getProperty<JSFunction>('beforeSend'.toJS);
    final view = {
      'type': 'view',
      'view': {'url': 'https://app/?token=1'},
    }.jsify()!;
    expect(beforeSend.callAsFunction(null, view).dartify(), isTrue);
    expect(view.dartify(), containsPair('view', {'url': 'redacted'}));
    expect(
      beforeSend.callAsFunction(null, {'type': 'action'}.jsify()).dartify(),
      isFalse,
    );
  });

  test('beforeSend rejects paths with an empty key', () {
    late O2Event captured;
    createO2BrowserSdk()!.rum.init(
      intake,
      O2RumConfiguration(
        applicationId: 'app',
        beforeSend: (event) {
          captured = event;
          return true;
        },
      ),
    );
    final options = calls.lastWhere((c) => c.$1 == 'init').$2[0]! as JSObject;
    options
        .getProperty<JSFunction>('beforeSend'.toJS)
        .callAsFunction(null, {'type': 'view'}.jsify());
    expect(() => captured[''], throwsArgumentError);
    expect(() => captured['context..city'] = 1, throwsArgumentError);
    expect(captured['context.city'], isNull);
  });

  test('setUser sends id, name, email and extra properties', () {
    createO2BrowserSdk()!.rum.setUser(
      const O2User(id: '42', name: 'ivan', properties: {'role': 'admin'}),
    );
    expect(arg('setUser', 0), {'id': '42', 'name': 'ivan', 'role': 'admin'});
  });

  test('startResource passes the url and options', () {
    createO2BrowserSdk()!.rum.startResource(
      '/topic/orders',
      method: 'SUBSCRIBE',
      resourceKey: 'k1',
    );
    expect(arg('startResource', 0), '/topic/orders');
    expect(arg('startResource', 1), {
      'type': 'other',
      'method': 'SUBSCRIBE',
      'resourceKey': 'k1',
    });
  });

  test('logger.log passes status, context and a JS error with stack', () {
    final logger = createO2BrowserSdk()!.logs.createLogger('errors');
    logger.error(
      'boom',
      context: {'a': 1},
      error: StateError('bad'),
      stackTrace: StackTrace.fromString('at main'),
    );
    expect(arg('createLogger', 0), 'errors');
    expect(arg('log', 0), 'boom');
    expect(arg('log', 1), {'a': 1});
    expect(arg('log', 2), 'error');
    final error = calls.lastWhere((c) => c.$1 == 'log').$2[3]! as JSObject;
    expect(error.getProperty<JSString>('stack'.toJS).toDart, 'at main');
    expect(
      error.getProperty<JSString>('message'.toJS).toDart,
      'Bad state: bad',
    );
  });

  test('unused SDK methods throw UnimplementedError', () {
    final rum = createO2BrowserSdk()!.rum;
    expect(rum.startSessionReplayRecording, throwsUnimplementedError);
  });
}
