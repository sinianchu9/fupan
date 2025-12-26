import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fupan/l10n/generated/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/theme.dart';
import '../../../models/add_event_request.dart';

class AddEventSheet extends ConsumerStatefulWidget {
  final String planId;
  final VoidCallback onSuccess;

  const AddEventSheet({
    super.key,
    required this.planId,
    required this.onSuccess,
  });

  @override
  ConsumerState<AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends ConsumerState<AddEventSheet> {
  final _formKey = GlobalKey<FormState>();
  final _summaryController = TextEditingController();
  final _priceController = TextEditingController();

  String _eventType = 'verify';
  String _impactTarget = 'sell';
  String _eventStage = 'exit_deviation';
  String? _behaviorDriver;
  bool _triggeredExit = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _summaryController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  List<String> _getDriversForStage(String stage) {
    switch (stage) {
      case 'entry_deviation':
        return [
          'driver_fomo_short',
          'driver_wait_failed_short',
          'driver_other_short',
        ];
      case 'entry_non_action':
        return [
          'driver_fear',
          'driver_wait_failed_short',
          'driver_other_short',
        ];
      case 'exit_deviation':
        return [
          'driver_early_profit',
          'driver_fear_drawdown',
          'driver_emotion_fear',
          'driver_lower_target',
          'driver_other_short',
        ];
      case 'stoploss_deviation':
        return [
          'driver_fear',
          'driver_wait_failed_short',
          'driver_other_short',
        ];
      case 'external_change':
        return [
          'driver_logic_broken',
          'driver_market_crash',
          'driver_profit_protect',
          'driver_other_short',
        ];
      default:
        return ['driver_other_short'];
    }
  }

  String _getDriverLabel(BuildContext context, String driver) {
    final l10n = AppLocalizations.of(context)!;
    switch (driver) {
      case 'driver_early_profit':
        return l10n.driver_early_profit;
      case 'driver_fear_drawdown':
        return l10n.driver_fear_drawdown;
      case 'driver_emotion_fear':
        return l10n.driver_emotion_fear;
      case 'driver_lower_target':
        return l10n.driver_lower_target;
      case 'driver_fomo_short':
        return l10n.driver_fomo_short;
      case 'driver_fear':
        return l10n.driver_fear;
      case 'driver_wait_failed_short':
        return l10n.driver_wait_failed_short;
      case 'driver_logic_broken':
        return l10n.driver_logic_broken;
      case 'driver_market_crash':
        return l10n.driver_market_crash;
      case 'driver_profit_protect':
        return l10n.driver_profit_protect;
      case 'driver_revenge':
        return l10n.driver_revenge;
      case 'driver_other_short':
        return l10n.driver_other_short;
      default:
        return driver;
    }
  }

  String _getStageLabel(BuildContext context, String stage) {
    final l10n = AppLocalizations.of(context)!;
    switch (stage) {
      case 'entry_deviation':
        return l10n.stage_entry_deviation;
      case 'entry_non_action':
        return l10n.stage_entry_non_action;
      case 'exit_deviation':
        return l10n.stage_exit_deviation;
      case 'stoploss_deviation':
        return l10n.stage_stoploss_deviation;
      case 'external_change':
        return l10n.stage_external_change;
      default:
        return stage;
    }
  }

  String _getTypeLabel(AppLocalizations l10n, String type) {
    switch (type) {
      case 'logic_broken':
        return l10n.type_logic_broken;
      case 'forced':
        return l10n.type_forced;
      case 'verify':
        return l10n.type_verify;
      case 'structure_change':
        return l10n.type_structure_change;
      default:
        return type;
    }
  }

  String _getTargetLabel(AppLocalizations l10n, String target) {
    switch (target) {
      case 'buy':
        return l10n.target_buy;
      case 'hold':
        return l10n.target_hold;
      case 'sell':
        return l10n.target_sell;
      case 'stop':
        return l10n.target_stop;
      default:
        return target;
    }
  }

  String _getPriceLabel(BuildContext context, String stage) {
    final l10n = AppLocalizations.of(context)!;
    if (stage == 'entry_non_action') return l10n.label_missed_price;
    return l10n.label_deviation_price;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.addEvent(
        widget.planId,
        AddEventRequest(
          eventType: _eventType,
          summary: _summaryController.text.trim(),
          impactTarget: _impactTarget,
          triggeredExit: _triggeredExit,
          eventStage: _eventStage,
          behaviorDriver: _behaviorDriver,
          priceAtEvent: double.tryParse(_priceController.text),
        ),
      );
      if (!mounted) return;
      widget.onSuccess();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('添加失败: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final drivers = _getDriversForStage(_eventStage);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.title_add_event,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.label_event_explain,
                style: const TextStyle(fontSize: 12, color: AppColors.textWeak),
              ),
              const SizedBox(height: 16),

              Text(
                l10n.label_event_type,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    ['logic_broken', 'forced', 'verify', 'structure_change']
                        .map(
                          (t) => ChoiceChip(
                            label: Text(
                              _getTypeLabel(l10n, t),
                              style: TextStyle(
                                fontSize: 12,
                                color: _eventType == t
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            selected: _eventType == t,
                            onSelected: (s) => setState(() => _eventType = t),
                            selectedColor: Colors.blue,
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 16),

              Text(
                l10n.label_impact_target,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['buy', 'hold', 'sell', 'stop']
                    .map(
                      (t) => ChoiceChip(
                        label: Text(
                          _getTargetLabel(l10n, t),
                          style: TextStyle(
                            fontSize: 12,
                            color: _impactTarget == t
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        selected: _impactTarget == t,
                        onSelected: (s) => setState(() => _impactTarget = t),
                        selectedColor: Colors.green,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),

              Text(
                l10n.label_event_stage,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  'entry_deviation',
                  'entry_non_action',
                  'exit_deviation',
                  'stoploss_deviation',
                  'external_change',
                ].map((s) => _buildStageChip(s)).toList(),
              ),
              const SizedBox(height: 16),

              Text(
                l10n.label_behavior_driver,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: drivers.map((d) => _buildDriverChip(d)).toList(),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _summaryController,
                decoration: InputDecoration(
                  labelText: l10n.label_event_summary,
                  hintText: l10n.hint_summary_fact_only,
                  border: const OutlineInputBorder(),
                  counterText: '${_summaryController.text.length}/40',
                ),
                maxLength: 40,
                onChanged: (v) => setState(() {}),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? '不能为空' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: _getPriceLabel(context, _eventStage),
                  hintText: '可选',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 8),

              SwitchListTile(
                title: Text(
                  l10n.label_triggered_exit,
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: const Text(
                  '此事件是否意味着你应该执行卖出/止损',
                  style: TextStyle(fontSize: 12),
                ),
                value: _triggeredExit,
                onChanged: (v) => setState(() => _triggeredExit = v),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.btn_submit_event,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStageChip(String value) {
    final isSelected = _eventStage == value;
    return ChoiceChip(
      label: Text(
        _getStageLabel(context, value),
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _eventStage = value;
            _behaviorDriver = null; // Reset driver when stage changes
          });
        }
      },
      selectedColor: Colors.blue,
    );
  }

  Widget _buildDriverChip(String value) {
    final isSelected = _behaviorDriver == value;
    return ChoiceChip(
      label: Text(
        _getDriverLabel(context, value),
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _behaviorDriver = selected ? value : null;
        });
      },
      selectedColor: Colors.indigo,
    );
  }
}
