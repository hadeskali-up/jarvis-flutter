import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis_flutter/models/ai_usage.dart';
import 'package:jarvis_flutter/models/crypto_position.dart';
import 'package:jarvis_flutter/models/forex_position.dart';

void main() {
  test('AI usage parses the bridge contract', () {
    final model = AiUsageData.fromJson(jsonDecode('''{
      "ok": true,
      "balance": 19.25,
      "budget": 50,
      "spent": 30.75,
      "used_pct": 61.5,
      "currency": "USD",
      "usage_24h_spent": 2.4,
      "recent_requests": 18,
      "fetched_at": "2026-08-18T00:00:00Z"
    }'''));

    expect(model.ok, isTrue);
    expect(model.balance, 19.25);
    expect(model.budget, 50);
    expect(model.usedPct, 61.5);
    expect(model.recentRequests, 18);
  });

  test('AI usage failure contract is safe to parse', () {
    final model = AiUsageData.fromJson(jsonDecode('''{
      "ok": false,
      "error": "http 502",
      "fetched_at": "2026-08-18T00:00:00Z",
      "last_good": {"fetched_at": "2026-08-17T23:30:00Z"}
    }'''));

    expect(model.ok, isFalse);
    expect(model.error, 'http 502');
    expect(model.lastGoodAt, '2026-08-17T23:30:00Z');
  });

  test('crypto positions parse the bridge contract', () {
    final model = CryptoPositionsResponse.fromJson(jsonDecode('''{
      "positions": [{
        "symbol": "ETH/USD",
        "raw_symbol": "ETHUSD",
        "qty": 4.9,
        "entry": 1858.88,
        "current": 1899.39,
        "pnl_usd": 201.53,
        "pnl_pct": 2.18,
        "tp": 2230.65,
        "sl": 1672.99,
        "tp_progress": 10.9,
        "sl_progress": 0,
        "market_value": 9449.47
      }],
      "count": 1
    }'''));

    expect(model.count, 1);
    expect(model.positions.single.symbol, 'ETH/USD');
    expect(model.positions.single.pnlUsd, 201.53);
  });

  test('MT5 positions and account parse the bridge contract', () {
    final model = MT5PositionsResponse.fromJson(jsonDecode('''{
      "positions": [{
        "ticket": 99,
        "symbol": "XAUUSD",
        "type": "BUY",
        "volume": 0.01,
        "price_open": 4400.1,
        "price_current": 4410.2,
        "sl": 4390,
        "tp": 4420,
        "profit": 10.1,
        "swap": -0.2,
        "pnl_pct": 1.3,
        "time": "2026-08-18T12:00:00",
        "comment": "test"
      }],
      "count": 1,
      "total_pnl": 10.1,
      "last_updated": "2026-08-18T12:00:01",
      "account": {
        "login": 17252282,
        "balance": 2498.28,
        "equity": 2508.38,
        "currency": "USD",
        "server": "Headway-Real",
        "leverage": 200
      }
    }'''));

    expect(model.positions.single.symbol, 'XAUUSD');
    expect(model.positions.single.type, 'BUY');
    expect(model.positions.single.pnlUsd, 10.1);
    expect(model.account.login, 17252282);
    expect(model.account.balance, 2498.28);
  });
}
