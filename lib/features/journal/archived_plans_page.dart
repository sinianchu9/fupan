import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fupan/l10n/generated/app_localizations.dart';
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tip_fetch_failed(e.toString()))),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _unarchivePlan(String planId) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.unarchivePlan(planId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.tip_unarchived_success)));
      _fetchPlans();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tip_submit_failed(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.title_archived_plans),
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (v) {
              setState(() => _statusFilter = v);
              _fetchPlans();
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: null, child: Text(l10n.label_all_statuses)),
              PopupMenuItem(value: 'draft', child: Text(l10n.status_draft)),
              PopupMenuItem(value: 'armed', child: Text(l10n.status_armed)),
              PopupMenuItem(value: 'holding', child: Text(l10n.status_holding)),
              PopupMenuItem(value: 'closed', child: Text(l10n.status_closed)),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPlans,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _plans.isEmpty
            ? Center(child: Text(l10n.tip_no_archived_plans))
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
    final l10n = AppLocalizations.of(context)!;
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                    l10n.label_target_range_with_values(
                      plan.targetLow.toString(),
                      plan.targetHigh.toString(),
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Text(
                    l10n.label_direction_with_value(
                      plan.direction == 'long'
                          ? l10n.label_long
                          : l10n.label_short,
                    ),
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
    final l10n = AppLocalizations.of(context)!;
    Color color = Colors.grey;
    String label = l10n.status_draft;

    if (plan.status == 'armed') {
      color = Colors.blue;
      label = l10n.status_armed;
    } else if (plan.status == 'holding') {
      color = Colors.orange;
      label = l10n.status_holding;
    } else if (plan.status == 'closed') {
      color = Colors.green;
      label = l10n.status_closed;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(75)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCardMenu(PlanListItem plan) {
    final l10n = AppLocalizations.of(context)!;
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
        PopupMenuItem(
          value: 'unarchive',
          child: Row(
            children: [
              const Icon(Icons.unarchive_outlined, size: 18),
              const SizedBox(width: 8),
              Text(l10n.action_unarchive),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'detail',
          child: Row(
            children: [
              const Icon(Icons.description_outlined, size: 18),
              const SizedBox(width: 8),
              Text(l10n.action_view_detail),
            ],
          ),
        ),
      ],
    );
  }
}
