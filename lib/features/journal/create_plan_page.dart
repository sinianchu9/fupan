import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fupan/l10n/generated/app_localizations.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../models/watchlist_item.dart';
import '../plan/widgets/add_symbol_sheet.dart';

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

  Map<String, String> _getBuyReasonTypes(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return {
      'trend': l10n.reason_trend,
      'range': l10n.reason_range,
      'policy': l10n.reason_policy,
      'industry': l10n.reason_industry,
      'earnings': l10n.reason_earnings,
      'sentiment': l10n.reason_sentiment,
      'probe': l10n.reason_probe,
      'other': l10n.reason_other,
    };
  }

  Map<String, String> _getTargetTypes(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return {
      'technical': l10n.target_technical,
      'previous_high': l10n.target_previous_high,
      'event': l10n.target_event,
      'trend': l10n.target_trend,
    };
  }

  Map<String, String> _getSellConditions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return {
      'reach_target': l10n.logic_reach_target,
      'volume_exhaust': l10n.logic_volume_exhaust,
      'trend_break': l10n.logic_trend_break,
      'thesis_invalidated': l10n.logic_thesis_invalidated,
      'time_take_profit': l10n.logic_time_take_profit,
    };
  }

  Map<String, String> _getStopTypes(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return {
      'technical': l10n.stop_technical,
      'time': l10n.stop_time,
      'logic_fail': l10n.stop_logic_fail,
      'max_loss': l10n.stop_max_loss,
    };
  }

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
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.tip_fetch_failed(e.toString()))),
        );
      }
      setState(() => _isFetchingWatchlist = false);
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBuyReasons.isEmpty) {
      _showError(l10n.tip_select_buy_reason);
      return;
    }
    if (_selectedSellConditions.isEmpty) {
      _showError(l10n.tip_select_sell_logic);
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
        'planned_entry_price': double.tryParse(_entryPriceController.text),
      };

      await apiClient.createPlan(data);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showError(l10n.tip_submit_failed(e.toString()));
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
    final l10n = AppLocalizations.of(context)!;
    if (_isFetchingWatchlist) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_watchlist.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.title_create_plan)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.tip_watchlist_empty),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.action_back),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.title_create_plan),
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
                l10n.action_save_draft,
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
            _buildSectionTitle(l10n.label_symbol_selection),
            _buildSymbolPicker(),
            const SizedBox(height: 24),

            _buildSectionTitle(l10n.label_buy_reason),
            _buildBuyReasonTypes(context),
            const SizedBox(height: 16),
            TextFormField(
              controller: _buyReasonTextController,
              decoration: InputDecoration(
                labelText: l10n.label_buy_reason_one_liner,
                hintText: l10n.hint_buy_reason_one_liner,
                border: const OutlineInputBorder(),
              ),
              maxLength: 50,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.tip_required : null,
            ),
            const SizedBox(height: 24),

            _buildSectionTitle(l10n.label_target_sell_price),
            _buildTargetTypePicker(context),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _targetLowController,
                    decoration: InputDecoration(
                      labelText: l10n.label_target_low,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? l10n.tip_required : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _targetHighController,
                    decoration: InputDecoration(
                      labelText: l10n.label_target_high,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return l10n.tip_required;
                      final high = double.tryParse(v);
                      final low = double.tryParse(_targetLowController.text);
                      if (high != null && low != null && high <= low) {
                        return l10n.tip_greater_than_low;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionTitle(l10n.label_sell_logic_expected),
            _buildSellConditions(context),
            const SizedBox(height: 24),

            _buildSectionTitle(l10n.label_expected_entry_price),
            TextFormField(
              controller: _entryPriceController,
              decoration: InputDecoration(
                labelText: l10n.label_expected_entry_price,
                hintText: '输入计划买入的价格，用于计算建仓偏离',
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 24),
            if (_selectedSellConditions.contains('time_take_profit')) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeTakeProfitDaysController,
                decoration: InputDecoration(
                  labelText: l10n.label_time_take_profit_days,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.tip_required;
                  final days = int.tryParse(v);
                  if (days == null || days < 1) {
                    return l10n.tip_greater_than_zero;
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 24),

            _buildSectionTitle(l10n.label_stop_loss_logic),
            _buildStopTypePicker(context),
            const SizedBox(height: 16),
            _buildStopTypeFields(context),
            const SizedBox(height: 24),

            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(
                  l10n.label_advanced_options,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                children: [
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _direction,
                    decoration: InputDecoration(
                      labelText: l10n.label_trade_direction,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'long',
                        child: Text(l10n.label_long),
                      ),
                      DropdownMenuItem(
                        value: 'short',
                        child: Text(l10n.label_short),
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
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: _selectedSymbolId,
            isExpanded: true,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: _watchlist
                .map(
                  (s) => DropdownMenuItem(
                    value: s.symbolId,
                    child: Text(
                      '${s.code} ${s.name}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _selectedSymbolId = v),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _openAddSymbolSheet,
          icon: const Icon(Icons.add_circle_outline, color: AppColors.goldMain),
          tooltip: '添加股票',
        ),
      ],
    );
  }

  Future<void> _openAddSymbolSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddSymbolSheet(),
    );

    if (result != null) {
      // Add to local watchlist and select it
      final newItem = WatchlistItem(
        symbolId: result['symbolId'],
        code: result['code'],
        name: result['name'],
        industry: result['industry'],
        createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

      setState(() {
        _watchlist.insert(0, newItem);
        _selectedSymbolId = newItem.symbolId;
      });
    }
  }

  Widget _buildBuyReasonTypes(BuildContext context) {
    final buyReasonTypes = _getBuyReasonTypes(context);
    return Wrap(
      spacing: 8,
      children: buyReasonTypes.entries.map((e) {
        final isSelected = _selectedBuyReasons.contains(e.key);
        return FilterChip(
          label: Text(e.value, maxLines: 1, overflow: TextOverflow.ellipsis),
          selected: isSelected,
          visualDensity: const VisualDensity(horizontal: 0, vertical: 2),
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

  Widget _buildTargetTypePicker(BuildContext context) {
    final targetTypes = _getTargetTypes(context);
    return Wrap(
      spacing: 8,
      children: targetTypes.entries.map((e) {
        return ChoiceChip(
          label: Text(e.value, maxLines: 1, overflow: TextOverflow.ellipsis),
          selected: _targetType == e.key,
          visualDensity: const VisualDensity(horizontal: 0, vertical: 2),
          onSelected: (selected) {
            if (selected) setState(() => _targetType = e.key);
          },
        );
      }).toList(),
    );
  }

  Widget _buildSellConditions(BuildContext context) {
    final sellConditions = _getSellConditions(context);
    return Wrap(
      spacing: 8,
      children: sellConditions.entries.map((e) {
        final isSelected = _selectedSellConditions.contains(e.key);
        return FilterChip(
          label: Text(e.value, maxLines: 1, overflow: TextOverflow.ellipsis),
          selected: isSelected,
          visualDensity: const VisualDensity(horizontal: 0, vertical: 2),
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

  Widget _buildStopTypePicker(BuildContext context) {
    final stopTypes = _getStopTypes(context);
    return Wrap(
      spacing: 8,
      children: stopTypes.entries.map((e) {
        return ChoiceChip(
          label: Text(e.value, maxLines: 1, overflow: TextOverflow.ellipsis),
          selected: _stopType == e.key,
          visualDensity: const VisualDensity(horizontal: 0, vertical: 2),
          onSelected: (selected) {
            if (selected) setState(() => _stopType = e.key);
          },
        );
      }).toList(),
    );
  }

  Widget _buildStopTypeFields(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_stopType == 'technical') {
      return TextFormField(
        controller: _stopValueController,
        decoration: InputDecoration(
          labelText: l10n.label_stop_price,
          border: const OutlineInputBorder(),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (v) => (v == null || v.isEmpty) ? l10n.tip_required : null,
      );
    } else if (_stopType == 'time') {
      return TextFormField(
        controller: _stopTimeDaysController,
        decoration: InputDecoration(
          labelText: l10n.label_stop_days,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        validator: (v) => (v == null || v.isEmpty) ? l10n.tip_required : null,
      );
    } else if (_stopType == 'max_loss') {
      return TextFormField(
        controller: _stopValueController,
        decoration: InputDecoration(
          labelText: l10n.label_max_loss_percent,
          hintText: l10n.hint_max_loss,
          border: const OutlineInputBorder(),
          suffixText: '%',
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (v) {
          if (v == null || v.isEmpty) return l10n.tip_required;
          final val = double.tryParse(v);
          if (val == null || val <= 0 || val > 100) {
            return l10n.tip_invalid_loss_percent;
          }
          return null;
        },
      );
    }
    return const SizedBox.shrink();
  }
}
