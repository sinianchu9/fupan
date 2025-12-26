import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fupan/l10n/generated/app_localizations.dart';
import '../../../models/trade_event.dart';

class EventsTimelineCard extends StatelessWidget {
  final List<TradeEvent> events;
  final VoidCallback onAddEvent;
  final bool isReadOnly;

  const EventsTimelineCard({
    super.key,
    required this.events,
    required this.onAddEvent,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // 按时间升序排列
    final sortedEvents = List<TradeEvent>.from(events)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.label_event_timeline,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!isReadOnly)
                  TextButton.icon(
                    onPressed: onAddEvent,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(
                      l10n.action_add_event,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (sortedEvents.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    '暂无事件。记录那些已经发生、并对原交易计划有效性产生影响的客观事实。比如本应该执行却因外部因素未执行的，本不该执行的却执行了的事件。', // This could be localized too
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedEvents.length,
                separatorBuilder: (context, index) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  return _buildEventItem(context, sortedEvents[index]);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, TradeEvent event) {
    final l10n = AppLocalizations.of(context)!;
    final dateStr = DateFormat(
      'yyyy-MM-dd HH:mm',
    ).format(DateTime.fromMillisecondsSinceEpoch(event.createdAt * 1000));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getStageColor(
                  event.eventStage ?? event.eventType,
                ).withAlpha(38),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getStageDisplay(context, event),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _getStageColor(event.eventStage ?? event.eventType),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              dateStr,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const Spacer(),
            if (event.triggeredExit)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(38),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  l10n.label_exit_trigger_event,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          event.summary,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (event.behaviorDriver != null || event.priceAtEvent != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              if (event.behaviorDriver != null)
                Text(
                  '${l10n.label_behavior_driver}：${_getDriverLabel(context, event.behaviorDriver!)}',
                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
              if (event.behaviorDriver != null && event.priceAtEvent != null)
                const SizedBox(width: 12),
              if (event.priceAtEvent != null)
                Text(
                  '${l10n.label_price_at_event}：¥${event.priceAtEvent}',
                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
            ],
          ),
        ],
        if (event.eventStage == null) ...[
          const SizedBox(height: 4),
          Text(
            '影响对象：${event.impactDisplay}',
            style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
          ),
        ],
      ],
    );
  }

  Color _getStageColor(String stage) {
    switch (stage) {
      case 'entry_deviation':
      case 'entry_non_action':
        return Colors.orange;
      case 'exit_deviation':
      case 'stoploss_deviation':
        return Colors.red;
      case 'external_change':
        return Colors.blue;
      case 'falsify':
        return Colors.red;
      case 'forced':
        return Colors.orange;
      case 'verify':
        return Colors.green;
      case 'structure':
        return Colors.blue;
      default:
        return Colors.grey;
    }
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

  String _getDriverLabel(BuildContext context, String driver) {
    final l10n = AppLocalizations.of(context)!;
    switch (driver) {
      case 'driver_fomo_short':
        return l10n.driver_fomo_short;
      case 'driver_fear':
        return l10n.driver_fear;
      case 'driver_wait_failed_short':
        return l10n.driver_wait_failed_short;
      case 'driver_logic_broken':
        return l10n.driver_logic_broken;
      case 'driver_market_crash':
        return l10n.driver_market_crash;
      case 'driver_profit_protect':
        return l10n.driver_profit_protect;
      case 'driver_revenge':
        return l10n.driver_revenge;
      case 'driver_other_short':
        return l10n.driver_other_short;
      default:
        return driver;
    }
  }
}
