/// CLI detection result for a single provider (claude/gemini).
class CliStatus {
  const CliStatus({
    required this.provider,
    required this.installed,
    required this.loggedIn,
    this.version,
    this.path,
  });

  final String provider;
  final bool installed;
  final bool loggedIn;
  final String? version;
  final String? path;

  factory CliStatus.fromJson(String provider, Map<String, dynamic> json) {
    return CliStatus(
      provider: provider,
      installed: json['installed'] as bool? ?? false,
      loggedIn: json['logged_in'] as bool? ?? false,
      version: json['version'] as String?,
      path: json['path'] as String?,
    );
  }

  CliState get state {
    if (!installed) return CliState.notInstalled;
    if (!loggedIn) return CliState.loggedOut;
    return CliState.ready;
  }
}

enum CliState { notInstalled, loggedOut, ready }

class CliDetection {
  const CliDetection({required this.claude, required this.gemini});
  final CliStatus claude;
  final CliStatus gemini;

  bool get anyReady => claude.state == CliState.ready || gemini.state == CliState.ready;

  factory CliDetection.fromJson(Map<String, dynamic> json) {
    return CliDetection(
      claude: CliStatus.fromJson('claude', (json['claude'] as Map?)?.cast<String, dynamic>() ?? const {}),
      gemini: CliStatus.fromJson('gemini', (json['gemini'] as Map?)?.cast<String, dynamic>() ?? const {}),
    );
  }
}
