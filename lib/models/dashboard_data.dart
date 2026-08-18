class DashboardSnapshot {
  final VpsData? vps;
  final Map<String, AgentStat> agents;
  final DeepSeekData? deepseek;

  const DashboardSnapshot({
    required this.vps,
    required this.agents,
    required this.deepseek,
  });

  factory DashboardSnapshot.fromJson(Map<String, dynamic> json) {
    final rawVps = json['vps'];
    final rawAgents = json['agents'];
    final rawDeepseek = json['deepseek'];
    return DashboardSnapshot(
      vps: rawVps is Map
          ? VpsData.fromJson(Map<String, dynamic>.from(rawVps))
          : null,
      agents: rawAgents is Map
          ? rawAgents.map(
              (key, value) => MapEntry(
                key.toString(),
                value is Map
                    ? AgentStat.fromJson(Map<String, dynamic>.from(value))
                    : const AgentStat(),
              ),
            )
          : const {},
      deepseek: rawDeepseek is Map
          ? DeepSeekData.fromJson(Map<String, dynamic>.from(rawDeepseek))
          : null,
    );
  }
}

class VpsData {
  final double cpuPct;
  final double cpuLoad;
  final double memPct;
  final double memUsedMb;
  final double memTotalMb;
  final double diskPct;
  final double diskUsedGb;
  final double diskTotalGb;
  final int uptimeSeconds;

  const VpsData({
    required this.cpuPct,
    required this.cpuLoad,
    required this.memPct,
    required this.memUsedMb,
    required this.memTotalMb,
    required this.diskPct,
    required this.diskUsedGb,
    required this.diskTotalGb,
    required this.uptimeSeconds,
  });

  factory VpsData.fromJson(Map<String, dynamic> json) => VpsData(
        cpuPct: _double(json['cpu_pct']),
        cpuLoad: _double(json['cpu_load']),
        memPct: _double(json['mem_pct']),
        memUsedMb: _double(json['mem_used_mb']),
        memTotalMb: _double(json['mem_total_mb']),
        diskPct: _double(json['disk_pct']),
        diskUsedGb: _double(json['disk_used_gb']),
        diskTotalGb: _double(json['disk_total_gb']),
        uptimeSeconds: _int(json['uptime_s']),
      );
}

class AgentStat {
  final int total;
  final int completed;
  final int failed;
  final String lastSeen;

  const AgentStat({
    this.total = 0,
    this.completed = 0,
    this.failed = 0,
    this.lastSeen = '',
  });

  factory AgentStat.fromJson(Map<String, dynamic> json) => AgentStat(
        total: _int(json['total']),
        completed: _int(json['completed']),
        failed: _int(json['failed']),
        lastSeen: json['last_seen']?.toString() ?? '',
      );
}

class DeepSeekData {
  final bool configured;
  final bool available;
  final double balance;
  final String currency;
  final double todayUsed;

  const DeepSeekData({
    required this.configured,
    required this.available,
    required this.balance,
    required this.currency,
    required this.todayUsed,
  });

  factory DeepSeekData.fromJson(Map<String, dynamic> json) => DeepSeekData(
        configured: json['configured'] == true,
        available: json['is_available'] == true,
        balance: _double(json['total_balance']),
        currency: json['currency']?.toString() ?? 'USD',
        todayUsed: _double(json['today_used']),
      );
}

class ProviderBalancesResponse {
  final List<ProviderBalance> providers;
  final bool fresh;
  final int? ageSeconds;

  const ProviderBalancesResponse({
    required this.providers,
    required this.fresh,
    required this.ageSeconds,
  });

  factory ProviderBalancesResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['providers'];
    return ProviderBalancesResponse(
      providers: raw is List
          ? raw
              .whereType<Map>()
              .map((item) => ProviderBalance.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .toList()
          : const [],
      fresh: json['fresh'] == true,
      ageSeconds: json['age_seconds'] == null ? null : _int(json['age_seconds']),
    );
  }

  ProviderBalance? named(String providerName) {
    for (final provider in providers) {
      if (provider.provider.toLowerCase() == providerName.toLowerCase()) {
        return provider;
      }
    }
    return null;
  }
}

class ProviderBalance {
  final String provider;
  final double balance;
  final String unit;
  final double? usagePercent;
  final String status;

  const ProviderBalance({
    required this.provider,
    required this.balance,
    required this.unit,
    required this.usagePercent,
    required this.status,
  });

  factory ProviderBalance.fromJson(Map<String, dynamic> json) => ProviderBalance(
        provider: json['provider']?.toString() ?? '',
        balance: _double(json['balance']),
        unit: json['balance_unit']?.toString() ?? '',
        usagePercent: json['usage_percent'] == null
            ? null
            : _double(json['usage_percent']),
        status: json['status']?.toString() ?? '',
      );
}

double _double(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

int _int(dynamic value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
