import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/neo_card.dart';
import '../models/crypto_position.dart';

class CryptoScreen extends StatelessWidget {
  final CryptoPositionsResponse positions;

  const CryptoScreen({Key? key, required this.positions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.cream,
      appBar: AppBar(
        backgroundColor: NeoColors.yellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NeoColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Crypto Positions',
          style: TextStyle(
            color: NeoColors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(24),
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
                        Text(
                          position.symbol,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
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
                            border: Border.all(color: NeoColors.black, width: 2),
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
                    _buildInfoRow('Quantity', position.qty.toStringAsFixed(4)),
                    _buildInfoRow('Entry', '\$${position.entry.toStringAsFixed(2)}'),
                    _buildInfoRow('Current', '\$${position.current.toStringAsFixed(2)}'),
                    _buildInfoRow(
                      'P&L',
                      '\$${position.pnlUsd.toStringAsFixed(2)}',
                      color: position.isProfitable ? NeoColors.green : NeoColors.red,
                    ),
                    if (position.tp > 0)
                      _buildInfoRow('TP', '\$${position.tp.toStringAsFixed(2)}'),
                    if (position.sl > 0)
                      _buildInfoRow('SL', '\$${position.sl.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            );
          },
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
}
