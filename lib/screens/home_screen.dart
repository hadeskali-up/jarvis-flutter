import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/neo_card.dart';
import '../widgets/neo_button.dart';
import '../services/ai_service.dart';
import '../services/crypto_service.dart';
import '../services/forex_service.dart';
import '../models/ai_usage.dart';
import '../models/crypto_position.dart';
import '../models/forex_position.dart';
import 'crypto_screen.dart';
import 'forex_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AiService _aiService = AiService();
  final CryptoService _cryptoService = CryptoService();
  final ForexService _forexService = ForexService();

  AiUsageData? _aiUsage;
  CryptoPositionsResponse? _cryptoPositions;
  MT5PositionsResponse? _mt5Positions;

  bool _isLoadingAi = true;
  bool _isLoadingCrypto = true;
  bool _isLoadingMt5 = true;

  String? _aiError;
  String? _cryptoError;
  String? _mt5Error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _loadAiUsage();
    _loadCryptoPositions();
    _loadMt5Positions();
  }

  Future<void> _loadAiUsage() async {
    try {
      final data = await _aiService.fetchUsage();
      if (mounted) {
        setState(() {
          _aiUsage = data;
          _isLoadingAi = false;
          _aiError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAi = false;
          _aiError = e.toString();
        });
      }
    }
  }

  Future<void> _loadCryptoPositions() async {
    try {
      final data = await _cryptoService.fetchPositions();
      if (mounted) {
        setState(() {
          _cryptoPositions = data;
          _isLoadingCrypto = false;
          _cryptoError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCrypto = false;
          _cryptoError = e.toString();
        });
      }
    }
  }

  Future<void> _loadMt5Positions() async {
    try {
      final data = await _forexService.fetchMT5Positions();
      if (mounted) {
        setState(() {
          _mt5Positions = data;
          _isLoadingMt5 = false;
          _mt5Error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMt5 = false;
          _mt5Error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.cream,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: NeoColors.yellow,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Hi, User',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: NeoColors.black,
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: NeoColors.yellow,
                        border: Border.all(color: NeoColors.black, width: 3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: NeoColors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Good day',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: NeoColors.black,
                  ),
                ),
                const SizedBox(height: 24),

                // AI Router Credit
                _buildAiCreditCard(),
                const SizedBox(height: 24),

                // Crypto Positions
                _buildCryptoSection(),
                const SizedBox(height: 24),

                // MT5 Positions
                _buildMt5Section(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAiCreditCard() {
    return NeoCard(
      backgroundColor: NeoColors.mintGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card, size: 24),
              const SizedBox(width: 8),
              const Text(
                'AI Router Credit',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoadingAi)
            const Center(child: CircularProgressIndicator())
          else if (_aiError != null)
            Text('Error: $_aiError',
                style: const TextStyle(color: NeoColors.red))
          else if (_aiUsage != null)
            Text(
              '\$${_aiUsage!.credit.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCryptoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Crypto Positions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!_isLoadingCrypto && _cryptoPositions != null)
              Text(
                '(${_cryptoPositions!.count})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingCrypto)
          const Center(child: CircularProgressIndicator())
        else if (_cryptoError != null)
          NeoCard(
            child: Text('Error: $_cryptoError',
                style: const TextStyle(color: NeoColors.red)),
          )
        else if (_cryptoPositions != null && _cryptoPositions!.positions.isEmpty)
          NeoCard(
            child: const Text('No positions'),
          )
        else if (_cryptoPositions != null)
          NeoCard(
            backgroundColor: NeoColors.teal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CryptoScreen(positions: _cryptoPositions!),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_cryptoPositions!.count} positions',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Text(
                      'Tap to view details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMt5Section() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'MT5 Positions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!_isLoadingMt5 && _mt5Positions != null)
              Text(
                '(${_mt5Positions!.count})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingMt5)
          const Center(child: CircularProgressIndicator())
        else if (_mt5Error != null)
          NeoCard(
            child: Text('Error: $_mt5Error',
                style: const TextStyle(color: NeoColors.red)),
          )
        else if (_mt5Positions != null && _mt5Positions!.positions.isEmpty)
          NeoCard(
            child: const Text('No positions'),
          )
        else if (_mt5Positions != null)
          NeoCard(
            backgroundColor: NeoColors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ForexScreen(positions: _mt5Positions!),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_mt5Positions!.count} positions',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total P&L: \$${_mt5Positions!.totalPnl.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _mt5Positions!.totalPnl >= 0
                        ? NeoColors.green
                        : NeoColors.red,
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Text(
                      'Tap to view details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
