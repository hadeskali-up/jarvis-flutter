import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/neo_card.dart';
import '../models/forex_position.dart';
import 'package:intl/intl.dart';

class ForexScreen extends StatelessWidget {
  final MT5PositionsResponse positions;

  const ForexScreen({super.key, required this.positions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.cream,
      appBar: AppBar(
        backgroundColor: NeoColors.orange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NeoColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'MT5 Positions',
          style: TextStyle(
            color: NeoColors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Total P&L Summary
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: positions.totalPnl >= 0
                    ? NeoColors.mintGreen
                    : const Color(0xFFFFE5E5),
                border: Border.all(color: NeoColors.black, width: 3),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: NeoColors.black,
                    offset: Offset(6, 6),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Total P&L',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${positions.totalPnl.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: positions.totalPnl >= 0
                          ? NeoColors.green
                          : NeoColors.red,
                    ),
                  ),
                ],
              ),
            ),

            // Positions List
            Expanded(
              child: positions.positions.isEmpty
                  ? const Center(
                      child: Text(
                        'No open MT5 positions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: positions.positions.length,
                itemBuilder: (context, index) {
                  final position = positions.positions[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: NeoCard(
                      backgroundColor: position.isProfitable
                          ? NeoColors.mintGreen
                          : const Color(0xFFFFE5E5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    position.symbol,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: position.isLong
                                          ? NeoColors.blue
                                          : NeoColors.orange,
                                      border: Border.all(
                                          color: NeoColors.black, width: 2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      position.type,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: NeoColors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: position.isProfitable
                                      ? NeoColors.green
                                      : NeoColors.red,
                                  border: Border.all(
                                      color: NeoColors.black, width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${position.pnlPct >= 0 ? '+' : ''}${position.pnlPct.toStringAsFixed(2)}%',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: NeoColors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow('Lots', position.volume.toStringAsFixed(2)),
                          _buildInfoRow('Open', '\$${position.priceOpen.toStringAsFixed(5)}'),
                          _buildInfoRow('Current', '\$${position.priceCurrent.toStringAsFixed(5)}'),
                          _buildInfoRow(
                            'P&L',
                            '\$${position.pnlUsd.toStringAsFixed(2)}',
                            color: position.isProfitable
                                ? NeoColors.green
                                : NeoColors.red,
                          ),
                          if (position.tp > 0)
                            _buildInfoRow('TP', '\$${position.tp.toStringAsFixed(5)}'),
                          if (position.sl > 0)
                            _buildInfoRow('SL', '\$${position.sl.toStringAsFixed(5)}'),
                          if (position.time.isNotEmpty)
                            _buildInfoRow('Opened', _formatTime(position.time)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color ?? NeoColors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      return DateFormat('MMM dd, HH:mm').format(dt);
    } catch (e) {
      return timestamp;
    }
  }
}
