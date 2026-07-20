/// Build and version information placeholder.
/// Integrate with package_info_plus or similar in a later sprint.
final class BuildInfo {
  const BuildInfo({required this.version, required this.buildNumber});

  final String version;
  final String buildNumber;

  static const unknown = BuildInfo(version: '0.0.0', buildNumber: '0');
}
