import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fupan/l10n/generated/app_localizations.dart';
import '../../core/theme.dart';
import '../../models/weekly_report.dart';

class WeeklyMetricDetailPage extends StatelessWidget {
  final WeeklyMetric metric;

  const WeeklyMetricDetailPage({super.key, required this.metric});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text('${metric.key} ${l10n.action_view_detail}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionA(context, l10n),
            const SizedBox(height: 24),
            _buildSectionB(context, l10n),
            const SizedBox(height: 24),
            _buildSectionC(context, l10n),
            const SizedBox(height: 24),
            _buildSectionD(context, l10n),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionA(BuildContext context, AppLocalizations l10n) {
    return _buildCard(
      title: l10n.label_weekly_conclusion,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatusLabel(l10n, metric.status),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  metric.summaryLine,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionB(BuildContext context, AppLocalizations l10n) {
    return _buildCard(
      title: l10n.label_quantitative_results,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                l10n.label_deviation_score,
                '${metric.score ?? 0}',
                isGold: true,
              ),
              _buildStatItem(
                l10n.label_deviation_magnitude,
                _getDeviationDisplay(),
              ),
              _buildStatItem(
                l10n.label_trigger_threshold,
                '${(metric.thresholds['deviation_threshold'] * 100).toStringAsFixed(0)}%',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.tip_score_explanation,
            style: const TextStyle(fontSize: 11, color: AppColors.textWeak),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionC(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            l10n.label_evidence_chain,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
        ),
        if (metric.evidence.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.tip_no_evidence,
                style: const TextStyle(color: AppColors.textWeak),
              ),
            ),
          )
        else
          ...metric.evidence.map((e) => _buildEvidenceCard(l10n, e)),
      ],
    );
  }

  Widget _buildSectionD(BuildContext context, AppLocalizations l10n) {
    final tips = _getImprovementTips();
    if (tips.isEmpty) return const SizedBox.shrink();

    return _buildCard(
      title: l10n.label_improvement_tips,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: tips
            .map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: AppColors.goldMain,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textWeak,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {bool isGold = false}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textWeak),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isGold ? AppColors.goldMain : AppColors.textMain,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusLabel(AppLocalizations l10n, String status) {
    String text;
    Color color;
    switch (status) {
      case 'triggered':
        text = l10n.status_triggered;
        color = Colors.orange;
        break;
      case 'not_triggered':
        text = l10n.status_not_triggered;
        color = Colors.green;
        break;
      case 'na':
        text = l10n.status_na;
        color = Colors.grey;
        break;
      case 'insufficient_data':
        text = l10n.status_insufficient_data;
        color = Colors.blueGrey;
        break;
      default:
        text = status;
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEvidenceCard(AppLocalizations l10n, Evidence e) {
    final dateStr = DateFormat(
      'MM-dd HH:mm',
    ).format(DateTime.fromMillisecondsSinceEpoch(e.ts * 1000));
    IconData icon;
    Color color;
    switch (e.type) {
      case 'plan_field':
        icon = Icons.assignment_outlined;
        color = Colors.blue;
        break;
      case 'trade':
        icon = Icons.shopping_cart_outlined;
        color = Colors.green;
        break;
      case 'event':
        icon = Icons.event_note_outlined;
        color = Colors.orange;
        break;
      default:
        icon = Icons.info_outline;
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondaryBlock,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textWeak,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  e.detail,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDeviationDisplay() {
    if (metric.status != 'triggered') return '—';
    final dev = metric.metrics['deviation_pct'] ?? metric.metrics['cost_pct'];
    if (dev != null) {
      return '${(dev * 100).toStringAsFixed(1)}%';
    }
    return '已触发';
  }

  List<String> _getImprovementTips() {
    final tips = <String>[];
    switch (metric.key) {
      case 'PCS':
        tips.add('建议补全：卖出目标/止损价/触发条件');
        tips.add('建议把预算价写成区间上沿，便于判定偏离');
        break;
      case 'E-TNR':
        tips.add('严格遵守预算价入场，避免追高');
        tips.add('若逻辑发生变化，请先记录“计划调整”事件再入场');
        break;
      case 'LDC':
        tips.add('止损是最后的防线，切勿在止损位犹豫');
        tips.add('建议使用条件单自动执行止损');
        break;
      case 'TNR':
        tips.add('到位即卖是纪律，不要贪恋后续涨幅');
        break;
    }
    return tips;
  }
}
