import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/neo_card.dart';
import '../widgets/neo_button.dart';
import '../widgets/dashboard_sections.dart';
import '../services/ai_service.dart';
import '../services/crypto_service.dart';
import '../services/forex_service.dart';
import '../services/dashboard_service.dart';
import '../models/ai_usage.dart';
import '../models/crypto_position.dart';
import '../models/forex_position.dart';
import '../models/dashboard_data.dart';
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
  final DashboardService _dashboardService = DashboardService();

  AiUsageData? _aiUsage;
  CryptoPositionsResponse? _cryptoPositions;
  MT5PositionsResponse? _mt5Positions;
  DashboardSnapshot? _dashboard;
  ProviderBalancesResponse? _providerBalances;

  bool _isLoadingAi = true;
  bool _isLoadingCrypto = true;
  bool _isLoadingMt5 = true;

  String? _aiError;
  String? _cryptoError;
  String? _mt5Error;
  String? _dashboardError;
  String? _providerError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadAiUsage(),
      _loadCryptoPositions(),
      _loadMt5Positions(),
      _loadDashboard(),
      _loadProviderBalances(),
    ]);
  }

  Future<void> _loadDashboard() async {
    try {
      final data = await _dashboardService.fetchSnapshot();
      if (!mounted) return;
      setState(() {
        _dashboard = data;
        _dashboardError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _dashboardError = e.toString());
    }
  }

  Future<void> _loadProviderBalances() async {
    try {
      final data = await _dashboardService.fetchProviderBalances();
      if (!mounted) return;
      setState(() {
        _providerBalances = data;
        _providerError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _providerError = e.toString());
    }
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

  Widget _errorState(String message, Future<void> Function() retry) {
    final cleaned = message.replaceFirst('Exception: ', '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cleaned,
          style: const TextStyle(
            color: NeoColors.red,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        NeoButton(
          text: 'Retry',
          icon: Icons.refresh,
          onPressed: () => retry(),
        ),
      ],
    );
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
                const Text(
                  'JARVIS DASHBOARD',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: NeoColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Systems, providers, agents & trading',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: NeoColors.black,
                  ),
                ),
                const SizedBox(height: 24),

                if (_dashboardError != null && _dashboard == null)
                  NeoCard(child: _errorState(_dashboardError!, _loadDashboard))
                else if (_dashboard == null)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  if (_dashboard!.vps != null) ...[
                    const DashboardSectionTitle(
                      title: 'VPS Health',
                      icon: Icons.dns_outlined,
                    ),
                    VpsHealthCard(data: _dashboard!.vps!),
                    const SizedBox(height: 24),
                  ],
                  const DashboardSectionTitle(
                    title: 'AI Provider Balances',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                  ProviderBalanceCards(
                    balances: _providerBalances,
                    deepseekFallback: _dashboard!.deepseek,
                  ),
                  if (_providerError != null) ...[
                    const SizedBox(height: 10),
                    _errorState(_providerError!, _loadProviderBalances),
                  ],
                  const SizedBox(height: 24),
                  const DashboardSectionTitle(
                    title: 'Agent Status',
                    icon: Icons.hub_outlined,
                  ),
                  AgentStatusCard(agents: _dashboard!.agents),
                  const SizedBox(height: 24),
                ],

                const DashboardSectionTitle(
                  title: 'AI Router Credit',
                  icon: Icons.credit_card,
                ),
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
            _errorState(_aiError!, _loadAiUsage)
          else if (_aiUsage != null && !_aiUsage!.ok)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Router balance temporarily unavailable',
                  style: TextStyle(
                    color: NeoColors.red,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _aiUsage!.error.isEmpty ? 'Provider did not return a balance.' : _aiUsage!.error,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (_aiUsage!.lastGoodAt != null) ...[
                  const SizedBox(height: 4),
                  Text('Last successful fetch: ${_aiUsage!.lastGoodAt}'),
                ],
                const SizedBox(height: 12),
                NeoButton(text: 'Retry credit', icon: Icons.refresh, onPressed: _loadAiUsage),
              ],
            )
          else if (_aiUsage != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${_aiUsage!.balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Spent \$${_aiUsage!.spent.toStringAsFixed(2)} of '
                  '\$${_aiUsage!.budget.toStringAsFixed(2)} '
                  '(${_aiUsage!.usedPct.toStringAsFixed(0)}%)',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
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
            child: _errorState(_cryptoError!, _loadCryptoPositions),
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
            child: _errorState(_mt5Error!, _loadMt5Positions),
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
                  _mt5Positions!.positions.isEmpty
                      ? 'No open positions'
                      : '${_mt5Positions!.count} positions',
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
                const SizedBox(height: 4),
                Text(
                  'Balance: ${_mt5Positions!.account.currency} '
                  '${_mt5Positions!.account.balance.toStringAsFixed(2)}  •  '
                  '${_mt5Positions!.account.server.isEmpty ? 'MT5' : _mt5Positions!.account.server}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
