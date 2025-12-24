import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../models/plan_list_item.dart';
import 'plan_detail_page.dart';

class ArchivedPlansPage extends ConsumerStatefulWidget {
  const ArchivedPlansPage({super.key});

  @override
  ConsumerState<ArchivedPlansPage> createState() => _ArchivedPlansPageState();
}

class _ArchivedPlansPageState extends ConsumerState<ArchivedPlansPage> {
  bool _isLoading = true;
  List<PlanListItem> _plans = [];
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    setState(() => _isLoading = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      final data = await apiClient.getArchivedPlans(status: _statusFilter);
      if (!mounted) return;
      setState(() {
        _plans = data.map((e) => PlanListItem.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载失败: $e')));
      setState(() => _isLoading = false);
    }
  }

  Future<void> _unarchivePlan(String planId) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.unarchivePlan(planId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已取消归档')));
      _fetchPlans();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('操作失败: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('已归档计划'),
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (v) {
              setState(() => _statusFilter = v);
              _fetchPlans();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('全部状态')),
              const PopupMenuItem(value: 'draft', child: Text('草稿')),
              const PopupMenuItem(value: 'armed', child: Text('已武装')),
              const PopupMenuItem(value: 'holding', child: Text('持仓')),
              const PopupMenuItem(value: 'closed', child: Text('已结束')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPlans,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _plans.isEmpty
            ? const Center(child: Text('暂无归档计划'))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _plans.length,
                itemBuilder: (context, index) {
                  final plan = _plans[index];
                  return _buildPlanCard(plan);
                },
              ),
      ),
    );
  }

  Widget _buildPlanCard(PlanListItem plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          final needRefresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlanDetailPage(planId: plan.id),
            ),
          );
          if (needRefresh == true) _fetchPlans();
        },
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
                      '${plan.symbolCode} ${plan.symbolName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusBadge(plan),
                  const SizedBox(width: 8),
                  _buildCardMenu(plan),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                plan.buyReasonText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '目标: ${plan.targetLow} ~ ${plan.targetHigh}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Text(
                    '方向: ${plan.direction == 'long' ? '做多' : '做空'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: plan.direction == 'long'
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PlanListItem plan) {
    Color color = Colors.grey;
    if (plan.status == 'armed') color = Colors.blue;
    if (plan.status == 'holding') color = Colors.orange;
    if (plan.status == 'closed') color = Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        plan.statusDisplay,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCardMenu(PlanListItem plan) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
      padding: EdgeInsets.zero,
      onSelected: (v) {
        if (v == 'unarchive') {
          _unarchivePlan(plan.id);
        } else if (v == 'detail') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlanDetailPage(planId: plan.id),
            ),
          ).then((_) => _fetchPlans());
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'unarchive',
          child: Row(
            children: [
              Icon(Icons.unarchive_outlined, size: 18),
              SizedBox(width: 8),
              Text('取消归档'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'detail',
          child: Row(
            children: [
              Icon(Icons.description_outlined, size: 18),
              SizedBox(width: 8),
              Text('查看详情'),
            ],
          ),
        ),
      ],
    );
  }
}
