import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../journal/widgets/add_event_sheet.dart';

class AnomalyPage extends ConsumerStatefulWidget {
  const AnomalyPage({super.key});

  @override
  ConsumerState<AnomalyPage> createState() => _AnomalyPageState();
}

class _AnomalyPageState extends ConsumerState<AnomalyPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _hints = [];

  @override
  void initState() {
    super.initState();
    _loadHints();
  }

  Future<void> _loadHints() async {
    setState(() => _isLoading = true);
    try {
      final hints = await ref.read(apiClientProvider).getHints();
      if (mounted) {
        setState(() {
          _hints = hints;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load hints: $e')));
      }
    }
  }

  Future<void> _consumeHint(String id) async {
    try {
      await ref.read(apiClientProvider).consumeHint(id);
      _loadHints(); // Reload to remove consumed hint
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to consume hint: $e')));
      }
    }
  }

  Future<void> _dismissHint(String id) async {
    try {
      await ref.read(apiClientProvider).dismissHint(id);
      _loadHints();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to dismiss hint: $e')));
      }
    }
  }

  void _onRecordEvent(Map<String, dynamic> hint) {
    final planId = hint['plan_id'];
    final eventStage = hint['event_stage'];
    final price = hint['price'] != null
        ? (hint['price'] as num).toDouble()
        : null;

    // Infer plan status from trigger tag to show correct options in AddEventSheet
    String planStatus = 'armed';
    final tag = hint['trigger_tag'];
    if (tag == 'TNR' || tag == 'LDC' || tag == 'EPC') {
      planStatus = 'holding';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEventSheet(
        planId: planId,
        planStatus: planStatus,
        initialEventStage: eventStage,
        initialPrice: price,
        onSuccess: () {
          _consumeHint(hint['id']);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event recorded and hint consumed')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('异动', style: TextStyle(color: AppColors.textMain)),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textMain),
            onPressed: _loadHints,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.goldMain),
            )
          : _hints.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _hints.length,
              itemBuilder: (context, index) {
                final hint = _hints[index];
                return _buildHintCard(hint);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.textWeak,
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无异动提示',
            style: TextStyle(fontSize: 16, color: AppColors.textWeak),
          ),
        ],
      ),
    );
  }

  Widget _buildHintCard(Map<String, dynamic> hint) {
    final type = hint['hint_type'];
    final symbol = hint['symbol'];
    final price = hint['price'];
    final tag = hint['trigger_tag'];
    final ts = hint['created_at'];
    final dateStr = DateFormat(
      'MM-dd HH:mm',
    ).format(DateTime.fromMillisecondsSinceEpoch(ts * 1000));

    String title = '未知提示';
    String subtitle = '';
    Color color = AppColors.card;
    IconData icon = Icons.notifications;

    if (type == 'price_trigger') {
      Map<String, dynamic> payload = {};
      try {
        if (hint['payload_json'] != null) {
          payload = jsonDecode(hint['payload_json']);
        }
      } catch (e) {
        debugPrint('Error parsing payload: $e');
      }

      String tagDesc = tag;
      String extraInfo = '';

      switch (tag) {
        case 'E-TNR':
          tagDesc = '建仓偏离';
          if (payload['threshold'] != null) {
            extraInfo = ' | 阈值: ${payload['threshold'].toStringAsFixed(2)}';
          }
          break;
        case 'E-LDC':
          tagDesc = '建仓机会';
          if (payload['threshold'] != null) {
            extraInfo = ' | 计划价: ${payload['threshold'].toStringAsFixed(2)}';
          }
          break;
        case 'TNR':
          tagDesc = '止盈区间';
          if (payload['target_low'] != null && payload['target_high'] != null) {
            extraInfo =
                ' | 目标: ${payload['target_low']} - ${payload['target_high']}';
          }
          break;
        case 'LDC':
          tagDesc = '止损预警';
          if (payload['stop_value'] != null) {
            extraInfo = ' | 止损价: ${payload['stop_value']}';
          }
          break;
      }

      title = '价格触发: $tag ($tagDesc)';
      subtitle = '当前价: $price$extraInfo';
      color = Colors.orange.shade900.withOpacity(0.1);
      icon = Icons.price_check;
    } else if (type == 'evidence_gap') {
      title = '证据缺失';
      subtitle = '已结算但无事件记录 (缺少买卖点事件记录，影响复盘，请补全当时情况)';
      color = Colors.blue.shade900.withOpacity(0.1);
      icon = Icons.warning_amber;
    }

    return Card(
      color: AppColors.card,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.goldMain, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$symbol · $title',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$dateStr · $subtitle',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textWeak,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.textWeak,
                  ),
                  onPressed: () => _dismissHint(hint['id']),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _onRecordEvent(hint),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldMain,
                  foregroundColor: Colors.black,
                ),
                child: const Text('记录事件'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
