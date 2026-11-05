import 'package:meta/meta.dart';

import 'package:openobserve_flutter_rum_web/src/o2_event.dart';

@immutable
final class O2RumConfiguration {
  const O2RumConfiguration({
    required this.applicationId,
    this.sessionSampleRate = 100,
    this.traceSampleRate = 100,
    this.trackResources = true,
    this.trackLongTasks = true,
    this.allowedTracingUrls = const [],
    this.excludedActivityUrls = const [],
    this.beforeSend,
  });

  final String applicationId;

  /// Percentage of sessions that are tracked, 0–100.
  final num sessionSampleRate;

  /// Percentage of requests to [allowedTracingUrls] that are traced, 0–100.
  final num traceSampleRate;

  /// Automatically track fetch and XHR requests and loaded files.
  final bool trackResources;
  final bool trackLongTasks;
  final List<O2TracingUrl> allowedTracingUrls;

  /// Requests ignored when computing view loading time, such as long-lived
  /// connections.
  final List<O2UrlMatcher> excludedActivityUrls;
  final O2BeforeSend? beforeSend;
}

/// URL check for `O2RumConfiguration.allowedTracingUrls` and
/// `O2RumConfiguration.excludedActivityUrls`.
typedef O2UrlMatcher = bool Function(String url);

/// URLs whose requests get trace headers.
@immutable
final class O2TracingUrl {
  const O2TracingUrl({
    required this.match,
    this.propagatorTypes = const [O2PropagatorType.tracecontext],
  });

  final O2UrlMatcher match;
  final List<O2PropagatorType> propagatorTypes;
}

/// Trace header format for `O2TracingUrl`.
enum O2PropagatorType { tracecontext, b3, b3multi }
