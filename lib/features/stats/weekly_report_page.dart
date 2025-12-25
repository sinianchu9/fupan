import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fupan/l10n/generated/app_localizations.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';

class WeeklyReportPage extends ConsumerStatefulWidget {
  const WeeklyReportPage({super.key});

  @override
  ConsumerState<WeeklyReportPage> createState() => _WeeklyReportPageState();
}

class _WeeklyReportPageState extends ConsumerState<WeeklyReportPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _report;

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
                  vertical: 32,
                ),
                children: [
                  if (_report?['has_trades'] == false)
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

                  _buildReportCard([
                    _buildReportLine(
                      l10n.label_pcs_score,
                      _report?['has_trades'] == true
                          ? '${_report?['pcs']}'
                          : l10n.label_no_trades,
                      isGold: true,
                    ),
                    const Divider(height: 48),
                    _buildReportLine(
                      l10n.label_main_deviation,
                      _getDeviationDisplay(context, _report?['main_deviation']),
                    ),
                    const Divider(height: 48),
                    _buildReportLine(
                      l10n.label_conclusion,
                      _report?['has_trades'] == true
                          ? (_report?['conclusion_text'] ?? l10n.label_none)
                          : l10n.label_none,
                      isLongText: true,
                    ),
                    const Divider(height: 48),
                    _buildReportLine(
                      l10n.label_tnr_ldc,
                      _getTnrLdcDisplay(context, _report),
                      isWrap: true,
                    ),
                  ]),
                ],
              ),
            ),
    );
  }

  String _getTnrLdcDisplay(BuildContext context, Map<String, dynamic>? report) {
    final l10n = AppLocalizations.of(context)!;
    if (report == null) return '-';
    final tnr = report['tnr_status'] ?? l10n.label_not_applicable;
    final ldc = report['ldc_status'] ?? l10n.label_not_applicable;
    final ldcVal = report['ldc_value'];

    String display = 'TNR: $tnr / LDC: $ldc';
    if (ldcVal != null) {
      display += ' (¥$ldcVal)';
    }
    return display;
  }

  Widget _buildReportCard(List<Widget> children) {
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
        children: children,
      ),
    );
  }

  Widget _buildReportLine(
    String title,
    String value, {
    bool isLongText = false,
    bool isGold = false,
    bool isWrap = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textWeak,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        isWrap
            ? Wrap(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: isLongText ? 15 : 32,
                      fontWeight: isLongText
                          ? FontWeight.normal
                          : FontWeight.bold,
                      color: isLongText
                          ? AppColors.textSecondary
                          : (isGold ? AppColors.goldMain : AppColors.textMain),
                      height: isLongText ? 1.5 : 1.2,
                    ),
                  ),
                ],
              )
            : Text(
                value,
                maxLines: isLongText ? null : 1,
                overflow: isLongText ? null : TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isLongText ? 15 : 32,
                  fontWeight: isLongText ? FontWeight.normal : FontWeight.bold,
                  color: isLongText
                      ? AppColors.textSecondary
                      : (isGold ? AppColors.goldMain : AppColors.textMain),
                  height: isLongText ? 1.5 : 1.2,
                ),
              ),
      ],
    );
  }

  String _getDeviationDisplay(BuildContext context, String? deviation) {
    final l10n = AppLocalizations.of(context)!;
    switch (deviation) {
      case 'no_plan':
        return l10n.deviation_no_plan;
      case 'emotion_override':
        return l10n.deviation_emotion_override;
      case 'forced':
        return l10n.deviation_forced;
      case 'none':
        return l10n.deviation_none;
      case 'no_trades':
        return l10n.deviation_no_trades;
      default:
        return l10n.deviation_no_trades;
    }
  }
}
