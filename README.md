# openobserve_flutter_rum_web

Unofficial Dart bindings for the [OpenObserve](https://openobserve.ai) Browser
SDK (`@openobserve/browser-rum-slim` and `@openobserve/browser-logs`). It
covers RUM views, actions, errors, resources, vitals, user and global context,
`beforeSend` filtering, and named loggers.

This package is not affiliated with OpenObserve. It does not bundle the SDK;
your page loads it.

## Setup

Load the SDK in `web/index.html`, before the app starts:

```html
<script src="https://cdn.jsdelivr.net/npm/@openobserve/browser-logs@0.4.3/bundle/openobserve-logs.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@openobserve/browser-rum-slim@0.4.3/bundle/openobserve-rum-slim.js"></script>
```

Add the package from git:

```yaml
dependencies:
  openobserve_flutter_rum_web:
    git:
      url: https://github.com/alexander-ts/openobserve-flutter-rum-web.git
      ref: v0.1.0
```

## Usage

```dart
import 'package:openobserve_flutter_rum_web/openobserve_flutter_rum_web.dart';

void startTelemetry() {
  final sdk = createO2BrowserSdk();
  if (sdk == null) return; // Not on web, or the scripts are not loaded.

  const intake = O2Intake(
    site: 'o2.example.com',
    clientToken: '<RUM client token>',
    service: 'my-app',
    env: 'prod',
  );
  sdk.rum.init(intake, const O2RumConfiguration(applicationId: '<app id>'));
  sdk.logs.init(intake, const O2LogsConfiguration());

  sdk.rum.startView('/home');
  sdk.rum.setUser(const O2User(id: '42', name: 'ivan'));
  sdk.logs.createLogger('app').info('started');
}
```

`createO2BrowserSdk()` returns `null` on platforms other than web, so the same
code compiles everywhere.

Views are tracked manually and clicks are not tracked, because Flutter renders
to a single canvas. Start a view on each navigation, for example from a
`NavigatorObserver`. The [example](example) app does this and also reports
uncaught Flutter errors.

SDK methods that the package does not implement, such as session replay and
account context, are declared and throw `UnimplementedError`.

## Testing

```shell
dart test -p chrome
```

## License

Apache License 2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).
