import 'package:flutter/material.dart';
import 'package:fupan/l10n/generated/app_localizations.dart';
import '../../../models/plan_detail.dart';
import '../../../models/trade_event.dart';

class PlanCompareCard extends StatelessWidget {
  final PlanDetail plan;
  final List<TradeEvent> events;

  const PlanCompareCard({super.key, required this.plan, required this.events});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.label_comparison_status,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.label_fact_only,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusItem(
              Icons.track_changes,
              l10n.label_target_range,
              hasTarget ? l10n.label_defined : l10n.label_undefined,
              hasTarget,
            ),
            _buildStatusItem(
              Icons.shield_outlined,
              l10n.label_stop_logic,
              hasStop ? l10n.label_defined : l10n.label_undefined,
              hasStop,
            ),
            _buildStatusItem(
              Icons.sell_outlined,
              l10n.label_sell_logic,
              hasSellConditions ? l10n.label_defined : l10n.label_undefined,
              hasSellConditions,
            ),
            _buildStatusItem(
              Icons.warning_amber_rounded,
              l10n.label_exit_trigger_event,
              hasExitTrigger
                  ? l10n.label_yes_with_count(exitEvents.length)
                  : l10n.label_none,
              !hasExitTrigger,
              isWarning: hasExitTrigger,
            ),

            if (hasExitTrigger) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withAlpha(75)),
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
                        l10n.tip_exit_event_recorded(exitEvents.length),
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
                l10n.label_time_take_profit_condition(plan.timeTakeProfitDays!),
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
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
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
