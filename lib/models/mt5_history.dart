class MT5HistoryResponse {
  final List<MT5Deal> deals;
  final int count;
  final int total;
  final double totalPnl;
  final bool hasMore;
  final MT5HistorySummary summary;

  const MT5HistoryResponse({
    required this.deals,
    required this.count,
    required this.total,
    required this.totalPnl,
    required this.hasMore,
    required this.summary,
  });

  factory MT5HistoryResponse.fromJson(Map<String, dynamic> json) {
    final rawDeals = json['deals'] ?? json['items'];
    final rawSummary = json['summary'];
    return MT5HistoryResponse(
      deals: rawDeals is List
          ? rawDeals
              .whereType<Map>()
              .map((item) => MT5Deal.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : const [],
      count: _int(json['count']),
      total: _int(json['total']),
      totalPnl: _double(json['total_pnl']),
      hasMore: json['has_more'] == true,
      summary: rawSummary is Map
          ? MT5HistorySummary.fromJson(Map<String, dynamic>.from(rawSummary))
          : const MT5HistorySummary(),
    );
  }
}

class MT5HistorySummary {
  final double dailyPnl;
  final double allTimePnl;
  final double filteredListPnl;
  final String todayMyt;

  const MT5HistorySummary({
    this.dailyPnl = 0,
    this.allTimePnl = 0,
    this.filteredListPnl = 0,
    this.todayMyt = '',
  });

  factory MT5HistorySummary.fromJson(Map<String, dynamic> json) =>
      MT5HistorySummary(
        dailyPnl: _double(json['daily_pnl']),
        allTimePnl: _double(json['all_time_pnl']),
        filteredListPnl: _double(json['filtered_list_pnl']),
        todayMyt: json['today_myt']?.toString() ?? '',
      );
}

class MT5Deal {
  final int ticket;
  final String symbol;
  final String type;
  final int entry;
  final double volume;
  final double price;
  final double profit;
  final double commission;
  final double swap;
  final double fee;
  final double netPnl;
  final String time;
  final String comment;

  const MT5Deal({
    required this.ticket,
    required this.symbol,
    required this.type,
    required this.entry,
    required this.volume,
    required this.price,
    required this.profit,
    required this.commission,
    required this.swap,
    required this.fee,
    required this.netPnl,
    required this.time,
    required this.comment,
  });

  factory MT5Deal.fromJson(Map<String, dynamic> json) => MT5Deal(
        ticket: _int(json['ticket']),
        symbol: json['symbol']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        entry: _int(json['entry']),
        volume: _double(json['volume']),
        price: _double(json['price']),
        profit: _double(json['profit']),
        commission: _double(json['commission']),
        swap: _double(json['swap']),
        fee: _double(json['fee']),
        netPnl: json['net_pnl'] == null
            ? _double(json['profit']) + _double(json['commission']) +
                _double(json['swap']) + _double(json['fee'])
            : _double(json['net_pnl']),
        time: json['time']?.toString() ?? '',
        comment: json['comment']?.toString() ?? '',
      );
}

double _double(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

int _int(dynamic value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
