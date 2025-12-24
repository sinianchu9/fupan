import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../models/plan_detail.dart';
import '../../models/plan_detail_response.dart';
import '../../models/plan_edit.dart';
import './widgets/plan_compare_card.dart';
import './widgets/events_timeline_card.dart';
import './widgets/add_event_sheet.dart';
import './widgets/result_card.dart';
import './widgets/close_trade_sheet.dart';

class PlanDetailPage extends ConsumerStatefulWidget {
  final String planId;
  const PlanDetailPage({super.key, required this.planId});

  @override
  ConsumerState<PlanDetailPage> createState() => _PlanDetailPageState();
}

class _PlanDetailPageState extends ConsumerState<PlanDetailPage> {
  bool _isLoading = true;
  PlanDetailResponse? _data;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() => _isLoading = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      final json = await apiClient.getPlanDetail(widget.planId);
      if (!mounted) return;
      setState(() {
        _data = PlanDetailResponse.fromJson(json);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('获取详情失败: $e')));
      setState(() => _isLoading = false);
    }
  }

  Future<void> _armPlan() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认武装计划？'),
        content: const Text('武装后关键字段将锁定。后续修改将以“修订记录”形式保存，不会改写原始计划。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认武装'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.armPlan(widget.planId);
      if (!mounted) return;
      _fetchDetail();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('武装失败: $e')));
    }
  }

  Future<void> _reviseTarget() async {
    final lowController = TextEditingController(
      text: _data!.plan.targetLow.toString(),
    );
    final highController = TextEditingController(
      text: _data!.plan.targetHigh.toString(),
    );

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '修订目标区间',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '注意：修订不会改写原计划，仅作为调整记录。',
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lowController,
              decoration: const InputDecoration(
                labelText: '新目标低位',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: highController,
              decoration: const InputDecoration(
                labelText: '新目标高位',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('提交修订'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (result == true) {
      try {
        final apiClient = ref.read(apiClientProvider);
        await apiClient.updatePlan(widget.planId, {
          'target_low': double.parse(lowController.text),
          'target_high': double.parse(highController.text),
        });
        if (!mounted) return;
        _fetchDetail();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('修订失败: $e')));
      }
    }
  }

  void _showAddEventSheet() {
    if (_data == null) return;
    final isClosed = _data!.result != null || _data!.plan.status == 'closed';
    if (isClosed) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          AddEventSheet(planId: widget.planId, onSuccess: _fetchDetail),
    );
  }

  void _showCloseTradeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CloseTradeSheet(
        planId: widget.planId,
        status: _data!.plan.status,
        onSuccess: _fetchDetail,
      ),
    );
  }

  Future<void> _unarchivePlan() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.unarchivePlan(widget.planId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已取消归档')));
      _fetchDetail();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('操作失败: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_data == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('加载失败')),
      );
    }

    final plan = _data!.plan;

    return Scaffold(
      appBar: AppBar(title: const Text('计划详情')),
      body: RefreshIndicator(
        onRefresh: _fetchDetail,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSummaryCard(plan),
            const SizedBox(height: 16),
            _buildOriginalPlanCard(plan),
            const SizedBox(height: 16),
            PlanCompareCard(plan: plan, events: _data!.events),
            const SizedBox(height: 16),
            EventsTimelineCard(
              events: _data!.events,
              onAddEvent: _showAddEventSheet,
              isReadOnly:
                  _data!.result != null || _data!.plan.status == 'closed',
            ),
            const SizedBox(height: 16),
            if (_data!.result != null) ...[
              ResultCard(result: _data!.result!),
              const SizedBox(height: 16),
            ] else if (_data!.plan.status != 'closed') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showCloseTradeSheet,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text(
                    '结束交易（卖出）',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            _buildActionArea(plan),
            const SizedBox(height: 16),
            _buildEditsList(_data!.edits),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(PlanDetail plan) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${plan.symbolCode} ${plan.symbolName}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusBadge(plan),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              plan.symbolIndustry,
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeInfo('创建', plan.createdAt),
                _buildTimeInfo('更新', plan.updatedAt),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PlanDetail plan) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(plan.status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: _getStatusColor(plan.status).withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        plan.statusDisplay,
        style: TextStyle(
          color: _getStatusColor(plan.status),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, int timestamp) {
    final dateStr = DateFormat(
      'MM-dd HH:mm',
    ).format(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(dateStr, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildOriginalPlanCard(PlanDetail plan) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.blueGrey.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.blueGrey.withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lock_outline, size: 16, color: Colors.blueGrey),
                SizedBox(width: 8),
                Text(
                  '原始计划 (锁定内容)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('买入理由', plan.buyReasonText),
            _buildDetailRow('理由类型', plan.buyReasonTypes.join(', ')),
            _buildDetailRow(
              '目标区间',
              '${plan.targetLow} ~ ${plan.targetHigh} (${plan.targetType})',
            ),
            _buildDetailRow('卖出逻辑', plan.sellConditions.join(', ')),
            if (plan.timeTakeProfitDays != null)
              _buildDetailRow('时间止盈', '${plan.timeTakeProfitDays} 天'),
            _buildDetailRow(
              '止损逻辑',
              '${plan.stopType}: ${plan.stopValue ?? plan.stopTimeDays ?? "-"}',
            ),
            if (plan.entryPrice != null)
              _buildDetailRow('预期买入价', plan.entryPrice.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildActionArea(PlanDetail plan) {
    final isClosed = _data!.result != null || plan.status == 'closed';
    if (isClosed) {
      if (plan.isArchived) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _unarchivePlan,
            icon: const Icon(Icons.unarchive_outlined),
            label: const Text('取消归档'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
              foregroundColor: Colors.white,
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    if (plan.status == 'draft') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _armPlan,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(16),
          ),
          child: const Text(
            '确认并进入已武装 (Armed)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      return Column(
        children: [
          const Text(
            '计划已锁定；后续调整会以“修订记录”形式保存。',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _reviseTarget,
                  icon: const Icon(Icons.edit_location_alt_outlined),
                  label: const Text('修订目标区间'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Colors.blueGrey[800]
                        : Colors.blueGrey[50],
                    foregroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.blueGrey[800],
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildEditsList(List<PlanEdit> edits) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '修订记录',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        if (edits.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text('暂无修订记录', style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          ...edits.map((edit) => _buildEditItem(edit)),
      ],
    );
  }

  Widget _buildEditItem(PlanEdit edit) {
    final dateStr = DateFormat(
      'MM-dd HH:mm',
    ).format(DateTime.fromMillisecondsSinceEpoch(edit.editedAt * 1000));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: isDark ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                edit.fieldDisplay,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.orange,
                ),
              ),
              Text(
                dateStr,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${edit.oldValue} -> ${edit.newValue}',
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.grey;
      case 'armed':
        return Colors.blue;
      case 'holding':
        return Colors.orange;
      case 'closed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
