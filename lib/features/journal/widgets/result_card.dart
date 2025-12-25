import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/trade_result.dart';

class ResultCard extends StatelessWidget {
  final TradeResult result;

  const ResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final closedDateStr = DateFormat(
      'yyyy-MM-dd HH:mm',
    ).format(DateTime.fromMillisecondsSinceEpoch(result.closedAt * 1000));

    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              '实际卖出价',
              result.sellPrice.toStringAsFixed(2),
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
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color valueColor = isJudgement
        ? Colors.blue
        : (isDark ? Colors.white70 : Colors.black87);

    if (isJudgement) {
      if (result.systemJudgement == 'follow_plan') valueColor = Colors.green;
      if (result.systemJudgement == 'emotion_override') valueColor = Colors.red;
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
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
