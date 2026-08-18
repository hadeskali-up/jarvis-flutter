import 'package:flutter/material.dart';

import '../models/dashboard_data.dart';
import '../theme/colors.dart';
import 'neo_card.dart';

class DashboardSectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const DashboardSectionTitle({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      );
}

class VpsHealthCard extends StatelessWidget {
  final VpsData data;

  const VpsHealthCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final elevated = data.cpuPct > 80 || data.memPct > 80 || data.diskPct > 85;
    return NeoCard(
      backgroundColor: elevated ? const Color(0xFFFFD8D8) : NeoColors.mintGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'VPS resource health',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                elevated ? 'HIGH LOAD' : 'HEALTHY',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: elevated ? NeoColors.red : const Color(0xFF006B45),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MetricBar(label: 'CPU', percent: data.cpuPct, detail: 'load ${data.cpuLoad.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _MetricBar(
            label: 'Memory',
            percent: data.memPct,
            detail: '${data.memUsedMb.toStringAsFixed(0)} / ${data.memTotalMb.toStringAsFixed(0)} MB',
          ),
          const SizedBox(height: 12),
          _MetricBar(
            label: 'Storage',
            percent: data.diskPct,
            detail: '${data.diskUsedGb.toStringAsFixed(1)} / ${data.diskTotalGb.toStringAsFixed(1)} GB',
          ),
          const SizedBox(height: 12),
          Text(
            'Uptime ${_formatUptime(data.uptimeSeconds)}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  static String _formatUptime(int seconds) {
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    return days > 0 ? '${days}d ${hours}h' : '${hours}h';
  }
}

class _MetricBar extends StatelessWidget {
  final String label;
  final double percent;
  final String detail;

  const _MetricBar({required this.label, required this.percent, required this.detail});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800))),
              Text('${percent.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 5),
          LinearProgressIndicator(
            value: (percent / 100).clamp(0, 1).toDouble(),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
            color: percent > 80 ? NeoColors.red : percent > 60 ? NeoColors.orange : NeoColors.blue,
            backgroundColor: NeoColors.white,
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(detail, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      );
}

class ProviderBalanceCards extends StatelessWidget {
  final ProviderBalancesResponse? balances;
  final DeepSeekData? deepseekFallback;

  const ProviderBalanceCards({
    super.key,
    required this.balances,
    required this.deepseekFallback,
  });

  @override
  Widget build(BuildContext context) {
    final deepseek = balances?.named('deepseek');
    final amanai = balances?.named('amanai');
    return Column(
      children: [
        _ProviderCard(
          name: 'DeepSeek',
          balance: deepseek?.balance ?? deepseekFallback?.balance,
          unit: deepseek?.unit ?? deepseekFallback?.currency ?? 'USD',
          active: deepseek?.status.toLowerCase() == 'active' || deepseekFallback?.available == true,
          color: NeoColors.teal,
        ),
        const SizedBox(height: 14),
        _ProviderCard(
          name: 'amanAI',
          balance: amanai?.balance,
          unit: amanai?.unit ?? 'credits',
          active: amanai?.status.toLowerCase() == 'active',
          color: NeoColors.yellow,
        ),
      ],
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final String name;
  final double? balance;
  final String unit;
  final bool active;
  final Color color;

  const _ProviderCard({
    required this.name,
    required this.balance,
    required this.unit,
    required this.active,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => NeoCard(
        backgroundColor: color,
        child: Row(
          children: [
            const Icon(Icons.account_balance_wallet_outlined, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                  Text(active ? 'ACTIVE' : 'UNAVAILABLE', style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Text(
              balance == null ? '—' : _formatBalance(balance!, unit),
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      );

  static String _formatBalance(double value, String unit) {
    if (unit == 'USD') return '\$${value.toStringAsFixed(2)}';
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M\n$unit';
    return '${value.toStringAsFixed(0)}\n$unit';
  }
}

class AgentStatusCard extends StatelessWidget {
  final Map<String, AgentStat> agents;

  const AgentStatusCard({super.key, required this.agents});

  @override
  Widget build(BuildContext context) {
    final entries = agents.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return NeoCard(
      child: Column(
        children: entries.map((entry) {
          final stat = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    entry.key,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                Text('${stat.completed} done', style: const TextStyle(fontWeight: FontWeight.w700)),
                if (stat.failed > 0) ...[
                  const SizedBox(width: 8),
                  Text('${stat.failed} fail', style: const TextStyle(color: NeoColors.red, fontWeight: FontWeight.w800)),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
