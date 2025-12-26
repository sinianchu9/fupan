import 'package:flutter/material.dart';
import 'package:fupan/l10n/generated/app_localizations.dart';
import '../../../models/plan_detail.dart';
import '../../../models/trade_result.dart';
import '../../../models/trade_event.dart';
import '../../../core/theme.dart';

class CalmConclusionSummaryCard extends StatefulWidget {
  final PlanDetail plan;
  final TradeResult? result;
  final List<TradeEvent> events;
  final Function(String eventId)? onLinkClick;

  const CalmConclusionSummaryCard({
    super.key,
    required this.plan,
    this.result,
    required this.events,
    this.onLinkClick,
  });

  @override
  State<CalmConclusionSummaryCard> createState() =>
      _CalmConclusionSummaryCardState();
}

class _CalmConclusionSummaryCardState extends State<CalmConclusionSummaryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.result == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final result = widget.result!;
    final isFollowPlan = result.systemJudgement == 'follow_plan';
    final isEmotion = result.systemJudgement == 'emotion_override';

    // 1. Determine Status Color & Icon
    final statusColor = isFollowPlan ? Colors.green : Colors.red;
    final statusIcon = isFollowPlan
        ? Icons.check_circle_outline
        : Icons.warning_amber_rounded;

    // 2. Collect Triggered Metrics (Chips)
    final chips = _buildMetricChips(l10n);

    // 3. Determine Linked Event
    final linkedEvent = _findLinkedEvent();

    return Card(
      elevation: 2,
      shadowColor: statusColor.withAlpha(50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withAlpha(80), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title & Subtitle
            Row(
              children: [
                Icon(Icons.balance, color: AppColors.textMain, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.title_calm_conclusion,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.subtitle_fact_only, // "只显示事实，不提供建议"
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textWeak,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 1. System Judgment (Main Conclusion)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isFollowPlan
                        ? l10n.judgement_follow_plan
                        : l10n.judgement_emotion_override,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 2. Triggered Metrics (Chips)
            if (chips.isNotEmpty) ...[
              Wrap(spacing: 8, runSpacing: 8, children: chips),
              const SizedBox(height: 12),
            ],

            // 3. One-line Summary (Expandable)
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.conclusionText,
                    maxLines: _isExpanded ? 10 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  if (!_isExpanded && result.conclusionText.length > 20)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        l10n.action_expand, // "展开"
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textWeak,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 4. Evidence Link
            if (linkedEvent != null) ...[
              const SizedBox(height: 16),
              InkWell(
                onTap: () => widget.onLinkClick?.call(linkedEvent.id),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBlock,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.link,
                        size: 16,
                        color: AppColors.goldMain,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          l10n.label_associated_event(
                            _getStageDisplay(context, linkedEvent),
                            linkedEvent.priceAtEvent?.toString() ?? '-',
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.goldMain,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMetricChips(AppLocalizations l10n) {
    final chips = <Widget>[];
    final result = widget.result!;

    // EPC
    if (result.epcOpportunityPct != null && result.epcOpportunityPct! > 0) {
      chips.add(_buildChip(l10n.label_epc, Colors.orange));
    }

    // Check events for other metrics
    final entryDev = widget.events.any(
      (e) => e.eventStage == 'entry_deviation',
    );
    final entryNon = widget.events.any(
      (e) => e.eventStage == 'entry_non_action',
    );
    final exitDev = widget.events.any((e) => e.eventStage == 'exit_deviation');
    final stopDev = widget.events.any(
      (e) => e.eventStage == 'stoploss_deviation',
    );

    if (entryDev) chips.add(_buildChip(l10n.label_etnr, Colors.orange));
    if (entryNon) chips.add(_buildChip(l10n.label_eldc, Colors.red));
    if (exitDev) chips.add(_buildChip(l10n.label_tnr, Colors.orange));
    if (stopDev) chips.add(_buildChip(l10n.label_ldc, Colors.red));

    return chips;
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  TradeEvent? _findLinkedEvent() {
    // 1. Priority: Triggered Exit
    final triggered = widget.events.where((e) => e.triggeredExit).toList();
    if (triggered.isNotEmpty) return triggered.last;

    // 2. Priority: Matching Deviation Stage
    // If system says emotion_override, look for deviation events near close time
    if (widget.result!.systemJudgement == 'emotion_override') {
      // Find latest deviation event
      final deviations = widget.events
          .where(
            (e) => e.eventStage != null && e.eventStage!.contains('deviation'),
          )
          .toList();
      if (deviations.isNotEmpty) {
        deviations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return deviations.first;
      }
    }

    return null;
  }

  String _getStageDisplay(BuildContext context, TradeEvent event) {
    final l10n = AppLocalizations.of(context)!;
    if (event.eventStage == null) return event.typeDisplay;
    switch (event.eventStage) {
      case 'entry_deviation':
        return l10n.stage_entry_deviation;
      case 'entry_non_action':
        return l10n.stage_entry_non_action;
      case 'exit_deviation':
        return l10n.stage_exit_deviation;
      case 'stoploss_deviation':
        return l10n.stage_stoploss_deviation;
      case 'external_change':
        return l10n.stage_external_change;
      default:
        return event.eventStage!;
    }
  }
}
