# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A pure Dart package (no Flutter dependency): unofficial bindings for the OpenObserve Browser SDK 0.4.3 (`@openobserve/browser-rum-slim` and `@openobserve/browser-logs`). The package does not bundle the SDK; the host page loads it and it exposes `window.O2_RUM` and `window.O2_LOGS`. Dart SDK `^3.10.0` (the code uses null-aware map elements like `'version': ?intake.version`).

## Commands

```shell
dart pub get
dart analyze
dart format .
dart test -p chrome                          # browser tests (the real implementation)
dart test                                    # VM tests (stub only)
dart test -p chrome test/o2_browser_sdk_web_test.dart --name '<substring>'   # single test
```

`example/` is a separate Flutter web app that depends on the package by path. Use the Flutter tool there: `cd example && flutter pub get && flutter analyze && flutter build web`.

Lints: `package:lints/recommended.yaml` plus `always_use_package_imports`, so every import inside `lib/` and `test/` uses `package:openobserve_flutter_rum_web/...`, never relative paths.

## Architecture

**Platform split via conditional export.** `lib/openobserve_flutter_rum_web.dart` exports `create_o2_browser_sdk_stub.dart` (returns `null`) or, when `dart.library.js_interop` exists, `create_o2_browser_sdk_web.dart`. The web factory also returns `null` if either `O2_RUM` or `O2_LOGS` is missing. Anything that imports `dart:js_interop` must stay under `lib/src/web/` and be reachable only from the web factory, so the package still compiles on the VM and on native platforms.

**Three layers:**
1. `lib/src/o2_*.dart`: the platform-independent public API (abstract classes `O2BrowserSdk`, `O2Rum`, `O2Logs`, `O2Logger`, `O2Contexts`, plus config/value types and `O2Event`). Only these are exported.
2. `lib/src/web/js_*.dart`: raw `@JS` extension types that mirror the JS SDK surface (`JsO2Rum`, `JsO2Logs`, `JsO2Logger`, `JsO2Contexts`, `JsError`).
3. `lib/src/web/web_o2_*.dart`: implementations of layer 1 on top of layer 2. `WebO2Contexts` is a mixin shared by `WebO2Rum` and `WebO2Logs`, because both JS objects have the same user/global-context methods.

`lib/src/web/js_conversions.dart` holds the shared Dart→JS helpers: `intakeFields` (common `init` options, always sends `source: 'flutter'`), `jsObject` (Dart map via `jsify` plus raw JS values such as functions), `toDartMap`, `jsBeforeSend`, `jsError` (wraps Dart errors and stack traces in a JS `Error`).

**Fixed behavior decisions:** RUM `init` always sets `trackViewsManually: true` and `trackUserInteractions: false`, because Flutter renders to a single canvas. Views must be started with `startView` (for example from a `NavigatorObserver`).

**Unimplemented SDK methods** (session replay, operations, feature flags, account context, tracking consent, logger handlers) are declared on the abstract classes with default bodies that throw `UnimplementedError`. To add one, declare/override it in the web class and add the `external` member to the matching `js_*.dart` extension type.

**`O2Event` (beforeSend)** addresses fields by dotted path (`view.url`, `context.city`). `type` is `null` for log entries; `WebO2Event` is created with `isLog` to make that distinction.

## Tests

- `test/o2_browser_sdk_stub_test.dart` is `@TestOn('!browser')`.
- `test/o2_browser_sdk_web_test.dart` is `@TestOn('browser')`. It installs fake `O2_RUM` / `O2_LOGS` objects on `globalContext` that record every call as `(methodName, args)` in `calls`, then asserts on the JS arguments. When you bind a new JS method, add its name to the fake object's method list in `setUp`, or the call fails at runtime.

## Releases

The package is consumed from git by tag (`ref: v0.1.0` in the README), with `publish_to: none`. When bumping the version, update `pubspec.yaml`, `CHANGELOG.md` and the README's `ref`. When changing the supported SDK version, update the script URLs in the README and the version mentioned in the `O2BrowserSdk` doc comment.
