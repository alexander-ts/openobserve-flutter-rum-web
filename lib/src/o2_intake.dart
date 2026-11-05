import 'package:meta/meta.dart';

/// OpenObserve connection settings shared by RUM and Logs.
@immutable
final class O2Intake {
  const O2Intake({
    required this.site,
    required this.clientToken,
    required this.service,
    required this.env,
    this.version,
    this.organizationIdentifier = 'default',
    this.apiVersion = 'v1',
    this.insecureHttp = false,
  });

  /// `host[:port][/path]` without a scheme.
  final String site;
  final String clientToken;
  final String service;
  final String env;
  final String? version;
  final String organizationIdentifier;
  final String apiVersion;

  /// Send over plain HTTP rather than HTTPS.
  final bool insecureHttp;
}
