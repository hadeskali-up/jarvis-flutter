class MT5PositionsResponse {
  final List<MT5Position> positions;
  final int count;
  final double totalPnl;

  MT5PositionsResponse({
    required this.positions,
    required this.count,
    required this.totalPnl,
  });

  factory MT5PositionsResponse.fromJson(Map<String, dynamic> json) {
    return MT5PositionsResponse(
      positions: (json['positions'] as List?)
              ?.map((e) => MT5Position.fromJson(e))
              .toList() ??
          [],
      count: json['count'] ?? 0,
      totalPnl: (json['total_pnl'] ?? 0).toDouble(),
    );
  }
}

class MT5Position {
  final String pair;
  final String direction;
  final double lots;
  final double openPrice;
  final double currentPrice;
  final double pnlUsd;
  final double pnlPct;
  final double sl;
  final double tp;
  final String openTime;

  MT5Position({
    required this.pair,
    required this.direction,
    required this.lots,
    required this.openPrice,
    required this.currentPrice,
    required this.pnlUsd,
    required this.pnlPct,
    required this.sl,
    required this.tp,
    required this.openTime,
  });

  bool get isProfitable => pnlUsd >= 0;
  bool get isLong => direction.toUpperCase() == 'BUY';

  factory MT5Position.fromJson(Map<String, dynamic> json) {
    return MT5Position(
      pair: json['pair'] ?? '',
      direction: json['direction'] ?? '',
      lots: (json['lots'] ?? 0).toDouble(),
      openPrice: (json['open_price'] ?? 0).toDouble(),
      currentPrice: (json['current_price'] ?? 0).toDouble(),
      pnlUsd: (json['pnl_usd'] ?? 0).toDouble(),
      pnlPct: (json['pnl_pct'] ?? 0).toDouble(),
      sl: (json['sl'] ?? 0).toDouble(),
      tp: (json['tp'] ?? 0).toDouble(),
      openTime: json['open_time'] ?? '',
    );
  }
}
