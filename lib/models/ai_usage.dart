class AiUsageData {
  final bool ok;
  final double balance;
  final double budget;
  final double spent;
  final double usedPct;
  final String currency;
  final double usage24hSpent;
  final int recentRequests;
  final String fetchedAt;
  final String error;
  final String? lastGoodAt;

  const AiUsageData({
    required this.ok,
    required this.balance,
    required this.budget,
    required this.spent,
    required this.usedPct,
    required this.currency,
    required this.usage24hSpent,
    required this.recentRequests,
    required this.fetchedAt,
    required this.error,
    this.lastGoodAt,
  });

  factory AiUsageData.fromJson(Map<String, dynamic> json) {
    final lastGood = json['last_good'];
    return AiUsageData(
      ok: json['ok'] == true,
      balance: _asDouble(json['balance']),
      budget: _asDouble(json['budget']),
      spent: _asDouble(json['spent']),
      usedPct: _asDouble(json['used_pct']),
      currency: json['currency']?.toString() ?? 'USD',
      usage24hSpent: _asDouble(json['usage_24h_spent']),
      recentRequests: _asInt(json['recent_requests']),
      fetchedAt: json['fetched_at']?.toString() ?? '',
      error: json['error']?.toString() ?? '',
      lastGoodAt: lastGood is Map
          ? lastGood['fetched_at']?.toString()
          : null,
    );
  }

  static double _asDouble(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

  static int _asInt(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
}
