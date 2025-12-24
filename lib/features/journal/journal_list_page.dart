import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../models/plan_list_item.dart';
import 'create_plan_page.dart';
import 'plan_detail_page.dart';
import 'archived_plans_page.dart';

class JournalListPage extends ConsumerStatefulWidget {
  const JournalListPage({super.key});

  @override
  ConsumerState<JournalListPage> createState() => _JournalListPageState();
}

class _JournalListPageState extends ConsumerState<JournalListPage> {
  bool _isLoading = false;
  List<PlanListItem> _plans = [];
  int _watchlistCount = 0;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    try {
      final apiClient = ref.read(apiClientProvider);

      // 并行拉取 watchlist 数量和计划列表
      final results = await Future.wait([
        apiClient.getWatchlist(),
        apiClient.getPlans(),
      ]);

      if (!mounted) return;
      final watchlistItems = results[0] as List;
      final planItems = results[1] as List;

      setState(() {
        _watchlistCount = watchlistItems.length;
        _plans = planItems.map((e) => PlanListItem.fromJson(e)).toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('获取数据失败: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('交易复盘'),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            tooltip: '已归档计划',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ArchivedPlansPage()),
              ).then((_) => _refresh());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Column(
          children: [
            // 顶部信息条
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withAlpha(76),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '已关注 $_watchlistCount 只股票',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CreatePlanPage(),
                        ),
                      );
                      if (result == true) {
                        _refresh();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('新建计划'),
                  ),
                ],
              ),
            ),

            // 列表
            Expanded(
              child: _isLoading && _plans.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _plans.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.2,
                        ),
                        const Center(
                          child: Column(
                            children: [
                              Text(
                                '还没有交易计划',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '先写计划再交易，强化交易纪律',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: _plans.length,
                      itemBuilder: (context, index) {
                        final plan = _plans[index];
                        return _buildPlanCard(plan);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(PlanListItem plan) {
    final dateStr = DateFormat(
      'yyyy-MM-dd HH:mm',
    ).format(DateTime.fromMillisecondsSinceEpoch(plan.updatedAt * 1000));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PlanDetailPage(planId: plan.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${plan.symbolCode} ${plan.symbolName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          plan.symbolIndustry,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(plan.status).withAlpha(25),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _getStatusColor(plan.status).withAlpha(128),
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
                  ),
                  _buildCardMenu(plan),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                plan.buyReasonText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '目标区间: ${plan.targetLow} ~ ${plan.targetHigh}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Text(
                    dateStr,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardMenu(PlanListItem plan) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
      padding: EdgeInsets.zero,
      onSelected: (v) {
        if (v == 'archive') {
          _archivePlan(plan.id);
        } else if (v == 'detail') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PlanDetailPage(planId: plan.id),
            ),
          ).then((_) => _refresh());
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'archive',
          child: Row(
            children: [
              Icon(Icons.archive_outlined, size: 18),
              SizedBox(width: 8),
              Text('归档'),
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

  Future<void> _archivePlan(String planId) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.archivePlan(planId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已归档，可在已归档中查看')),
      );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('归档失败: $e')),
      );
    }
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
