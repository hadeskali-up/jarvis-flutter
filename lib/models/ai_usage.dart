class AiUsageData {
  final bool ok;
  final double credit;
  final String error;

  AiUsageData({
    required this.ok,
    required this.credit,
    required this.error,
  });

  factory AiUsageData.fromJson(Map<String, dynamic> json) {
    return AiUsageData(
      ok: json['ok'] ?? false,
      credit: (json['credit'] ?? 0).toDouble(),
      error: json['error'] ?? '',
    );
  }
}
