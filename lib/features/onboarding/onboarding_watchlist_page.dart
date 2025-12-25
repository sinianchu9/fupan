import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fupan/l10n/generated/app_localizations.dart';
import '../../core/providers.dart';
import '../../models/symbol.dart';
import '../../models/watchlist_item.dart';
import '../shell/main_shell.dart';

class OnboardingWatchlistPage extends ConsumerStatefulWidget {
  final bool isStandalone;

  const OnboardingWatchlistPage({super.key, this.isStandalone = false});

  @override
  ConsumerState<OnboardingWatchlistPage> createState() =>
      _OnboardingWatchlistPageState();
}

class _OnboardingWatchlistPageState
    extends ConsumerState<OnboardingWatchlistPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<StockSymbol> _searchResults = [];
  List<WatchlistItem> _watchlist = [];
  String? _selectedIndustry;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchWatchlist();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchWatchlist() async {
    setState(() => _isLoading = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get('/watchlist');
      if (response.data['ok'] == true) {
        final List items = response.data['items'] ?? [];
        setState(() {
          _watchlist = items.map((e) => WatchlistItem.fromJson(e)).toList();
        });
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      _showError(l10n.tip_fetch_failed(e.toString()));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        setState(() => _searchResults = []);
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get(
        '/symbols',
        queryParameters: {'q': query},
      );
      if (response.data['ok'] == true) {
        final List items = response.data['items'] ?? [];
        setState(() {
          _searchResults = items.map((e) => StockSymbol.fromJson(e)).toList();
        });
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      _showError(l10n.tip_fetch_failed(e.toString()));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addToWatchlist(StockSymbol symbol) async {
    setState(() => _isLoading = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(
        '/watchlist/add',
        data: {'symbol_id': symbol.id},
      );
      if (response.data['ok'] == true) {
        await _fetchWatchlist();
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.tip_added_symbol(symbol.name))),
          );
        }
      }
    } catch (e) {
      if (e.toString().contains('403')) {
        _showSubscriptionLimitDialog();
      } else {
        final l10n = AppLocalizations.of(context)!;
        _showError(l10n.tip_submit_failed(e.toString()));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFromWatchlist(WatchlistItem item) async {
    setState(() => _isLoading = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(
        '/watchlist/remove',
        data: {'symbol_id': item.symbolId},
      );
      if (response.data['ok'] == true) {
        await _fetchWatchlist();
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      _showError(l10n.tip_submit_failed(e.toString()));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _seedData() async {
    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(
        '/symbols/seed',
        data: {
          'items': [
            {'code': '600519', 'name': '贵州茅台', 'industry': '白酒'},
            {'code': '000001', 'name': '平安银行', 'industry': '银行'},
            {'code': '300750', 'name': '宁德时代', 'industry': '锂电池'},
            {'code': '000651', 'name': '格力电器', 'industry': '家电'},
            {'code': '601318', 'name': '中国平安', 'industry': '保险'},
          ],
        },
      );
      if (response.data['ok'] == true) {
        _showError(l10n.tip_seed_success);
        setState(() => _searchResults = []);
      }
    } catch (e) {
      _showError(l10n.tip_seed_failed(e.toString()));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSubscriptionLimitDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.title_subscription_limit),
        content: Text(l10n.tip_subscription_limit_msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.action_confirm),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.action_learn_more_upgrade),
          ),
        ],
      ),
    );
  }

  List<String> get _industries {
    final industries = _searchResults.map((s) => s.industry).toSet().toList();
    industries.sort();
    return industries;
  }

  List<StockSymbol> get _filteredResults {
    if (_selectedIndustry == null) return _searchResults;
    return _searchResults
        .where((s) => s.industry == _selectedIndustry)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isStandalone
              ? l10n.title_manage_watchlist
              : l10n.title_select_watchlist,
        ),
        automaticallyImplyLeading: widget.isStandalone,
      ),
      body: Column(
        children: [
          if (!widget.isStandalone)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                l10n.tip_add_at_least_one,
                style: const TextStyle(color: Colors.grey),
              ),
            ),

          // 搜索框
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.hint_search_symbol,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // 行业筛选 (Chip)
          if (_searchResults.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(l10n.label_all_industries),
                      selected: _selectedIndustry == null,
                      onSelected: (selected) {
                        setState(() => _selectedIndustry = null);
                      },
                    ),
                  ),
                  ..._industries.map(
                    (industry) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(industry),
                        selected: _selectedIndustry == industry,
                        onSelected: (selected) {
                          setState(() => _selectedIndustry = industry);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 搜索结果
          Expanded(
            child:
                _searchResults.isEmpty &&
                    _searchController.text.isNotEmpty &&
                    !_isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l10n.tip_symbol_not_found),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _seedData,
                          icon: const Icon(Icons.data_usage),
                          label: Text(l10n.action_seed_data),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredResults.length,
                    itemBuilder: (context, index) {
                      final symbol = _filteredResults[index];
                      final isAdded = _watchlist.any(
                        (w) => w.symbolId == symbol.id,
                      );
                      return ListTile(
                        title: Text(
                          '${symbol.code} ${symbol.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          symbol.industry,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: isAdded
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : ElevatedButton(
                                onPressed: () => _addToWatchlist(symbol),
                                child: Text(l10n.action_add),
                              ),
                      );
                    },
                  ),
          ),

          // 已添加区域
          if (_watchlist.isNotEmpty) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.list, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    l10n.label_added,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _watchlist.length,
                itemBuilder: (context, index) {
                  final item = _watchlist[index];
                  return Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 12, bottom: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.code,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                onPressed: () => _removeFromWatchlist(item),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          item.name,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Text(
                          item.industry,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],

          // 底部按钮
          if (!widget.isStandalone)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _watchlist.isEmpty
                        ? null
                        : () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const MainShell(),
                              ),
                              (route) => false,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.action_enter_app,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
