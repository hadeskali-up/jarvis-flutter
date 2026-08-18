class MT5PositionsResponse {
  final List<MT5Position> positions;
  final int count;
  final double totalPnl;
  final String lastUpdated;
  final MT5Account account;

  const MT5PositionsResponse({
    required this.positions,
    required this.count,
    required this.totalPnl,
    required this.lastUpdated,
    required this.account,
  });

  factory MT5PositionsResponse.fromJson(Map<String, dynamic> json) {
    final rawPositions = json['positions'];
    final rawAccount = json['account'];
    return MT5PositionsResponse(
      positions: rawPositions is List
          ? rawPositions
              .whereType<Map>()
              .map((item) => MT5Position.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .toList()
          : const [],
      count: _asInt(json['count']),
      totalPnl: _asDouble(json['total_pnl']),
      lastUpdated: json['last_updated']?.toString() ?? '',
      account: rawAccount is Map
          ? MT5Account.fromJson(Map<String, dynamic>.from(rawAccount))
          : const MT5Account(),
    );
  }
}

class MT5Account {
  final int login;
  final double balance;
  final double equity;
  final double margin;
  final double marginFree;
  final double? marginLevel;
  final double profit;
  final String currency;
  final String server;
  final int leverage;
  final String name;
  final String company;

  const MT5Account({
    this.login = 0,
    this.balance = 0,
    this.equity = 0,
    this.margin = 0,
    this.marginFree = 0,
    this.marginLevel,
    this.profit = 0,
    this.currency = 'USD',
    this.server = '',
    this.leverage = 0,
    this.name = '',
    this.company = '',
  });

  factory MT5Account.fromJson(Map<String, dynamic> json) => MT5Account(
        login: _asInt(json['login']),
        balance: _asDouble(json['balance']),
        equity: _asDouble(json['equity']),
        margin: _asDouble(json['margin']),
        marginFree: _asDouble(json['margin_free']),
        marginLevel: json['margin_level'] == null
            ? null
            : _asDouble(json['margin_level']),
        profit: _asDouble(json['profit']),
        currency: json['currency']?.toString() ?? 'USD',
        server: json['server']?.toString() ?? '',
        leverage: _asInt(json['leverage']),
        name: json['name']?.toString() ?? '',
        company: json['company']?.toString() ?? '',
      );
}

class MT5Position {
  final int ticket;
  final String symbol;
  final String type;
  final double volume;
  final double priceOpen;
  final double priceCurrent;
  final double pnlUsd;
  final double pnlPct;
  final double sl;
  final double tp;
  final double swap;
  final String time;
  final String comment;

  const MT5Position({
    required this.ticket,
    required this.symbol,
    required this.type,
    required this.volume,
    required this.priceOpen,
    required this.priceCurrent,
    required this.pnlUsd,
    required this.pnlPct,
    required this.sl,
    required this.tp,
    required this.swap,
    required this.time,
    required this.comment,
  });

  bool get isProfitable => pnlUsd >= 0;
  bool get isLong => type.toUpperCase() == 'BUY';

  factory MT5Position.fromJson(Map<String, dynamic> json) => MT5Position(
        ticket: _asInt(json['ticket']),
        symbol: json['symbol']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        volume: _asDouble(json['volume']),
        priceOpen: _asDouble(json['price_open']),
        priceCurrent: _asDouble(json['price_current']),
        pnlUsd: _asDouble(json['profit']),
        pnlPct: _asDouble(json['pnl_pct']),
        sl: _asDouble(json['sl']),
        tp: _asDouble(json['tp']),
        swap: _asDouble(json['swap']),
        time: json['time']?.toString() ?? '',
        comment: json['comment']?.toString() ?? '',
      );
}

double _asDouble(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

int _asInt(dynamic value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
