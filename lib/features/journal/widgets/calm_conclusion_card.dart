import 'package:flutter/material.dart';
import 'package:fupan/l10n/generated/app_localizations.dart';
import '../../../models/plan_detail.dart';
import '../../../models/trade_result.dart';
import '../../../models/trade_event.dart';

class CalmConclusionCard extends StatelessWidget {
  final PlanDetail plan;
  final TradeResult? result;
  final List<TradeEvent> events;

  const CalmConclusionCard({
    super.key,
    required this.plan,
    this.result,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final deviation = plan.entryDeviationPct;
    final hasDeviation = deviation != null && deviation.abs() > 0.01;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withAlpha(50)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1️⃣ 标题
            Row(
              children: [
                const Icon(
                  Icons.balance_outlined,
                  size: 20,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.title_calm_conclusion,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Summary Text
            Text(
              _getSummaryText(l10n),
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // 2️⃣ 事实区
            _buildSectionTitle(l10n.label_fact_only),
            const SizedBox(height: 8),
            Text(
              hasDeviation
                  ? l10n.label_deviation_fact(
                      deviation > 0
                          ? l10n.label_direction_up
                          : l10n.label_direction_down,
                      (deviation.abs() * 100).toStringAsFixed(1),
                    )
                  : l10n.label_no_deviation,
              style: const TextStyle(fontSize: 14),
            ),
            if (hasDeviation && plan.entryDriver != null) ...[
              const SizedBox(height: 4),
              Text(
                l10n.label_driver_fact(
                  _getDriverLabel(l10n, plan.entryDriver!),
                ),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],

            // 3. 刺痛点 (EPC)
            _buildEPCFact(context, l10n),

            const SizedBox(height: 16),

            // 4️⃣ 对照区
            _buildSectionTitle(l10n.label_plan_vs_actual),
            const SizedBox(height: 8),
            _buildComparisonRow(
              l10n.label_planned_range,
              "¥${plan.targetLow} – ¥${plan.targetHigh}",
            ),
            _buildComparisonRow(
              l10n.label_actual_price,
              "¥${plan.actualEntryPrice ?? '-'}",
            ),
            _buildComparisonRow(
              l10n.label_deviation_direction,
              hasDeviation
                  ? (deviation > 0
                        ? l10n.label_direction_up
                        : l10n.label_direction_down)
                  : l10n.label_direction_none,
            ),
            const SizedBox(height: 16),

            // 5️⃣ 执行指标区
            _buildExecutionMetrics(context, l10n),
            const SizedBox(height: 16),

            // 6️⃣ 结果关联区
            if (result != null) ...[
              _buildSectionTitle(l10n.label_result_correlation),
              const SizedBox(height: 8),
              Text(
                _getResultCorrelationText(l10n, hasDeviation),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildComparisonRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutionMetrics(BuildContext context, AppLocalizations l10n) {
    final metrics = <Widget>[];

    final entryDev = events
        .where((e) => e.eventStage == 'entry_deviation')
        .toList();
    final entryNon = events
        .where((e) => e.eventStage == 'entry_non_action')
        .toList();
    final exitDev = events
        .where((e) => e.eventStage == 'exit_deviation')
        .toList();
    final stopDev = events
        .where((e) => e.eventStage == 'stoploss_deviation')
        .toList();

    if (entryDev.isNotEmpty)
      metrics.add(_buildMetricRow(l10n.label_etnr, "发生"));
    if (entryNon.isNotEmpty)
      metrics.add(_buildMetricRow(l10n.label_eldc, "发生"));
    if (exitDev.isNotEmpty) metrics.add(_buildMetricRow(l10n.label_tnr, "发生"));
    if (stopDev.isNotEmpty) metrics.add(_buildMetricRow(l10n.label_ldc, "发生"));

    if (metrics.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("执行指标事实"),
        const SizedBox(height: 8),
        ...metrics,
      ],
    );
  }

  Widget _buildMetricRow(String label, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(
            status,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  String _getSummaryText(AppLocalizations l10n) {
    if (result?.epcOpportunityPct != null && result!.epcOpportunityPct! > 0) {
      return l10n.label_epc_summary;
    }

    final hasDeviation = (plan.entryDeviationPct?.abs() ?? 0) > 0.01;
    return hasDeviation
        ? l10n.label_calm_summary_deviation
        : l10n.label_calm_summary_no_deviation;
  }

  Widget _buildEPCFact(BuildContext context, AppLocalizations l10n) {
    if (result == null) return const SizedBox.shrink();

    // Check if any event triggered exit
    final triggeredExit = events.any((e) => e.triggeredExit);

    if (triggeredExit) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          l10n.label_exit_triggered_by_event,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }

    if (result!.epcOpportunityPct != null && result!.epcOpportunityPct! > 0) {
      final pctStr = (result!.epcOpportunityPct! * 100).toStringAsFixed(1);
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          l10n.label_epc_fact(pctStr),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _getDriverLabel(AppLocalizations l10n, String driver) {
    switch (driver) {
      case 'fomo':
      case 'driver_fomo_short':
        return l10n.driver_fomo;
      case 'plan_weakened':
      case 'driver_logic_broken':
        return l10n.driver_plan_weakened;
      case 'market_change':
      case 'driver_market_crash':
        return l10n.driver_market_change;
      case 'wait_failed':
      case 'driver_wait_failed_short':
        return l10n.driver_wait_failed;
      case 'emotion':
      case 'driver_revenge':
        return l10n.driver_emotion;
      default:
        return l10n.driver_other;
    }
  }

  String _getResultCorrelationText(AppLocalizations l10n, bool hasDeviation) {
    if (result == null) return "";
    final isProfit = result!.sellPrice > (plan.actualEntryPrice ?? 0);
    if (isProfit) {
      return hasDeviation
          ? l10n.label_profit_with_deviation
          : l10n.label_profit_no_deviation;
    } else {
      return hasDeviation
          ? l10n.label_loss_with_deviation
          : l10n.label_loss_no_deviation;
    }
  }
}
