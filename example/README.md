# Example

A Flutter web app that reports views, actions, errors and logs to OpenObserve
with `openobserve_flutter_rum_web`.

- `web/index.html` loads the OpenObserve Browser SDK before the app starts.
- `O2RouteObserver` in `lib/main.dart` starts a RUM view on each navigation.
- Uncaught Flutter and Dart errors are reported with `rum.addError`.

Run it against your OpenObserve instance:

```shell
flutter run -d chrome \
  --dart-define=O2_SITE=localhost:5080 \
  --dart-define=O2_INSECURE_HTTP=true \
  --dart-define=O2_CLIENT_TOKEN=<RUM client token> \
  --dart-define=O2_APPLICATION_ID=<app id>
```

Without `O2_CLIENT_TOKEN` and `O2_APPLICATION_ID`, the app runs without telemetry.
