import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  String _selectedIndustry = '全部行业';
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
      _showError('获取自选列表失败: $e');
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
      _showError('搜索失败: $e');
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('已添加 ${symbol.name}')));
      }
    } catch (e) {
      if (e.toString().contains('403')) {
        _showSubscriptionLimitDialog();
      } else {
        _showError('添加失败: $e');
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
      _showError('移除失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _seedData() async {
    setState(() => _isLoading = true);
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
        _showError('测试数据灌入成功，请重新搜索');
        setState(() => _searchResults = []);
      }
    } catch (e) {
      _showError('灌入失败: $e\n请确保已运行 npx wrangler d1 execute ... 初始化数据库');
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('订阅限制'),
        content: const Text('免费版仅可添加 1 只股票。请升级以解锁更多名额。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('了解升级'),
          ),
        ],
      ),
    );
  }

  List<String> get _industries {
    final industries = _searchResults.map((s) => s.industry).toSet().toList();
    industries.sort();
    return ['全部行业', ...industries];
  }

  List<StockSymbol> get _filteredResults {
    if (_selectedIndustry == '全部行业') return _searchResults;
    return _searchResults
        .where((s) => s.industry == _selectedIndustry)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isStandalone ? '管理关注股票' : '选择你关注的股票'),
        automaticallyImplyLeading: widget.isStandalone,
      ),
      body: Column(
        children: [
          if (!widget.isStandalone)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '请至少添加 1 只股票以开始使用',
                style: TextStyle(color: Colors.grey),
              ),
            ),

          // 搜索框
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '输入代码/名称/行业',
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
                children: _industries
                    .map(
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
                    )
                    .toList(),
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
                        const Text('未找到相关股票'),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _seedData,
                          icon: const Icon(Icons.data_usage),
                          label: const Text('灌入测试数据 (Seed)'),
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
                        title: Text('${symbol.code} ${symbol.name}'),
                        subtitle: Text(symbol.industry),
                        trailing: isAdded
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : ElevatedButton(
                                onPressed: () => _addToWatchlist(symbol),
                                child: const Text('添加'),
                              ),
                      );
                    },
                  ),
          ),

          // 已添加区域
          if (_watchlist.isNotEmpty) ...[
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.list, size: 18),
                  SizedBox(width: 8),
                  Text('已添加', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                            GestureDetector(
                              onTap: () => _removeFromWatchlist(item),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.grey,
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
            Padding(
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
                  child: const Text(
                    '进入应用',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
