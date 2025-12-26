import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fupan/l10n/generated/app_localizations.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../models/plan_detail.dart';
import '../../models/plan_edit.dart';
import '../../models/plan_detail_response.dart';
import 'self_assessment_page.dart';
import 'widgets/plan_integrity_card.dart';
import 'widgets/events_timeline_card.dart';
import 'widgets/add_event_sheet.dart';
import 'widgets/revise_target_sheet.dart';
import 'widgets/calm_conclusion_summary_card.dart';
import 'widgets/close_trade_sheet.dart';

class PlanDetailPage extends ConsumerStatefulWidget {
  final String planId;
  const PlanDetailPage({super.key, required this.planId});

  @override
  ConsumerState<PlanDetailPage> createState() => _PlanDetailPageState();
}

class _PlanDetailPageState extends ConsumerState<PlanDetailPage> {
  bool _isLoading = true;
  PlanDetailResponse? _data;
  final GlobalKey<EventsTimelineCardState> _eventsTimelineKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoading = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      final data = await apiClient.getPlanDetail(widget.planId);
      if (!mounted) return;
      setState(() {
        _data = PlanDetailResponse.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tip_fetch_failed(e.toString()))),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _armPlan(String planId) async {
    final l10n = AppLocalizations.of(context)!;
    final priceController = TextEditingController();
    String? selectedDriver;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final price = double.tryParse(priceController.text) ?? 0;
          final plannedPrice =
              _data?.plan.plannedEntryPrice ?? _data?.plan.entryPrice ?? 0;
          double deviation = 0;
          if (plannedPrice > 0 && price > 0) {
            // Long-only: only positive if price is HIGHER than planned
            deviation = (price - plannedPrice) / plannedPrice;
          }
          final showDriver = deviation > 0.01;
          final devPercent = (deviation * 100).toStringAsFixed(1);

          return AlertDialog(
            title: Text(l10n.action_arm),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: l10n.label_close_price,
                      hintText: l10n.hint_close_price,
                      helperText: plannedPrice > 0
                          ? '计划: $plannedPrice, 输入: $price, 偏离: $devPercent% ${showDriver ? "(" + l10n.tip_entry_deviation_hint + ")" : ""}'
                          : '未设置计划买入价，无法计算偏离',
                      helperStyle: TextStyle(
                        color: (plannedPrice > 0 && showDriver)
                            ? Colors.orange
                            : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  if (showDriver) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: l10n.label_entry_driver,
                      ),
                      value: selectedDriver,
                      items: [
                        DropdownMenuItem(
                          value: 'fomo',
                          child: Text(l10n.driver_fomo),
                        ),
                        DropdownMenuItem(
                          value: 'plan_weakened',
                          child: Text(l10n.driver_plan_weakened),
                        ),
                        DropdownMenuItem(
                          value: 'market_change',
                          child: Text(l10n.driver_market_change),
                        ),
                        DropdownMenuItem(
                          value: 'wait_failed',
                          child: Text(l10n.driver_wait_failed),
                        ),
                        DropdownMenuItem(
                          value: 'emotion',
                          child: Text(l10n.driver_emotion),
                        ),
                        DropdownMenuItem(
                          value: 'other',
                          child: Text(l10n.driver_other),
                        ),
                      ],
                      onChanged: (v) => setState(() => selectedDriver = v),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.action_back),
              ),
              ElevatedButton(
                onPressed: () {
                  final p = double.tryParse(priceController.text);
                  if (p != null) {
                    Navigator.pop(context, {
                      'price': p,
                      'driver': selectedDriver,
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.tip_invalid_price)),
                    );
                  }
                },
                child: Text(l10n.action_confirm),
              ),
            ],
          );
        },
      ),
    );

    if (result == null) return;

    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.armPlan(
        planId,
        actualEntryPrice: result['price'],
        entryDriver: result['driver'],
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.status_armed)));
      _loadDetail();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tip_submit_failed(e.toString()))),
      );
    }
  }

  Future<void> _archivePlan(String planId) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.archivePlan(planId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已归档')));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tip_submit_failed(e.toString()))),
      );
    }
  }

  void _showCloseTradeSheet(PlanDetail plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CloseTradeSheet(
        planId: plan.id,
        status: plan.status,
        onSuccess: () {
          _loadDetail();
        },
      ),
    );
  }

  Future<void> _showAddEventSheet(PlanDetail plan) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddEventSheet(
        planId: plan.id,
        planStatus: plan.status,
        onSuccess: () => _loadDetail(),
      ),
    );
  }

  Future<void> _showReviseTargetSheet(PlanDetail plan) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          ReviseTargetSheet(plan: plan, onSuccess: () => _loadDetail()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.title_plan_detail)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_data == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.title_plan_detail)),
        body: Center(child: Text(l10n.tip_no_plans)),
      );
    }

    final plan = _data!.plan;

    return Scaffold(
      appBar: AppBar(
        title: Text('${plan.symbolCode} ${l10n.title_plan_detail}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            tooltip: l10n.action_archive,
            onPressed: () => _archivePlan(plan.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSummaryCard(context, plan),
                  const SizedBox(height: 16),
                  if (_data!.result != null) ...[
                    CalmConclusionSummaryCard(
                      plan: plan,
                      result: _data!.result,
                      events: _data!.events,
                      onLinkClick: (eventId) {
                        _eventsTimelineKey.currentState?.scrollToEvent(eventId);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildOriginalPlanCard(context, plan),
                  const SizedBox(height: 16),
                  PlanIntegrityCard(plan: plan),
                  const SizedBox(height: 16),
                  EventsTimelineCard(
                    key: _eventsTimelineKey,
                    events: _data!.events,
                    onAddEvent: () => _showAddEventSheet(plan),
                    isReadOnly: plan.status == 'closed',
                  ),
                  const SizedBox(height: 24),
                  _buildActionArea(context, plan),
                  if (_data!.edits.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildEditsList(context, _data!.edits),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, PlanDetail plan) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppTheme.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${plan.symbolCode} ${plan.symbolName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMain,
                    ),
                  ),
                ),
                _buildStatusBadge(context, plan),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              plan.symbolIndustry,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),
            Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                _buildTimeInfo(context, l10n.label_create, plan.createdAt),
                _buildTimeInfo(context, l10n.label_update, plan.updatedAt),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, PlanDetail plan) {
    final l10n = AppLocalizations.of(context)!;
    String display;
    switch (plan.status) {
      case 'draft':
        display = l10n.status_draft;
        break;
      case 'armed':
        display = l10n.status_armed;
        break;
      case 'holding':
        display = l10n.status_holding;
        break;
      case 'closed':
        display = l10n.status_closed;
        break;
      default:
        display = plan.statusDisplay;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(plan.status).withAlpha(25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _getStatusColor(plan.status).withAlpha(128)),
      ),
      child: Text(
        display,
        style: TextStyle(
          color: _getStatusColor(plan.status),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTimeInfo(BuildContext context, String label, int timestamp) {
    final dateStr = DateFormat(
      'MM-dd HH:mm',
    ).format(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textWeak),
        ),
        const SizedBox(height: 2),
        Text(
          dateStr,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildOriginalPlanCard(BuildContext context, PlanDetail plan) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBlock,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 16,
                  color: AppColors.textWeak,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.label_original_plan,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(context, l10n.label_buy_reason, plan.buyReasonText),
            _buildDetailRow(
              context,
              l10n.label_reason_type,
              plan.buyReasonTypes.join(', '),
            ),
            _buildDetailRow(
              context,
              l10n.label_target_range,
              '${plan.targetLow} ~ ${plan.targetHigh} (${plan.targetType})',
            ),
            _buildDetailRow(
              context,
              l10n.label_sell_logic,
              plan.sellConditions.join(', '),
            ),
            if (plan.timeTakeProfitDays != null)
              _buildDetailRow(
                context,
                l10n.label_time_take_profit,
                '${plan.timeTakeProfitDays} 天',
              ),
            _buildDetailRow(
              context,
              l10n.label_stop_logic,
              '${plan.stopType}: ${plan.stopValue ?? plan.stopTimeDays ?? "-"}',
            ),
            if (plan.plannedEntryPrice != null)
              _buildDetailRow(
                context,
                l10n.label_entry_price,
                plan.plannedEntryPrice.toString(),
              ),
            if (plan.actualEntryPrice != null)
              _buildDetailRow(
                context,
                l10n.label_close_price,
                plan.actualEntryPrice.toString(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 72, maxWidth: 120),
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textWeak, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionArea(BuildContext context, PlanDetail plan) {
    final l10n = AppLocalizations.of(context)!;
    if (plan.status == 'closed') {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SelfAssessmentPage(planId: plan.id),
              ),
            );
          },
          icon: const Icon(Icons.assignment_outlined),
          label: Text(l10n.action_self_assessment),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            if (plan.status == 'draft')
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _armPlan(plan.id),
                    icon: const Icon(Icons.security),
                    label: Text(l10n.action_arm),
                  ),
                ),
              ),
            if (plan.status == 'armed' || plan.status == 'holding')
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _showCloseTradeSheet(plan),
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(
                      l10n.action_close_trade,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (plan.status == 'armed' || plan.status == 'holding') ...[
          const SizedBox(height: 16),
          Text(
            l10n.tip_plan_locked,
            style: const TextStyle(fontSize: 12, color: AppColors.textWeak),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => _showReviseTargetSheet(plan),
              icon: const Icon(Icons.track_changes),
              label: Text(
                l10n.action_revise_target,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                foregroundColor: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEditsList(BuildContext context, List<PlanEdit> edits) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.label_edit_history,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        ...edits.map((edit) => _buildEditItem(edit)),
      ],
    );
  }

  Widget _buildEditItem(PlanEdit edit) {
    final dateStr = DateFormat(
      'MM-dd HH:mm',
    ).format(DateTime.fromMillisecondsSinceEpoch(edit.editedAt * 1000));
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondaryBlock,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
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
                  color: AppColors.textMain,
                ),
              ),
              Text(
                dateStr,
                style: const TextStyle(fontSize: 11, color: AppColors.textWeak),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${edit.oldValue} -> ${edit.newValue}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
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
