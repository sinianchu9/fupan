import 'package:flutter/material.dart';
import '../../../models/plan_detail.dart';
import '../../../models/trade_event.dart';

class PlanCompareCard extends StatelessWidget {
  final PlanDetail plan;
  final List<TradeEvent> events;

  const PlanCompareCard({super.key, required this.plan, required this.events});

  @override
  Widget build(BuildContext context) {
    final hasTarget = plan.targetLow > 0 || plan.targetHigh > 0;
    final hasStop =
        plan.stopType != 'none' &&
        (plan.stopValue != null || plan.stopTimeDays != null);
    final hasSellConditions = plan.sellConditions.isNotEmpty;
    final exitEvents = events.where((e) => e.triggeredExit).toList();
    final hasExitTrigger = exitEvents.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '对照状态',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  '只显示事实，不提供建议',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusItem(
              Icons.track_changes,
              '目标区间',
              hasTarget ? '已定义' : '未定义',
              hasTarget,
            ),
            _buildStatusItem(
              Icons.shield_outlined,
              '止损逻辑',
              hasStop ? '已定义' : '未定义',
              hasStop,
            ),
            _buildStatusItem(
              Icons.sell_outlined,
              '卖出条件',
              hasSellConditions ? '已定义' : '未定义',
              hasSellConditions,
            ),
            _buildStatusItem(
              Icons.warning_amber_rounded,
              '退出触发事件',
              hasExitTrigger ? '有 (${exitEvents.length})' : '无',
              !hasExitTrigger,
              isWarning: hasExitTrigger,
            ),

            if (hasExitTrigger) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '已记录 ${exitEvents.length} 条事件标注为“触发退出条件”。请在卖出时选择原因并完成对照复盘。',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (plan.sellConditions.contains('time_take_profit') &&
                plan.timeTakeProfitDays != null) ...[
              const SizedBox(height: 8),
              Text(
                '• 时间止盈条件：${plan.timeTakeProfitDays} 天（从建计划开始计）',
                style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(
    IconData icon,
    String label,
    String value,
    bool isOk, {
    bool isWarning = false,
  }) {
    final color = isWarning
        ? Colors.orange
        : (isOk ? Colors.green : Colors.grey);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
