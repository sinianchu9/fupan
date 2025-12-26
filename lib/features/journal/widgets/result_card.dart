import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/trade_result.dart';

class ResultCard extends StatelessWidget {
  final TradeResult result;
  final double? actualEntryPrice;

  const ResultCard({super.key, required this.result, this.actualEntryPrice});

  @override
  Widget build(BuildContext context) {
    final closedDateStr = DateFormat(
      'yyyy-MM-dd HH:mm',
    ).format(DateTime.fromMillisecondsSinceEpoch(result.closedAt * 1000));

    final isDark = Theme.of(context).brightness == Brightness.dark;

    double? profit;
    double? profitPercent;
    if (actualEntryPrice != null && actualEntryPrice! > 0) {
      profit = result.sellPrice - actualEntryPrice!;
      profitPercent = (profit / actualEntryPrice!) * 100;
    }

    return Card(
      color: Colors.indigo.withValues(alpha: isDark ? 0.1 : 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.indigo.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics_outlined, color: Colors.indigo, size: 20),
                SizedBox(width: 8),
                Text(
                  '冷静结论',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.indigo.withValues(alpha: 0.2)),
              ),
              child: Text(
                result.conclusionText,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildResultRow(
              context,
              '系统判定',
              result.judgementDisplay,
              isJudgement: true,
            ),
            _buildResultRow(context, '卖出原因', result.reasonDisplay),
            _buildResultRow(
              context,
              '实际成交价',
              actualEntryPrice?.toStringAsFixed(2) ?? 'N/A',
            ),
            _buildResultRow(
              context,
              '实际卖出价',
              result.sellPrice.toStringAsFixed(2),
            ),
            if (profit != null)
              _buildResultRow(
                context,
                '盈亏额/率',
                '${profit > 0 ? "+" : ""}${profit.toStringAsFixed(2)} (${profitPercent! > 0 ? "+" : ""}${profitPercent.toStringAsFixed(2)}%)',
                valueColor: profit >= 0 ? Colors.red : Colors.green,
              ),
            _buildResultRow(context, '结束时间', closedDateStr),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(
    BuildContext context,
    String label,
    String value, {
    bool isJudgement = false,
    Color? valueColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color finalValueColor =
        valueColor ??
        (isJudgement
            ? Colors.blue
            : (isDark ? Colors.white70 : Colors.black87));

    if (isJudgement) {
      if (result.systemJudgement == 'follow_plan')
        finalValueColor = Colors.green;
      if (result.systemJudgement == 'emotion_override')
        finalValueColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isJudgement ? FontWeight.bold : FontWeight.normal,
                color: finalValueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
