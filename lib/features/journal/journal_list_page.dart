import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fupan/l10n/generated/app_localizations.dart';
import '../../core/providers.dart';
import '../../core/locale_provider.dart';
import '../../core/theme.dart';
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

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      final planItems = await apiClient.getPlans();

      if (!mounted) return;
      setState(() {
        _plans = (planItems as List)
            .map((e) => PlanListItem.fromJson(e))
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tip_fetch_failed(e.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showLanguageSheet(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.read(localeProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    l10n.action_switch_language,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Text('🇨🇳', style: TextStyle(fontSize: 24)),
                  title: Text(l10n.label_language_zh),
                  trailing: currentLocale?.languageCode == 'zh'
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    ref
                        .read(localeProvider.notifier)
                        .setLocale(const Locale('zh'));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                  title: Text(l10n.label_language_en),
                  trailing: currentLocale?.languageCode == 'en'
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    ref
                        .read(localeProvider.notifier)
                        .setLocale(const Locale('en'));
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.title_journal),
        actions: [
          // Language switch button
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: l10n.action_switch_language,
            onPressed: () => _showLanguageSheet(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            tooltip: l10n.title_archived_plans,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ArchivedPlansPage(),
                ),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.card,
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.label_discipline_score,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '85.5',
                          style: TextStyle(
                            color: AppColors.goldMain,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 40),
                      child: ElevatedButton.icon(
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
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(
                          l10n.action_create_plan,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
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
                        Center(
                          child: Column(
                            children: [
                              Text(
                                l10n.tip_no_plans,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.tip_no_plans_sub,
                                style: const TextStyle(color: Colors.grey),
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppTheme.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
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
                              color: AppColors.textMain,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            plan.symbolIndustry,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(context, plan.status),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateStr,
                      style: const TextStyle(
                        color: AppColors.textWeak,
                        fontSize: 12,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppColors.textWeak,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    Color color;
    String display;
    switch (status) {
      case 'draft':
        color = Colors.grey;
        display = l10n.status_draft;
        break;
      case 'armed':
        color = Colors.blue;
        display = l10n.status_armed;
        break;
      case 'holding':
        color = Colors.orange;
        display = l10n.status_holding;
        break;
      case 'closed':
        color = Colors.green;
        display = l10n.status_closed;
        break;
      default:
        color = Colors.grey;
        display = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(128)),
      ),
      child: Text(
        display,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
