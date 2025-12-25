import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('获取周报失败: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('本周纪律周报')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchReport,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  if (_report?['has_trades'] == false)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 24),
                        child: Text(
                          '本周无交易记录',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    ),

                  _buildReportLine(
                    '1️⃣ 计划一致性得分 (PCS)',
                    _report?['has_trades'] == true
                        ? '${_report?['pcs']}'
                        : '无交易',
                    subtitle: '基于本周已关闭交易的系统判定',
                  ),
                  const Divider(height: 40),
                  _buildReportLine(
                    '2️⃣ 本周主要偏离类型',
                    _getDeviationDisplay(_report?['main_deviation']),
                    subtitle: '优先级：无计划 > 情绪覆盖 > 强制扰动',
                  ),
                  const Divider(height: 40),
                  _buildReportLine(
                    '3️⃣ 冷静结论',
                    _report?['has_trades'] == true
                        ? (_report?['conclusion_text'] ?? '无')
                        : '无',
                    isLongText: true,
                    subtitle: '本周最具代表性的一条系统结论',
                  ),
                  const Divider(height: 40),
                  _buildReportLine(
                    '4️⃣ TNR / LDC',
                    _getTnrLdcDisplay(_report),
                    subtitle: '目标触达不卖 / 止损位不走 (需行情对照)',
                  ),
                ],
              ),
            ),
    );
  }

  String _getTnrLdcDisplay(Map<String, dynamic>? report) {
    if (report == null) return '-';
    final tnr = report['tnr_status'] ?? '不适用';
    final ldc = report['ldc_status'] ?? '不适用';
    final ldcVal = report['ldc_value'];

    String display = 'TNR: $tnr / LDC: $ldc';
    if (ldcVal != null) {
      display += ' (¥$ldcVal)';
    }
    return display;
  }

  Widget _buildReportLine(
    String title,
    String value, {
    String? subtitle,
    bool isLongText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: isLongText ? 16 : 28,
            fontWeight: isLongText ? FontWeight.normal : FontWeight.bold,
            color: isLongText ? null : Theme.of(context).colorScheme.primary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  String _getDeviationDisplay(String? deviation) {
    switch (deviation) {
      case 'no_plan':
        return '无计划交易';
      case 'emotion_override':
        return '情绪覆盖计划';
      case 'forced':
        return '强制扰动';
      case 'none':
        return '无偏离';
      case 'no_trades':
        return '无交易';
      default:
        return '无交易';
    }
  }
}
