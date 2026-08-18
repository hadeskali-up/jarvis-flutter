import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/forex_position.dart';
import '../models/mt5_history.dart';
import '../services/mt5_history_service.dart';
import '../services/forex_service.dart';
import '../theme/colors.dart';
import '../widgets/neo_button.dart';
import '../widgets/neo_card.dart';

class ForexScreen extends StatefulWidget {
  final MT5PositionsResponse positions;

  const ForexScreen({super.key, required this.positions});

  @override
  State<ForexScreen> createState() => _ForexScreenState();
}

class _ForexScreenState extends State<ForexScreen> {
  final MT5HistoryService _historyService = MT5HistoryService();
  final ForexService _positionsService = ForexService();
  late MT5PositionsResponse _positions;
  MT5HistoryResponse? _history;
  String? _historyError;
  String? _positionsError;
  bool _historyLoading = true;

  @override
  void initState() {
    super.initState();
    _positions = widget.positions;
    _loadHistory();
  }

  Future<void> _loadPositions() async {
    try {
      final result = await _positionsService.fetchMT5Positions();
      if (!mounted) return;
      setState(() {
        _positions = result;
        _positionsError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _positionsError = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _loadPositions(),
      _loadHistory(),
    ]);
  }

  Future<void> _loadHistory() async {
    if (mounted) {
      setState(() {
        _historyLoading = true;
        _historyError = null;
      });
    }
    try {
      final result = await _historyService.fetchHistory(limit: 50);
      if (!mounted) return;
      setState(() {
        _history = result;
        _historyLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _historyError = error.toString().replaceFirst('Exception: ', '');
        _historyLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final positions = _positions;
    return Scaffold(
      backgroundColor: NeoColors.cream,
      appBar: AppBar(
        backgroundColor: NeoColors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NeoColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'MT5 Trading',
          style: TextStyle(color: NeoColors.black, fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshAll,
          color: NeoColors.orange,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              if (_positionsError != null) ...[
                NeoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _positionsError!,
                        style: const TextStyle(
                          color: NeoColors.red,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      NeoButton(
                        text: 'Retry positions',
                        icon: Icons.refresh,
                        onPressed: _loadPositions,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _OpenSummary(positions: positions),
              const SizedBox(height: 22),
              const _SectionTitle('Open Positions'),
              const SizedBox(height: 10),
              if (positions.positions.isEmpty)
                const NeoCard(child: Text('No open MT5 positions'))
              else
                ...positions.positions.map(_positionCard),
              const SizedBox(height: 22),
              const _SectionTitle('History & Summary P&L'),
              const SizedBox(height: 10),
              if (_historyLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ))
              else if (_historyError != null)
                NeoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _historyError!,
                        style: const TextStyle(color: NeoColors.red, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      NeoButton(text: 'Retry history', icon: Icons.refresh, onPressed: _loadHistory),
                    ],
                  ),
                )
              else if (_history != null) ...[
                _HistorySummary(history: _history!),
                const SizedBox(height: 16),
                if (_history!.deals.isEmpty)
                  const NeoCard(child: Text('No MT5 history available'))
                else
                  ..._history!.deals.map(_dealCard),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _positionCard(MT5Position position) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: NeoCard(
          backgroundColor: position.isProfitable ? NeoColors.mintGreen : const Color(0xFFFFE5E5),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${position.symbol}  ${position.type}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ),
                  Text(
                    '${position.pnlUsd >= 0 ? '+' : ''}\$${position.pnlUsd.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: position.isProfitable ? NeoColors.green : NeoColors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _infoRow('Volume', position.volume.toStringAsFixed(2)),
              _infoRow('Open', position.priceOpen.toStringAsFixed(5)),
              _infoRow('Current', position.priceCurrent.toStringAsFixed(5)),
              if (position.sl > 0) _infoRow('SL', position.sl.toStringAsFixed(5)),
              if (position.tp > 0) _infoRow('TP', position.tp.toStringAsFixed(5)),
            ],
          ),
        ),
      );

  Widget _dealCard(MT5Deal deal) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: NeoCard(
          backgroundColor: deal.netPnl >= 0 ? NeoColors.white : const Color(0xFFFFE5E5),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${deal.symbol}  ${deal.type}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ),
                  Text(
                    '${deal.netPnl >= 0 ? '+' : ''}\$${deal.netPnl.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: deal.netPnl >= 0 ? NeoColors.green : NeoColors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              _infoRow('Time', _formatTime(deal.time)),
              _infoRow('Volume', deal.volume.toStringAsFixed(2)),
              _infoRow('Price', deal.price.toStringAsFixed(5)),
              if (deal.comment.isNotEmpty) _infoRow('Comment', deal.comment),
            ],
          ),
        ),
      );

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      );

  String _formatTime(String timestamp) {
    try {
      return DateFormat('MMM dd, HH:mm').format(DateTime.parse(timestamp));
    } catch (_) {
      return timestamp;
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
      );
}

class _OpenSummary extends StatelessWidget {
  final MT5PositionsResponse positions;
  const _OpenSummary({required this.positions});

  @override
  Widget build(BuildContext context) => NeoCard(
        backgroundColor: NeoColors.orange,
        child: Column(
          children: [
            const Text('Account & Open P&L', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 7),
            Text(
              '${positions.totalPnl >= 0 ? '+' : ''}\$${positions.totalPnl.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            Text(
              '${positions.account.currency} ${positions.account.balance.toStringAsFixed(2)} balance  •  '
              '${positions.count} open  •  ${positions.account.server}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
}

class _HistorySummary extends StatelessWidget {
  final MT5HistoryResponse history;
  const _HistorySummary({required this.history});

  @override
  Widget build(BuildContext context) => NeoCard(
        backgroundColor: NeoColors.yellow,
        child: Column(
          children: [
            _summaryRow(
              'Fetched ${history.deals.length} trades P&L',
              history.fetchedPnl,
            ),
            const Divider(color: NeoColors.black),
            const Text(
              'Calculated only from the trades loaded on this page.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );

  Widget _summaryRow(String label, double value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
            Text(
              '${value >= 0 ? '+' : ''}\$${value.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: value >= 0 ? NeoColors.green : NeoColors.red,
              ),
            ),
          ],
        ),
      );
}
