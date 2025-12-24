import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
                const Text(
                  '事件线',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (!isReadOnly)
                  TextButton.icon(
                    onPressed: onAddEvent,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('新增事件'),
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
                    '暂无事件。事件只用于记录影响计划的证据，不是新闻时间轴。',
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
                  return _buildEventItem(sortedEvents[index]);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventItem(TradeEvent event) {
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
                color: _getTypeColor(event.eventType).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                event.typeDisplay,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _getTypeColor(event.eventType),
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
                  color: Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '触发退出',
                  style: TextStyle(
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
        const SizedBox(height: 4),
        Text(
          '影响对象：${event.impactDisplay}',
          style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
        ),
      ],
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
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
}
