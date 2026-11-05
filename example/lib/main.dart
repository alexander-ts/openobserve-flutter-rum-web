import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:openobserve_flutter_rum_web/openobserve_flutter_rum_web.dart';

/// The SDK, or `null` if it is not available or not configured.
final O2BrowserSdk? sdk = startTelemetry();

O2BrowserSdk? startTelemetry() {
  const clientToken = String.fromEnvironment('O2_CLIENT_TOKEN');
  const applicationId = String.fromEnvironment('O2_APPLICATION_ID');
  if (clientToken.isEmpty || applicationId.isEmpty) return null;

  final sdk = createO2BrowserSdk();
  if (sdk == null) return null; // Not on web, or the scripts are not loaded.

  const intake = O2Intake(
    site: String.fromEnvironment('O2_SITE', defaultValue: 'localhost:5080'),
    clientToken: clientToken,
    service: 'rum-example',
    env: 'dev',
    version: '0.1.0',
    insecureHttp: bool.fromEnvironment('O2_INSECURE_HTTP'),
  );
  sdk.rum.init(intake, const O2RumConfiguration(applicationId: applicationId));
  sdk.logs.init(intake, const O2LogsConfiguration());
  return sdk;
}

void main() {
  final rum = sdk?.rum;
  if (rum != null) {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      rum.addError(details.exception, stackTrace: details.stack);
    };
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      rum.addError(error, stackTrace: stackTrace);
      return true;
    };
  }
  runApp(const ExampleApp());
}

/// Starts a RUM view whenever the visible route changes.
///
/// Flutter renders to a single canvas, so the SDK cannot detect navigation by
/// itself. Name your routes so that views are named in OpenObserve.
class O2RouteObserver extends RouteObserver<PageRoute<Object?>> {
  O2RouteObserver(this.rum);

  final O2Rum rum;

  void _startView(Route<Object?>? route) {
    if (route is! PageRoute) return;
    rum.startView(route.settings.name ?? 'unnamed');
  }

  @override
  void didPush(Route<Object?> route, Route<Object?>? previousRoute) {
    super.didPush(route, previousRoute);
    _startView(route);
  }

  @override
  void didPop(Route<Object?> route, Route<Object?>? previousRoute) {
    super.didPop(route, previousRoute);
    _startView(previousRoute);
  }

  @override
  void didReplace({Route<Object?>? newRoute, Route<Object?>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _startView(newRoute);
  }
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final rum = sdk?.rum;
    return MaterialApp(
      title: 'OpenObserve RUM example',
      navigatorObservers: [?(rum == null ? null : O2RouteObserver(rum))],
      initialRoute: '/',
      routes: {
        '/': (_) => const HomePage(),
        '/details': (_) => const DetailsPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final logger = sdk?.logs.createLogger('example');
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            if (sdk == null)
              const Text('Telemetry is off: see example/README.md.'),
            FilledButton(
              onPressed: () {
                // Clicks are not tracked automatically, so record them.
                sdk?.rum.addAction('open_details');
                Navigator.pushNamed(context, '/details');
              },
              child: const Text('Open details'),
            ),
            OutlinedButton(
              onPressed: () => logger?.info('hello', context: {'from': 'home'}),
              child: const Text('Send a log'),
            ),
            OutlinedButton(
              onPressed: () => throw StateError('Example error'),
              child: const Text('Throw an error'),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: const Center(child: Text('Go back to start the home view again.')),
    );
  }
}
