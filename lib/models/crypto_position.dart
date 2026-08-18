class CryptoPositionsResponse {
  final List<CryptoPosition> positions;
  final int count;

  CryptoPositionsResponse({
    required this.positions,
    required this.count,
  });

  factory CryptoPositionsResponse.fromJson(Map<String, dynamic> json) {
    return CryptoPositionsResponse(
      positions: (json['positions'] as List?)
              ?.map((e) => CryptoPosition.fromJson(e))
              .toList() ??
          [],
      count: json['count'] ?? 0,
    );
  }
}

class CryptoPosition {
  final String symbol;
  final String rawSymbol;
  final double qty;
  final double entry;
  final double current;
  final double pnlUsd;
  final double pnlPct;
  final double tp;
  final double sl;
  final double tpProgress;
  final double slProgress;
  final double marketValue;

  CryptoPosition({
    required this.symbol,
    required this.rawSymbol,
    required this.qty,
    required this.entry,
    required this.current,
    required this.pnlUsd,
    required this.pnlPct,
    required this.tp,
    required this.sl,
    required this.tpProgress,
    required this.slProgress,
    required this.marketValue,
  });

  bool get isProfitable => pnlUsd >= 0;
  String get pnlColor => isProfitable ? 'green' : 'red';

  factory CryptoPosition.fromJson(Map<String, dynamic> json) {
    return CryptoPosition(
      symbol: json['symbol'] ?? '',
      rawSymbol: json['raw_symbol'] ?? '',
      qty: (json['qty'] ?? 0).toDouble(),
      entry: (json['entry'] ?? 0).toDouble(),
      current: (json['current'] ?? 0).toDouble(),
      pnlUsd: (json['pnl_usd'] ?? 0).toDouble(),
      pnlPct: (json['pnl_pct'] ?? 0).toDouble(),
      tp: (json['tp'] ?? 0).toDouble(),
      sl: (json['sl'] ?? 0).toDouble(),
      tpProgress: (json['tp_progress'] ?? 0).toDouble(),
      slProgress: (json['sl_progress'] ?? 0).toDouble(),
      marketValue: (json['market_value'] ?? 0).toDouble(),
    );
  }
}
