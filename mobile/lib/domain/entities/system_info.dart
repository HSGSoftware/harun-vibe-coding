class SystemInfo {
  const SystemInfo({
    this.os = '',
    this.arch = '',
    this.cpu = 0,
    this.ramMb = 0,
    this.diskFreeGb = 0,
    this.goVersion = '',
    this.nodeVersion = '',
    this.pythonVersion = '',
    this.termuxVersion = '',
    this.cloudflaredVersion = '',
  });

  final String os;
  final String arch;
  final int cpu;
  final int ramMb;
  final int diskFreeGb;
  final String goVersion;
  final String nodeVersion;
  final String pythonVersion;
  final String termuxVersion;
  final String cloudflaredVersion;

  factory SystemInfo.fromJson(Map<String, dynamic> json) {
    return SystemInfo(
      os: json['os'] as String? ?? '',
      arch: json['arch'] as String? ?? '',
      cpu: (json['cpu'] as num?)?.toInt() ?? 0,
      ramMb: (json['ram_mb'] as num?)?.toInt() ?? 0,
      diskFreeGb: (json['disk_free_gb'] as num?)?.toInt() ?? 0,
      goVersion: json['go_version'] as String? ?? '',
      nodeVersion: json['node_version'] as String? ?? '',
      pythonVersion: json['python_version'] as String? ?? '',
      termuxVersion: json['termux_version'] as String? ?? '',
      cloudflaredVersion: json['cloudflared_version'] as String? ?? '',
    );
  }
}

class SystemStats {
  const SystemStats({
    this.cpuPercent = 0,
    this.ramUsedMb = 0,
    this.ramTotalMb = 0,
    this.batteryPercent = 0,
    this.batteryCharging = false,
    this.temperatureC = 0,
    this.uptimeSec = 0,
  });

  final double cpuPercent;
  final int ramUsedMb;
  final int ramTotalMb;
  final int batteryPercent;
  final bool batteryCharging;
  final double temperatureC;
  final int uptimeSec;

  factory SystemStats.fromJson(Map<String, dynamic> json) {
    return SystemStats(
      cpuPercent: (json['cpu_percent'] as num?)?.toDouble() ?? 0,
      ramUsedMb: (json['ram_used_mb'] as num?)?.toInt() ?? 0,
      ramTotalMb: (json['ram_total_mb'] as num?)?.toInt() ?? 0,
      batteryPercent: (json['battery_percent'] as num?)?.toInt() ?? 0,
      batteryCharging: json['battery_charging'] as bool? ?? false,
      temperatureC: (json['temperature_c'] as num?)?.toDouble() ?? 0,
      uptimeSec: (json['uptime_sec'] as num?)?.toInt() ?? 0,
    );
  }
}
