import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fupan/l10n/generated/app_localizations.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../models/weekly_report.dart';
import 'weekly_metric_detail_page.dart';

class WeeklyReportPage extends ConsumerStatefulWidget {
  const WeeklyReportPage({super.key});

  @override
  ConsumerState<WeeklyReportPage> createState() => _WeeklyReportPageState();
}

class _WeeklyReportPageState extends ConsumerState<WeeklyReportPage> {
  bool _isLoading = true;
  WeeklyReport? _report;

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    setState(() => _isLoading = true);
    try {
      final report = await ref.read(apiClientProvider).getWeeklyReport();
      setState(() {
        _report = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.tip_fetch_failed(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.title_weekly_report)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchReport,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                children: [
                  if (_report != null && _report!.summary.totalClosed == 0)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBlock,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Text(
                          l10n.tip_no_trades,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                  if (_report != null) ...[
                    _buildSummaryCard(context, _report!.summary),
                    const SizedBox(height: 24),
                    _buildMetricList(context, _report!.metrics),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, WeeklySummary summary) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.label_main_deviation,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textWeak,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            summary.dominantLabel,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.goldMain,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),
          Text(
            l10n.label_conclusion,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textWeak,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            summary.conclusionText,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricList(BuildContext context, List<WeeklyMetric> metrics) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            l10n.label_audit_metrics,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain.withOpacity(0.8),
            ),
          ),
        ),
        ...metrics.map((m) => _buildMetricItem(context, m)),
      ],
    );
  }

  Widget _buildMetricItem(BuildContext context, WeeklyMetric metric) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeeklyMetricDetailPage(metric: metric),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.secondaryBlock.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        metric.key,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.goldMain,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '| ${metric.name}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(l10n, metric.status),
                const SizedBox(width: 8),
                _buildScoreBadge(metric.score),
              ],
            ),
            if (metric.status == 'triggered') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _getMetricSummary(l10n, metric),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textWeak,
                      ),
                    ),
                  ),
                  Text(
                    l10n.label_evidence_count(metric.evidence.length),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textWeak,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.textWeak,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AppLocalizations l10n, String status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildScoreBadge(int? score) {
    if (score == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.goldMain.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.goldMain.withOpacity(0.5)),
      ),
      child: Text(
        score.toString(),
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.goldMain,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getMetricSummary(AppLocalizations l10n, WeeklyMetric metric) {
    if (metric.key == 'PCS') return l10n.label_plan_consistency_desc;
    return metric.summaryLine;
  }
}
