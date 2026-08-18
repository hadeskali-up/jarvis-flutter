import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis_flutter/models/dashboard_data.dart';
import 'package:jarvis_flutter/models/mt5_history.dart';

void main() {
  test('dashboard snapshot parses VPS, DeepSeek and agents', () {
    final snapshot = DashboardSnapshot.fromJson(jsonDecode('''{
      "vps": {
        "cpu_pct": 13.0,
        "cpu_load": 0.26,
        "mem_pct": 60.9,
        "mem_used_mb": 1199,
        "mem_total_mb": 1968,
        "disk_pct": 63.2,
        "disk_used_gb": 24.8,
        "disk_total_gb": 39.3,
        "uptime_s": 2541368
      },
      "agents": {
        "traderjoe": {"total": 139, "completed": 139, "failed": 0, "last_seen": "2026-08-04T00:03:24Z"}
      },
      "deepseek": {
        "configured": true,
        "is_available": true,
        "total_balance": "9.94",
        "currency": "USD",
        "today_used": "0.00"
      }
    }'''));

    expect(snapshot.vps?.cpuPct, 13);
    expect(snapshot.vps?.uptimeSeconds, 2541368);
    expect(snapshot.agents['traderjoe']?.completed, 139);
    expect(snapshot.deepseek?.balance, 9.94);
    expect(snapshot.deepseek?.available, isTrue);
  });

  test('provider balances parse amanAI and DeepSeek', () {
    final providers = ProviderBalancesResponse.fromJson(jsonDecode('''{
      "providers": [
        {"provider":"amanai","balance":900964526,"balance_unit":"credits","status":"active"},
        {"provider":"deepseek","balance":9.94,"balance_unit":"USD","status":"active"}
      ],
      "fresh": true,
      "age_seconds": 10
    }'''));

    expect(providers.named('amanai')?.balance, 900964526);
    expect(providers.named('deepseek')?.balance, 9.94);
    expect(providers.fresh, isTrue);
  });

  test('MT5 history parses MYT summaries and deal net PnL', () {
    final history = MT5HistoryResponse.fromJson(jsonDecode('''{
      "deals": [{
        "ticket": 636017173,
        "symbol": "XAUUSD",
        "type": "BUY",
        "entry": 1,
        "volume": 0.01,
        "price": 4419.61,
        "profit": 10.49,
        "commission": 0,
        "swap": 0,
        "fee": 0,
        "net_pnl": 10.49,
        "time": "2026-08-18T12:41:21",
        "comment": "[tp 4419.61]"
      }],
      "count": 1,
      "total": 817,
      "has_more": true,
      "total_pnl": 10.49,
      "summary": {
        "daily_pnl": 184.67,
        "all_time_pnl": -1648.04,
        "filtered_list_pnl": -1648.04,
        "today_myt": "2026-08-18"
      }
    }'''));

    expect(history.deals.single.netPnl, 10.49);
    expect(history.summary.dailyPnl, 184.67);
    expect(history.summary.allTimePnl, -1648.04);
    expect(history.summary.todayMyt, '2026-08-18');
    expect(history.total, 817);
    expect(history.fetchedPnl, 10.49);
  });
}
