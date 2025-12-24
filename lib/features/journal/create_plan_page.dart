import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../models/watchlist_item.dart';

class CreatePlanPage extends ConsumerStatefulWidget {
  const CreatePlanPage({super.key});

  @override
  ConsumerState<CreatePlanPage> createState() => _CreatePlanPageState();
}

class _CreatePlanPageState extends ConsumerState<CreatePlanPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isFetchingWatchlist = true;
  List<WatchlistItem> _watchlist = [];

  // Form Fields
  String? _selectedSymbolId;
  String _direction = 'long';
  final List<String> _selectedBuyReasons = [];
  final TextEditingController _buyReasonTextController =
      TextEditingController();
  String _targetType = 'technical';
  final TextEditingController _targetLowController = TextEditingController();
  final TextEditingController _targetHighController = TextEditingController();
  final List<String> _selectedSellConditions = [];
  final TextEditingController _timeTakeProfitDaysController =
      TextEditingController();
  String _stopType = 'technical';
  final TextEditingController _stopValueController = TextEditingController();
  final TextEditingController _stopTimeDaysController = TextEditingController();
  final TextEditingController _entryPriceController = TextEditingController();

  // Data Dictionaries
  final Map<String, String> _buyReasonTypes = {
    'trend': '趋势',
    'range': '震荡',
    'policy': '政策',
    'industry': '行业',
    'earnings': '财报',
    'sentiment': '情绪',
    'probe': '试仓',
    'other': '其他',
  };

  final Map<String, String> _targetTypes = {
    'technical': '技术位',
    'previous_high': '前高',
    'event': '事件兑现',
    'trend': '趋势延续',
  };

  final Map<String, String> _sellConditions = {
    'reach_target': '到达目标区',
    'volume_exhaust': '量能衰竭',
    'trend_break': '趋势破坏',
    'thesis_invalidated': '消息证伪',
    'time_take_profit': '时间止盈',
  };

  final Map<String, String> _stopTypes = {
    'technical': '技术位',
    'time': '时间',
    'logic_fail': '逻辑失效',
    'max_loss': '最大亏损',
  };

  @override
  void initState() {
    super.initState();
    _fetchWatchlist();
  }

  @override
  void dispose() {
    _buyReasonTextController.dispose();
    _targetLowController.dispose();
    _targetHighController.dispose();
    _timeTakeProfitDaysController.dispose();
    _stopValueController.dispose();
    _stopTimeDaysController.dispose();
    _entryPriceController.dispose();
    super.dispose();
  }

  Future<void> _fetchWatchlist() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final items = await apiClient.getWatchlist();
      setState(() {
        _watchlist = items.map((e) => WatchlistItem.fromJson(e)).toList();
        if (_watchlist.isNotEmpty) {
          _selectedSymbolId = _watchlist.first.symbolId;
        }
        _isFetchingWatchlist = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('获取自选股失败: $e')));
      setState(() => _isFetchingWatchlist = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBuyReasons.isEmpty) {
      _showError('请至少选择一个买入理由类型');
      return;
    }
    if (_selectedSellConditions.isEmpty) {
      _showError('请至少选择一个卖出逻辑');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final apiClient = ref.read(apiClientProvider);

      final data = {
        'symbol_id': _selectedSymbolId,
        'direction': _direction,
        'buy_reason_types': _selectedBuyReasons,
        'buy_reason_text': _buyReasonTextController.text,
        'target_type': _targetType,
        'target_low': double.parse(_targetLowController.text),
        'target_high': double.parse(_targetHighController.text),
        'sell_conditions': _selectedSellConditions,
        'time_take_profit_days':
            _selectedSellConditions.contains('time_take_profit')
            ? int.tryParse(_timeTakeProfitDaysController.text)
            : null,
        'stop_type': _stopType,
        'stop_value': (_stopType == 'technical' || _stopType == 'max_loss')
            ? double.tryParse(_stopValueController.text)
            : null,
        'stop_time_days': _stopType == 'time'
            ? int.tryParse(_stopTimeDaysController.text)
            : null,
        'entry_price': double.tryParse(_entryPriceController.text),
      };

      await apiClient.createPlan(data);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showError('提交失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetchingWatchlist) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_watchlist.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('新建交易计划')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('自选股为空，请先添加股票'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('新建交易计划'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _isLoading ? null : _submit,
              child: Text(
                '保存草稿',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _isLoading ? Colors.grey : null,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('股票选择'),
            _buildSymbolPicker(),
            const SizedBox(height: 24),

            _buildSectionTitle('买入理由'),
            _buildBuyReasonTypes(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _buyReasonTextController,
              decoration: const InputDecoration(
                labelText: '一句话理由',
                hintText: '用人话说一句 (50字以内)',
                border: OutlineInputBorder(),
              ),
              maxLength: 50,
              validator: (v) => (v == null || v.trim().isEmpty) ? '必填' : null,
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('预期卖出目标'),
            _buildTargetTypePicker(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _targetLowController,
                    decoration: const InputDecoration(
                      labelText: '目标低位',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? '必填' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _targetHighController,
                    decoration: const InputDecoration(
                      labelText: '目标高位',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return '必填';
                      final high = double.tryParse(v);
                      final low = double.tryParse(_targetLowController.text);
                      if (high != null && low != null && high <= low) {
                        return '须大于低位';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('预期卖出逻辑'),
            _buildSellConditions(),
            if (_selectedSellConditions.contains('time_take_profit')) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeTakeProfitDaysController,
                decoration: const InputDecoration(
                  labelText: '时间止盈天数',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return '必填';
                  final days = int.tryParse(v);
                  if (days == null || days < 1) return '须 >= 1';
                  return null;
                },
              ),
            ],
            const SizedBox(height: 24),

            _buildSectionTitle('止损逻辑'),
            _buildStopTypePicker(),
            const SizedBox(height: 16),
            _buildStopTypeFields(),
            const SizedBox(height: 24),

            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: const Text(
                  '高级选项',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                children: [
                  TextFormField(
                    controller: _entryPriceController,
                    decoration: const InputDecoration(
                      labelText: '预期买入价 (可选)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _direction,
                    decoration: const InputDecoration(
                      labelText: '交易方向',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'long', child: Text('做多 (Long)')),
                      DropdownMenuItem(
                        value: 'short',
                        child: Text('做空 (Short)'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _direction = v!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _buildSymbolPicker() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedSymbolId,
      decoration: const InputDecoration(border: OutlineInputBorder()),
      items: _watchlist
          .map(
            (s) => DropdownMenuItem(
              value: s.symbolId,
              child: Text('${s.code} ${s.name}'),
            ),
          )
          .toList(),
      onChanged: (v) => setState(() => _selectedSymbolId = v),
    );
  }

  Widget _buildBuyReasonTypes() {
    return Wrap(
      spacing: 8,
      children: _buyReasonTypes.entries.map((e) {
        final isSelected = _selectedBuyReasons.contains(e.key);
        return FilterChip(
          label: Text(e.value),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedBuyReasons.add(e.key);
              } else {
                _selectedBuyReasons.remove(e.key);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildTargetTypePicker() {
    return Wrap(
      spacing: 8,
      children: _targetTypes.entries.map((e) {
        return ChoiceChip(
          label: Text(e.value),
          selected: _targetType == e.key,
          onSelected: (selected) {
            if (selected) setState(() => _targetType = e.key);
          },
        );
      }).toList(),
    );
  }

  Widget _buildSellConditions() {
    return Wrap(
      spacing: 8,
      children: _sellConditions.entries.map((e) {
        final isSelected = _selectedSellConditions.contains(e.key);
        return FilterChip(
          label: Text(e.value),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedSellConditions.add(e.key);
              } else {
                _selectedSellConditions.remove(e.key);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildStopTypePicker() {
    return Wrap(
      spacing: 8,
      children: _stopTypes.entries.map((e) {
        return ChoiceChip(
          label: Text(e.value),
          selected: _stopType == e.key,
          onSelected: (selected) {
            if (selected) setState(() => _stopType = e.key);
          },
        );
      }).toList(),
    );
  }

  Widget _buildStopTypeFields() {
    if (_stopType == 'technical') {
      return TextFormField(
        controller: _stopValueController,
        decoration: const InputDecoration(
          labelText: '止损价',
          border: OutlineInputBorder(),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (v) => (v == null || v.isEmpty) ? '必填' : null,
      );
    } else if (_stopType == 'time') {
      return TextFormField(
        controller: _stopTimeDaysController,
        decoration: const InputDecoration(
          labelText: '止损天数',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        validator: (v) => (v == null || v.isEmpty) ? '必填' : null,
      );
    } else if (_stopType == 'max_loss') {
      return TextFormField(
        controller: _stopValueController,
        decoration: const InputDecoration(
          labelText: '最大亏损 (%)',
          hintText: '例如 5 表示 5%',
          border: OutlineInputBorder(),
          suffixText: '%',
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (v) {
          if (v == null || v.isEmpty) return '必填';
          final val = double.tryParse(v);
          if (val == null || val <= 0 || val > 100) return '请输入 1~100';
          return null;
        },
      );
    }
    return const SizedBox.shrink();
  }
}
